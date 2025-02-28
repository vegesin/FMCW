function filtered_signal = heartbeat_filter(signal, fs)
    % 输入参数：
    % signal: 输入信号 (1D array)
    % fs: 采样频率 (Hz)
    
    % 定义滤波器参数
    low_cutoff = 0.8; % 带通滤波器的低截止频率 (Hz)
    high_cutoff = 6;  % 带通滤波器的高截止频率 (Hz)
    filter_order = 100; % 滤波器阶数 (越高越陡峭)
    
    % 设计 FIR 带通滤波器
    bp_filter = designfilt('bandpassfir', ...
                           'FilterOrder', filter_order, ...
                           'CutoffFrequency1', low_cutoff, ...
                           'CutoffFrequency2', high_cutoff, ...
                           'SampleRate', fs);
    
    % 应用滤波器
    filtered_signal = filtfilt(bp_filter, signal); % 双向滤波，避免相位失真
end