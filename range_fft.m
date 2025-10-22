
% input: read_data 输出的 chirp矩阵 
% output: 绘制RTM RDM data_rangefft 之后的数据矩阵 （横轴 距离（adc采样点数） | 竖轴 chirp个数）

% 所有接受通进行fft 取出一个维度 转置操作

function [data_rangefft_trans,data_rangefft_single] =  range_fft(data_matrix,radar_params)

% !加窗的问题
win_r = hamming(radar_params.chirp_len);
data_rangefft = zeros(size(data_matrix));

for ch = 1:radar_params.Rx_channel
    data_rangefft(:,:,ch) = fft(data_matrix(:,:,ch).* (win_r*ones(1,radar_params.chirp_num)));  % 默认对 每一列 
    % data_rangefft(:,:,ch) = fft(data_matrix(:,:,ch)); % 不加窗
    
end


% 数据转置 排列成为 -->（横轴 距离（adc采样点数） | 竖轴 chirp个数）
% ? permute 对于复数进行转置存在的问题
% data_rangefft = permute(data_rangefft,[2,1,3]);


% ? 使用 .' 循环对每一维度进行转置
size_data_rangefft = size(data_rangefft);
data_rangefft_trans = zeros(size_data_rangefft(2),size_data_rangefft(1),size_data_rangefft(3));

for ch = 1:radar_params.Rx_channel
    % 参考下面的代码 实现转置 
    % range_fft_single = range_fft(:,:,1);
    % range_fft_single = range_fft_single.';  % 复数转置  
    data_rangefft_trans(:,:,ch) = data_rangefft(:,:,ch).';  % 复数转置
end

data_rangefft_single = data_rangefft_trans(:,:,1);
size_data_rangefft = size(data_rangefft_trans);
fprintf("[range_fft] data size: %d x %d x %d\n",size_data_rangefft(1),size_data_rangefft(2),size_data_rangefft(3));


% image show

figure(Name = "Range FFT");
% Plot 3D Surface Plot
subplot(1, 2, 1);
[X, Y] = meshgrid(radar_params.range_lin, radar_params.time_lin);
surf(X, Y, abs(data_rangefft_single));  % Plot the magnitude of FFT result in 3D
xlabel('距离(m)');
ylabel('时间(s)');
zlabel('幅值');
% title('Range FFT 3D Surface');
shading interp;  % Smooth the surface for better visualization
colorbar;


% Plot Heatmap (2D image)
subplot(1, 2, 2);
imagesc(radar_params.range_lin, radar_params.time_lin, abs(data_rangefft_single));  % Plot the magnitude of FFT result
xlabel('距离(m)');
ylabel('时间(s)');
% title('RTM');
colorbar;  % Add a colorbar for magnitude scaling

end
