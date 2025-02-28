% !----------------------------------------------------------------
% ! RTM sim --> chirp Tx Rx IF
% !----------------------------------------------------------------


clear all;
close all;

% ----------------------------------------------------------------
% 雷达基本参数
% ----------------------------------------------------------------

radar_params.c = 3e8;                                               % 光速
radar_params.fc = 77e9;                                             % 载波 77Ghz
radar_params.lamada = radar_params.c / radar_params.fc;             % 波长


radar_params.chirp_len = 256;                                       % chirp adc 采样点数
radar_params.chirp_per_frame = 5;                                   % 一帧chirp的个数
radar_params.frame_len = 1000;                                      % 帧数  
radar_params.chirp_num = radar_params.chirp_per_frame*radar_params.frame_len; 
                                                                    % 一个维度的chirp 个数

radar_params.S = 60.012e12;                                         % mmwave 调频斜率
radar_params.fs = 5e6;                                              % mmwave 配置采样速率

radar_params.chirp_time = radar_params.chirp_len / radar_params.fs; % chir持续时间 s
radar_params.idle_time = 12e-6;                                     % chirp间隔时间s(us）
radar_params.total_time = 20;                                       % 信号采集的总时间 包含帧间隔 s 

radar_params.B = radar_params.S*radar_params.chirp_time;            % 调频带宽
radar_params.bin_r = radar_params.c/radar_params.B/2;               % 距离门
% radar_params.bin_v =                                              % 速度门

radar_params.Tx_channel = 1;                                        % 发射天线数量
radar_params.Rx_channel = 4;                                        % 接受天线数量

radar_params.time_lin = linspace(1,radar_params.total_time,radar_params.chirp_num); % 雷达数据 时间坐标轴
radar_params.range_lin = (1:radar_params.chirp_len) * radar_params.bin_r;           % 雷达数据 距离坐标轴



% ----------------------------------------------------------------
%  LFMCW发射&接受信号仿真 仿真第一个chirp
% ----------------------------------------------------------------

r0 = 11.2;  % 仿真探测目标距离 m



Tx_chirp1 = zeros(1,radar_params.chirp_len);
Rx_chirp1 = zeros(1,radar_params.chirp_len);
t1 = linspace (0,radar_params.chirp_time,radar_params.chirp_len) ;   % 一个chirp 持续的时间和adc采样的点数 发射信号的时间轴
td1 = 2 * r0/radar_params.c ;                                                      % 接受回波信号的距离延时
t2 = t1 + td1*ones(1,radar_params.chirp_len);

% 时域波形
for i = 1:1:radar_params.chirp_len
    Tx_chirp1(i) = cos (2*pi* (radar_params.fs*t1(i) + 1/2* (radar_params.S*t1(i)^2)));
    Rx_chirp1(i) = cos (2*pi* (radar_params.fs*t2(i) + 1/2* (radar_params.S*t2(i)^2)));
end

% fprintf("length of Tx_chirp1: %d \n", length(Tx_chirp1));

figure(Name = 'FMCW');
subplot(311);
plot(t1,Tx_chirp1,'b');
title('第一个chirp的时域发射信号');
xlabel('时间 s');
ylabel('幅度');

subplot(312);
plot(t2,Rx_chirp1,'r');
title('第一个chirp的时域回波信号');
xlabel('时间 s');
ylabel('幅度');

% f-t图
subplot(313);
freq1 = radar_params.fs * ones(1,radar_params.chirp_len) + radar_params.S * t1;
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
mix = zeros(1,length(radar_params.chirp_len));
for i = 1:1:radar_params.chirp_len
    mix(i) = Tx_chirp1(i) .* Rx_chirp1(i);
end

% fft
mix_fft = abs(fft(mix));

figure(Name = 'IF');
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
plot(mix_fft(1:radar_params.chirp_len/2));
title('第一个chirp的FFT (前面n/2个点)');
xlabel('频率(Hz)');
ylabel('幅度');
