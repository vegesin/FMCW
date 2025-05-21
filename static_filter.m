% 针对一个维度的rangefft 滤除静态杂波
% TODO: 测试CFAR

function [data_static_filter] = static_filter(data_rangefft_single,radar_params)

% 1.背景静态杂波滤除 向量均值相消

% % 计算静态杂波的均值
% staticClutter = mean(radarData, 2); % 对每一行求时间均值

% % 静态杂波滤除 

% 向量均值相消
% static_noise = mean(data_rangefft_single,1); % 按照 列求均值 
% data_rangefft_single  = data_rangefft_single - static_noise;

% 窗口MTI
% data_rangefft_single = MTI_wind(data_rangefft_single,5);

% 2.MTI

% 初始化输出矩阵
data_static_filter = zeros(size(data_rangefft_single));

% 二阶差分滤波器（MTI 滤波器）
% 滤波器系数：h[n] = [1, -2, 1]
% 该滤波器可以抑制恒定目标的回波
MTI_filter = [1, -2, 1];


% 对每个距离单元（列）应用 MTI 滤波器
for col = 1:radar_params.chirp_len
    % 提取每个距离单元的时间序列
    time_series = data_rangefft_single(:, col);
    
    % 使用滤波器进行静态杂波抑制
    filtered_series = conv(time_series, MTI_filter, 'same');
    
    % 保存结果
    data_static_filter(:, col) = filtered_series;
end


% image show
% radar_params.range_lin = (1:radar_params.chirp_len) * radar_params.bin_r;
% radar_params.time_lin = linspace(1,radar_params.total_time,radar_params.chirp_per_frame*radar_params.frame_len);

figure(Name = "静态杂波滤除");

% Plot 3D Surface Plot
subplot(1, 2, 1);
[X, Y] = meshgrid(radar_params.range_lin, radar_params.time_lin);
surf(X, Y, abs(data_static_filter));  % Plot the magnitude of FFT result in 3D
xlabel('距离(m)');
ylabel('时间(s)');
zlabel('幅值');
shading interp;  % Smooth the surface for better visualization
colorbar;


% Plot Heatmap (2D image)
subplot(1, 2, 2);
imagesc(radar_params.range_lin, radar_params.time_lin, abs(data_static_filter));  % Plot the magnitude of FFT result
xlabel('距离(m)');
ylabel('时间(s)');
zlabel('幅值');
colorbar;  % Add a colorbar for magnitude scaling


end