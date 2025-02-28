% DCA1000+xWR1642数据录取分组程序
% 数据存储格式参考mmwave_studio_user_guide page.57

% TODO: 封装加入 n发m收体制的雷达，现在的代码是一发Rx_chan收

function [Rx_chan_data] = data_reshape_DCA1000_xWR1642(dataDec,chirp_len,chirp_per_frame,frame_len,Rx_chan)


data = reshape(dataDec,chirp_len*Rx_chan*2,chirp_per_frame*frame_len);  % 将数据按照chirp分组
% 行：一个chirp的长度 256*2 4个天线拼接  | 列：chirp的个数 5*1000

Rx_data = zeros(chirp_len*2,chirp_per_frame*frame_len,Rx_chan); 

for ki = 1:Rx_chan
    Rx_data(:,:,ki) = data((ki-1)*chirp_len*2+1:ki*chirp_len*2,:);
end


I_0 = Rx_data(1:4:end,:,:);
I_1 = Rx_data(2:4:end,:,:);
Q_0 = Rx_data(3:4:end,:,:);
Q_1 = Rx_data(4:4:end,:,:);


data_0 = I_0 + 1i*Q_0;
data_1 = I_1 + 1i*Q_1;


Rx_chan_data = zeros(chirp_len,chirp_per_frame*frame_len,Rx_chan);

for ki = 1:chirp_len/2
    Rx_chan_data(ki*2-1,:,:) = data_0(ki,:,:); % 奇
    Rx_chan_data(ki*2,:,:) = data_1(ki,:,:);   % 偶 
end




% ----------------------------------------------------------------
% 最终输出 Rx_chan_data 是一个三维复数矩阵：
% 维度为 (chirp_len, chirp_per_frame * frame_len, Rx_chan)。
% 含义：
% 第一维：每个 chirp 的采样点数。
% 第二维：所有 chirp（跨帧）的序列。
% 第三维：接收通道。 4个通道 一发三收
% 这个矩阵适用于后续信号处理，比如 FFT 分析、目标检测等。

