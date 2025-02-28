%  封装差分信号处理 
% 相位提取 人体位置提取 相位unwrap 相位差分

function [f_diff] = phase_extract(data_input,radar_params)

f_phase  = zeros(size(data_input));

% 转换绝对值之后，无法提取复数的实部和虚部
range_real = real(data_input);
range_imag = imag(data_input);


for i = 1:radar_params.chirp_num
    for j = 1:radar_params.chirp_len
        f_phase(i,j) = atan2(range_imag(i,j),range_real(i,j));
    end
end


% Range-bin tracking 找出能量最大的点，即人体的位置 
% [~,max_index] = max(sum(abs(data_input),1)); % 列方向上求和 返回最大索引 

range_accumulate = zeros(1,radar_params.chirp_len); 
range_max = 0;
for j = 1:radar_params.chirp_len
    for i = 1:radar_params.chirp_num % 进行 距离 非相干积累 寻找人体位置
        range_accumulate(j) = range_accumulate(j) + data_input(i,j);
    end
    
    if ( range_accumulate(j) > range_max)
        range_max = range_accumulate(j);
        max_num = j;
    end
end 

% disp(max_num);
fprintf("[phase extract]: range bin num = %d \n", max_num);

% 相位提取 分析n个chirp的max_num门
f_phase_extract = f_phase(:,max_num);

% 相位解缠绕
f_phase_unwrap = unwrap(f_phase_extract);


% 相位差分
% f_diff = 0;
f_diff = zeros(1,radar_params.chirp_num);
for i = 1:radar_params.chirp_num - 1
    f_diff(i) = f_phase_unwrap(i+1) - f_phase_unwrap(i);
    % 最后一个信号的相位差分 减去前面一个
    f_diff(radar_params.chirp_num)=f_phase_unwrap(radar_params.chirp_num)-f_phase_unwrap(radar_params.chirp_num-1); 
end 


% image show
figure(Name = 'phase extract unwrap diff');
subplot(311);
plot(f_phase_extract);
title('Phase');

subplot(312);
plot(f_phase_unwrap);
title('Unwrap');

subplot(313);
plot(f_diff);
xlabel('点数');
ylabel('相位');
title('Diff');

end