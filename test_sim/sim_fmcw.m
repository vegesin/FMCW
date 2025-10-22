% 现在sim_RDM.m 是复制的sim_fmcw.m



% ------------------------- fmcw 仿真 ----------------------------

% 雷达基本参数设置
% 数据cube的生成
% 距离 快时间 chirp 采样点数 fft
% 速度 慢时间 chirp 个数 fft


% !----------------------------------------------------------------
% !使用生成LFMCW仿真数据  检测目标距离 180 速度 10
% !----------------------------------------------------------------

clc;
close all;

% ----------------------------------------------------------------
% 雷达基本参数
% ----------------------------------------------------------------

maxR = 200;           % 雷达最大探测目标的距离
rangeRes = 1;         % 雷达的距离分率
maxV = 70;            % 雷达最大检测目标的速度
fc= 77e9;             % 雷达工作频率 载频 77GHz
c = 3e8;              % 光速 

r0 = 180;             % 目标距离设置 (max = 200m)
v0 = 30;              % 目标速度设置 (min =-70m/s, max=70m/s)


B = c / (2*rangeRes);  % 调频带宽 B = 150MHz，设置距离分辨率的情况下给出带宽B 

% t_chirp --> 发射chirp的持续时间 | t_endle--> 停止发射间隔时间
% 扫频时间 (x-axis), 5.5 往返时间的5到6倍
t_chirp = 5.5 * 2 * maxR/c;  % 扫频时间 
t_endle = 0; %6.3e-6;        % 空闲时间

slope = B / t_chirp;         % 调频斜率

f_IFmax = (slope*2*maxR)/c ; % 最高中频频率
f_IF=(slope*2*r0)/c ;        % 探测当前目标的中频信号 td1*slope


% Nd = 128;
% Nr = 1024;

num_chirp = 128;             % chirp数量     Nd      
num_adc = 1024;              % adc采样点数   Nr

vRes =  (c / fc) / (2*num_chirp* (t_chirp+t_endle)); % 速度分辨率 


Fs = num_adc / t_chirp;       %  Nr（ADC采样点数）= FS （采样速率） * t_chirp （信号时宽）

% t = linspace(0,num_chirp*t_chirp,num_adc*num_chirp);  % 离散信号总的点数


% ----------------------------------------------------------------
%  LFMCW发射&接受信号仿真 仿真第一个chirp
% ----------------------------------------------------------------

Tx_chirp1 = zeros(1,num_adc);
Rx_chirp1 = zeros(1,num_adc);
t1 = linspace (0,t_chirp,num_adc) ;   % 一个chirp 持续的时间和adc采样的点数 发射信号的时间轴
td1 = 2 * r0/c;                       % 接受回波信号的距离延时
t2 = t1 + td1*ones(1,num_adc);

% 时域波形
for i = 1:1:num_adc
    Tx_chirp1(i) = cos (2*pi* (fc*t1(i) + 1/2* (slope*t1(i)^2)));
    Rx_chirp1(i) = cos (2*pi* (fc*t2(i) + 1/2* (slope*t2(i)^2)));
end

fprintf("length of Tx_chirp1: %d \n", length(Tx_chirp1));

figure();
subplot(311);
plot(t1,Tx_chirp1,'b');
title('第一个chirp的时域发射信号');
xlabel('时间');
ylabel('幅度');

subplot(312);
plot(t2,Rx_chirp1,'r');
title('第一个chirp的时域回波信号');
xlabel('时间');
ylabel('幅度');

% f-t图
subplot(313);
freq1 = fc * ones(1,num_adc) + slope * t1;
plot(t1,freq1);
hold on;
plot(t2,freq1);
xlabel('时间');
ylabel('频率');
title('接收信号与发射信号时频图');
legend ('TX','RX');


% ----------------------------------------------------------------
% IF中频信号 | 回波信号和发射信号乘积 经过滤波器去除高频 留下差频
% ----------------------------------------------------------------


% 第一个chirp 中频
mix = zeros(1,length(num_adc));
for i = 1:1:num_adc
    mix(i) = Tx_chirp1(i) .* Rx_chirp1(i);
end

% fft
mix_fft = abs(fft(mix));

figure();
subplot(311);
plot(mix);
title('第一个chirp的差频信号');
xlabel('时间');
ylabel('幅度');

subplot(312);
plot(mix_fft);
title('第一个chirp的FFT');
xlabel('频率(Hz)');
ylabel('幅度');

subplot(313);
plot(mix_fft(1:num_adc/2));
title('第一个chirp的FFT (前面n/2个点)');
xlabel('频率(Hz)');
ylabel('幅度');


% ----------------------------------------------------------------
% 处理128个chirp | cube 、range、v
% ----------------------------------------------------------------

t = linspace(0,num_chirp*t_chirp,num_adc*num_chirp);  % 离散信号总的点数
Tx_chirp128 = cos (2*pi* (fc*t + 1/2 * (slope*t .^2)));

% 动目标延时 = 距离延时 td1 + 速度延时td2 (2vt / c )
td2 = 2*v0/c .*t;  
t3 = t - (td1*ones(1,num_chirp*num_adc) + td2); 
Rx_chirp128 = cos (2*pi* (fc*t3 + 1/2* (slope*t3 .^2)));

cube = Tx_chirp128 .* Rx_chirp128 ;
cube = reshape(cube,num_adc,num_chirp);

fprintf("size of cube %d x %d\n", size(cube, 1), size(cube, 2));

figure();
mesh(cube);
title("data cube");
xlabel("慢时间(速度) chirp个数 128");
ylabel("快时间(距离) adc采样点数 1024");
zlabel("幅度");



% range 对 num_adc 进行fft
cube_fft1 = fft(cube,num_adc) ./ num_adc;
cube_fft1 = abs(cube_fft1);
cube_fft1 = cube_fft1(1:(num_adc/2) , :);
figure(Name = 'range fft')


subplot(121);
%surf(10*log(abs(cube_fft1)));
mesh(cube_fft1);
xlabel('Doppler');
ylabel('Range');
%zlabel('幅度');
%title('距离维FFT');

subplot(122);
imagesc(cube_fft1)
xlabel('Doppler')
ylabel('Range')


% fft2 两个维度上fft得到速度和距离信息 num_chirp --> v
cube_fft2 = fft2(cube,num_adc,num_chirp);
cube_fft2 = cube_fft2(1:num_adc/2 , 1:num_chirp);
cube_fft2 = fftshift(cube_fft2);

RDM = abs(cube_fft2);
RDM = 10*log10(RDM);

figure();
%  这两个坐标的设定 --> 距离 速度 解算问题 坐标轴转换为速度门 距离门 频点落到哪个门上

% doppler_axis = linspace(-100,100,num_chirp);
% range_axis = linspace(-200,200,num_adc/2)*((num_adc/2)/400);

doppler_axis = linspace(-maxV,maxV,num_chirp)*vRes*(num_chirp / 200);
range_axis = linspace(-maxR,maxR,num_adc/2)*rangeRes*(num_adc/2 / 400);

subplot(121);
mesh(doppler_axis,range_axis,RDM);
title('Range-Doppler Map'); 
xlabel('多普勒通道'); 
ylabel('距离通道'); 
zlabel('幅度');


subplot(122);
imagesc(abs(cube_fft2));


