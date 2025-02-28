% ----------------------------------------------------------------
% 回波数据--> 距离FFT--> 静态杂波滤除 --> 人体位置提取
% 差分信号--> 0.3-6 hz滤波 --> SSA 分解信号 
% 呼吸谐波影响评估 --> 后向差分 --> hsp
% ----------------------------------------------------------------


clc;
close all;
clear all;


%! 第二套mmwave studio 采集参数
c = 3e8;
fc = 77e9;
lamada = c/fc;

chirp_len = 256;
chirp_per_frame = 5;
frame_len = 1000;

S = 60.012e12;
fs = 5e6;

chirp_time = chirp_len / fs; % 5.12e-05   50us  
idle_time  = 12e-6;   
total_time =  20;

B = S * chirp_time;

bin_r = c/B/2;               
Fr = 1/chirp_time;  
Rx_channel= 4;     



%! 数据读取
% file_name = "../data1/adc_data250107_1.bin"; 

% fid = fopen(file_name,'r');
% fseek(fid,0,1);
% data_length = ftell(fid);
% fseek(fid,0,-1);

% rawData = fread(fid,data_length/2,'int16');
% dataDec = rawData-(rawData>=2^14).*2^15;        % 这会将原本存储的负数数据转换成负的有符号数。


% fprintf("data_length = %d \n",data_length);

% [rx_4channel_data] = data_reshape_DCA1000_xWR1642(dataDec,chirp_len,chirp_per_frame,frame_len,Rx_channel);


%! 距离FFT


%! 先直接读取保存好的angle_fft_diff
diff_filename = '../data1/diff.mat';
loaded_data = load(diff_filename);            % 载入文件，数据存储为结构体
diff_phase = loaded_data.angle_fft_diff;            % 提取数据

% 第二套数据 无EGC
% diff_filename = '../data1/diff2.mat';
% loaded_data = load(diff_filename);            % 载入文件，数据存储为结构体
% diff_phase = loaded_data.diff2;                     % 提取数据


diff_fft = fft(diff_phase);                         % FFT 差分信号频谱

N = length(diff_phase);               % 5000
T = 20;                       % 20 seconds
% T = 100;                        % 100 seconds 50hz
t_n = linspace(1,T,N);          % 时间坐标轴 20s 5000点

fs = N/T;                       % 250hz
f_n = (0:N-1) * (fs/N);         % 频率坐标轴 250hz 5000点
show_points = 500;              % 截取显示的点数 200点--> 10Hz

% 0.8-6hz filter

diff_filter = heartbeat_filter(diff_phase,fs);
diff_filter_fft = fft(diff_filter);

% image diff_phase
image_diff = figure(Name='差分信号');
subplot(221);
plot(t_n,diff_phase);
xlabel('时间 t/s');title('提取的差分信号 时域');

subplot(222);
% plot(f_n(1:show_points),abs(diff_fft(1,show_points)));
plot(f_n,abs(diff_fft));
xlabel('频率 f/Hz'); title('提取的差分信号 频域');

subplot(223);
plot(t_n,diff_filter);
xlabel('时间 t/s'); title('0.8-6hz滤波后的差分信号 时域');

subplot(224);
% plot(f_n(1:show_points),diff_filter_fft(1,show_points));
plot(f_n(1:show_points),abs(diff_filter_fft(1:show_points)));
xlabel('频率 f/Hz'); title('0.8-6hz滤波后的差分信号 频域');



%% SSA 分解
% 参数设置
L = floor(N / 2); % 轨迹矩阵的窗口长度 (一般设为信号总长度的一半)
K = N - L + 1;    % 列数
trajectory_matrix = zeros(L, K);

% 构造轨迹矩阵
for i = 1:K
    trajectory_matrix(:, i) = diff_filter(i:i+L-1); % 每列为一个窗口
end

% 奇异值分解 (SVD)
[U, S, V] = svd(trajectory_matrix, 'econ'); % 轨迹矩阵的奇异值分解
singular_values = diag(S); % 提取奇异值

% 绘制奇异值谱
figure;
plot(singular_values, '-o');
title('奇异值谱');xlabel('分量索引');ylabel('奇异值');
grid on;


%% 绘制前 6 个分量的时域图
num_components = 6; % 要绘制的分量数
ssa_components = zeros(num_components, N); % 存储每个分量的信号

for i = 1:num_components
    Ui = U(:, i); % 第 i 个左奇异向量
    Vi = V(:, i); % 第 i 个右奇异向量
    Si = S(i, i); % 第 i 个奇异值
    reconstructed_matrix = Si * (Ui * Vi'); % 重构的轨迹矩阵

    % 每个分量的重建信号
    component_signal = zeros(1, N);
    for j = 1:K
        component_signal(j:j+L-1) = component_signal(j:j+L-1) + reconstructed_matrix(:, j)';
    end
    % 平均化
    ssa_components(i, :) = component_signal ./ (min(L, N - (0:N-1)) + min(L, (N-1-(0:N-1)) + 1));
end

% 绘制每个分量的时域图
figure;
for i = 1:num_components
    subplot(num_components, 1, i);
    plot(t_n, ssa_components(i, :), 'b');
    title(['分量 ', num2str(i), ' 的时域信号']);
    xlabel('时间 (s)');
    ylabel('幅值');
    xlim([0, T]);
    grid on;
end


figure;

for i = 1:num_components
    component_signal_fft = fft(ssa_components(i, :));
    subplot(num_components, 1, i);
    plot(f_n(1:show_points),abs(component_signal_fft(1:show_points)) , 'b');
    title(['分量 ', num2str(i), ' 的频谱']);
    xlabel('频率 f/hz');
    ylabel('幅值');
    xlim([0, T]);
    grid on;
end



%% 信号重构
% 选择主分量 (如选择前6个主要分量)
components_to_reconstruct = 1:6;

% 重构信号
ssa_reconstructed = zeros(1, N);
for i = components_to_reconstruct
    Ui = U(:, i); % 第 i 个左奇异向量
    Vi = V(:, i); % 第 i 个右奇异向量
    Si = S(i, i); % 第 i 个奇异值
    reconstructed_matrix = Si * (Ui * Vi'); % 重构的轨迹矩阵
    for j = 1:K
        ssa_reconstructed(j:j+L-1) = ssa_reconstructed(j:j+L-1) + reconstructed_matrix(:, j)';
    end
end

% 平均化重构信号 归一化
ssa_reconstructed = ssa_reconstructed ./ (min(L, N - (0:N-1)) + min(L, (N-1-(0:N-1)) + 1));

%% 显示重构信号
figure;
subplot(2,1,1);
plot(t_n, diff_filter./max(diff_filter), 'b-', 'DisplayName', '滤波后信号');
hold on;
plot(t_n, ssa_reconstructed./max(ssa_reconstructed), 'r-', 'DisplayName', '重构信号 (SSA)');
title('滤波信号与重构信号 (SSA)');
xlabel('时间 (s)');
ylabel('归一化幅值');
legend('show');
grid on;

subplot(2,1,2);
ssa_reconstructed_fft = fft(ssa_reconstructed);
plot(f_n(1:show_points), abs(diff_filter_fft(1:show_points))./max(abs(diff_filter_fft(1:show_points))), 'b-', 'DisplayName', '滤波信号频谱');
hold on;
plot(f_n(1:show_points), abs(ssa_reconstructed_fft(1:show_points))./max(abs(ssa_reconstructed_fft(1:show_points))), 'r-', 'DisplayName', '重构信号频谱');
title('滤波信号与重构信号的频谱');
xlabel('频率 (Hz)');
ylabel('归一化幅值');
legend('show');
grid on;

%% ssa重构频谱一阶差
ssa_diff = [0, diff(ssa_reconstructed)];  % 一阶后向相差分（首元素补0以对齐长度）

% 计算差分信号的频谱
ssa_diff_fft = fft(ssa_diff);

% 绘制差分信号的时域与频域图
figure;

% 时域对比
subplot(2, 1, 1);
plot(t_n, ssa_reconstructed, 'b-', 'DisplayName', 'SSA重构信号');
hold on;
plot(t_n, ssa_diff, 'r--', 'DisplayName', 'SSA信号一阶差分');
xlabel('时间 (s)');
ylabel('幅值');
title('SSA重构信号与其一阶差分信号（时域）');
legend('show');
grid on;

% 频域对比
subplot(2, 1, 2);
plot(f_n(1:show_points), abs(ssa_reconstructed_fft(1:show_points))./max(abs(ssa_reconstructed_fft(1:show_points))), 'b-', 'DisplayName', '重构信号频谱');
hold on;
plot(f_n(1:show_points), abs(ssa_diff_fft(1:show_points))./max(abs(ssa_diff_fft(1:show_points))), 'r--', 'DisplayName', '一阶差分信号频谱');
xlabel('频率 (Hz)');
ylabel('归一化幅值');
title('SSA重构信号与其一阶差分信号的频谱');
legend('show');
grid on;






