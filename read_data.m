% 基于data_reshape_DCA1000 进一步封装数据读取代码
% input : file_name,chirp_len,chirp_per_frame,frame_len,Rx_channel
% output : data_matrix (todo: fix a name

function  [data_matrix] = read_data(file_name,radar_params)

fid = fopen(file_name,'r');
fseek(fid,0,1);
data_length = ftell(fid);
fseek(fid,0,-1);

rawData = fread(fid,data_length/2,'int16');
dataDec = rawData-(rawData>=2^14).*2^15;        % 这会将原本存储的负数数据转换成负的有符号数。


% TODO: 添加Tx_channel 将代码修改为读取n发m收的
[data_matrix] = data_reshape_DCA1000_xWR1642(dataDec,radar_params.chirp_len,radar_params.chirp_per_frame,radar_params.frame_len,radar_params.Rx_channel);


% debug info
data_matrix_size = size(data_matrix);
fprintf("[read_data]:data_length = %d bytes \n",data_length);
fprintf("[read_data]:data_matrix shape = %d x %d x %d\n",data_matrix_size(1),data_matrix_size(2),data_matrix_size(3));

end

