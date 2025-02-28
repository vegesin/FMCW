% TODO : 生成一个标准的信号（心跳+呼吸+高次谐波+噪声） 进行 ssa_vhps 仿真

clear all;
close all;
addpath(genpath('../'));

% addpath(genpath('.\lib')); % 添加目文件夹下面的函数 



% MATLAB code to generate a heartbeat signal with harmonics and noise

% Sampling frequency
fs = 2000;  % 1000 Hz sampling rate

% Time vector (e.g., for 5 seconds)
t = 0:1/fs:5-1/fs;  

% Parameters from the table
a_h1 = 0.48;  % Amplitude of the 1st harmonic (mm)
a_h2 = 0.24;  % Amplitude of the 2nd harmonic (mm)
a_h3 = 0.20;  % Amplitude of the 3rd harmonic (mm)

f_h = 1.2;    % Fundamental frequency (Hz)

theta_1 = rand()*2*pi;  % Random phase for 1st harmonic
theta_2 = rand()*2*pi;  % Random phase for 2nd harmonic
theta_3 = rand()*2*pi;  % Random phase for 3rd harmonic

% Signal generation using harmonics
x_harmonics = a_h1 * cos(2 * pi * f_h * t + theta_1) + ...
              a_h2 * cos(2 * pi * 2 * f_h * t + theta_2) + ...
              a_h3 * cos(2 * pi * 3 * f_h * t + theta_3);

% Add Gaussian noise (SNR = 3 dB)
snr_db = 3;  % Signal-to-Noise Ratio in dB
x_noisy = awgn(x_harmonics, snr_db, 'measured');  % Add noise to signal

% Plot the signal
figure;
plot(t, x_noisy);
title('Simulated Heartbeat Signal with Harmonics and Noise');
xlabel('Time (seconds)');
ylabel('Amplitude (mm)');
grid on;

% Optional: Save the signal to a file
% save('heartbeat_signal_with_harmonics.mat', 't', 'x_noisy');


% test func

diff_params.n = length(x_noisy);                                                 % 差分信号点数
diff_params.fs = fs;                                      % 差分信号采样速率
diff_params.time_lin = linspace(1,5,diff_params.n);       % 差分信号 时间坐标轴
diff_params.freq_lin = (0:diff_params.n - 1) * (diff_params.fs / diff_params.n);% 差分信号 频率坐标轴




my_ssa_vhsp(x_noisy,diff_params);
