function [f_output] = lowpass_filter(f_input,diff_params)

        show_points = 500;
        % 3hz的椭圆低通去除差分信号的高频分量 
        f_output = elliptic_lowpass_filter(f_input);
        figure(Name = '差分 - 椭圆滤波器 '); 
        subplot(211);
        plot(diff_params.time_lin,f_output);
        title("3hz低通滤波之后的差分信号 时域");
        % xlabel('时间 t/s','HorizontalAlignment', 'right');
        xlabel("时间(s)");
        
        subplot(212);
        f_output_fft = fft(f_output);
        plot(diff_params.freq_lin(1:show_points),abs(f_output_fft(1:show_points)));
        title("3hz低通滤波之后的差分信号 频域");
        % xlabel('频率 f/hz','HorizontalAlignment', 'right');
        xlabel("频率(Hz)");

end




function [y, b, a] = elliptic_lowpass_filter(x)
    % ELLIPTIC_LOWPASS_FILTER 设计并应用椭圆低通滤波器
    % 输入：
    %   x    - 输入信号（向量）
    % 输出：
    %   y    - 滤波后的信号
    %   b, a - 滤波器的分子和分母系数（用于分析滤波器）
    


        Fs = 250;          % 采样频率 (Hz)
        Fc = 3;            % 截止频率 (Hz)
        Rp = 1;            % 通带波纹 (dB)
        Rs = 40;           % 阻带衰减 (dB)

        % 归一化截止频率
        Wn = Fc / (Fs / 2);
        
        % 估算滤波器的阶数 N 和截止频率
        [N, Wn] = ellipord(Wn, Wn + 0.2, Rp, Rs);
        
        % 设计椭圆低通滤波器
        [b, a] = ellip(N, Rp, Rs, Wn, 'low');
        
        % 应用滤波器
        y = filter(b, a, x);
        
        % 可选：绘制滤波器的频率响应（如果需要）
        % fvtool(b, a, 'Fs', Fs);
    end
    