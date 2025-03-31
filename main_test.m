

% |------------------------------------------------------
% |@Author: FunPlus007
% |@Date: 2025-02-07
% |@FilePath: \SSA_VHPS\main_test.m
% |@Description:  毫米波雷达 呼吸心跳提取 毕设主程序
% |-------------------------------------------------------






clear ;
clc;
close all;


% ----------------------------------------------------------------
% 雷达基本参数
% ----------------------------------------------------------------

% 第二套mmwave studio 采集参数
% 使用结构体封装参数

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
% 差分信号提取
% ----------------------------------------------------------------
% read data
% file_name = "../data1/adc_data250107_1.bin"; 
file_name = "./data1/adc_data250107_1.bin"; 
data_matrix = read_data(file_name,radar_params);

% range fft
[data_rangefft,data_rangefft_single] = range_fft(data_matrix,radar_params);

% statistics noise filter
[data_static_filter] = static_filter(data_rangefft_single,radar_params);

% phase extract
[f_diff] = phase_extract(data_static_filter,radar_params);




% ----------------------------------------------------------------
% 心跳提取算法
% ----------------------------------------------------------------

diff_params.n = length(f_diff);                                                 % 差分信号点数
diff_params.fs = diff_params.n / radar_params.total_time ;                      % 差分信号采样速率
diff_params.time_lin = linspace(1,radar_params.total_time,diff_params.n);       % 差分信号 时间坐标轴
diff_params.freq_lin = (0:diff_params.n - 1) * (diff_params.fs / diff_params.n);% 差分信号 频率坐标轴

show_points = 500;

% bandpass filter to extract heart and breath

[f_heart_filt,f_beath_filt] = my_filter(f_diff,diff_params);


% 0.8-6hz heartbeeat_filter

f_diff_filter = heartbeat_filter(f_diff,diff_params.fs);
f_diff_filter_fft = fft(f_diff_filter);

figure(Name = "滤波后的差分信号");
subplot(211);
plot(diff_params.time_lin,f_diff_filter);
xlabel('时间 t/s'); title('0.8-6hz滤波后的差分信号 时域');

subplot(212);
plot(diff_params.freq_lin(1:show_points),abs(f_diff_filter_fft(1:show_points)));
xlabel('频率 f/Hz'); title('0.8-6hz滤波后的差分信号 频域');


% 模态分解类算法总结 EMD VMD VME
% lowpass
f_diff_lowpass = lowpass_filter(f_diff,diff_params);

% EMD
% emd_f = f_diff;
emd_f = f_diff_lowpass;
% emd_f = f_diff_filter;
my_emd(emd_f,diff_params);


% VMD
% vmd_f = f_diff;
vmd_f = f_diff_lowpass;
% vmd_f = f_diff_filter;
my_vmd(vmd_f,diff_params);

% VME
% ? VME 这里滤波与否待定
% vme_f = f_diff;
vme_f = f_diff_lowpass;
% vme_f = f_diff_filter;
my_vme(vme_f,diff_params);





% ----------------------------------------------------------------
% % TODO: ssa_vhps 奇异值分解 变分谐波谱乘积 呼吸振幅因子判断
% ----------------------------------------------------------------

% main_ssa_vhps 

f_ssa_vhps = f_diff_filter;
my_ssa_vhps(f_ssa_vhps,diff_params);

% % test ssa
% N = diff_params.n;
% L = floor(N / 10);
% [f_components,f_ssa] = ssa(f_diff_filter,L,diff_params);
