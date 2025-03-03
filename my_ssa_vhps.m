function my_ssa_vhps(f_input,diff_params)

fprintf("\n\n-------------------------------- SSA vhps --------------------------------\n");

show_points =300;
N = diff_params.n;
f_input_fft = fft(f_input);


% SSA 奇异谱分析
% 参数设置
L = floor(N / 10); % 轨迹矩阵的窗口长度 (一般设为信号总长度的一半)
% L = 100;
K = N - L + 1;    % 列数
trajectory_matrix = zeros(L, K);

% 构造轨迹矩阵
for i = 1:K
    trajectory_matrix(:, i) = f_input(i:i+L-1); % 每列为一个窗口
end

% 奇异值分解 (SVD)
[U, S, V] = svd(trajectory_matrix, 'econ'); % 轨迹矩阵的奇异值分解
singular_values = diag(S); % 提取奇异值

% 绘制奇异值谱
figure(Name = "奇异值");
plot(singular_values, '-o');
title('奇异值谱');xlabel('分量索引');ylabel('奇异值');
grid on;


% 绘制前 6 个分量的时域图
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
figure(Name = " SSA 时域");
for i = 1:num_components
    subplot(num_components, 1, i);
    plot(diff_params.time_lin, ssa_components(i, :), 'b');
    title(['分量 ', num2str(i), ' 的时域信号']);
    xlabel('时间 (s)');
    ylabel('幅值');
    % xlim([0, T]);
    grid on;
end


figure(Name = "SSA 频域");

for i = 1:num_components
    component_signal_fft = fft(ssa_components(i, :));
    subplot(num_components, 1, i);
    plot(diff_params.freq_lin(1:show_points),abs(component_signal_fft(1:show_points)) , 'b');
    title(['分量 ', num2str(i), ' 的频谱']);
    xlabel('频率 f/hz');
    ylabel('幅值');
    % xlim([0, T]);
    grid on;
end



% 信号重构
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

% 平均化重构信号 归一化 ? 对角平均
ssa_reconstructed = ssa_reconstructed ./ (min(L, N - (0:N-1)) + min(L, (N-1-(0:N-1)) + 1));

% 显示重构信号
figure(Name = "信号重构");
subplot(2,1,1);
plot(diff_params.time_lin, f_input./max(f_input), 'b-', 'DisplayName', '滤波后信号');
hold on;
plot(diff_params.time_lin, ssa_reconstructed./max(ssa_reconstructed), 'r-', 'DisplayName', '重构信号 (SSA)');
title('滤波信号与重构信号 (SSA)');
xlabel('时间 (s)');
ylabel('归一化幅值');
legend('show');
grid on;

subplot(2,1,2);
ssa_reconstructed_fft = fft(ssa_reconstructed);
plot(diff_params.freq_lin(1:show_points), abs(f_input_fft(1:show_points))./max(abs(f_input_fft(1:show_points))), 'b-', 'DisplayName', '滤波信号频谱');
hold on;
plot(diff_params.freq_lin(1:show_points), abs(ssa_reconstructed_fft(1:show_points))./max(abs(ssa_reconstructed_fft(1:show_points))), 'r-', 'DisplayName', '重构信号频谱');
title('滤波信号与重构信号的频谱');
xlabel('频率 (Hz)');
ylabel('归一化幅值');
legend('show');
grid on;

% TODO: 呼吸谐波振幅因子判断


% SSA重构频谱一阶差
ssa_diff = [0, diff(ssa_reconstructed)];  % 一阶后向相差分（首元素补0以对齐长度）

% 计算差分信号的频谱
ssa_diff_fft = fft(ssa_diff);

% 绘制差分信号的时域与频域图
figure(Name = "一阶差分");

% 时域对比
subplot(2, 1, 1);
plot(diff_params.time_lin, ssa_reconstructed./max(ssa_reconstructed), 'b-', 'DisplayName', 'SSA重构信号');
hold on;
plot(diff_params.time_lin, ssa_diff ./ max(ssa_diff), 'r--', 'DisplayName', 'SSA信号一阶差分');
xlabel('时间 (s)');
ylabel('归一化幅值');
title('SSA重构信号与其一阶差分信号（时域）');
legend('show');
grid on;

% 频域对比
subplot(2, 1, 2);
plot(diff_params.freq_lin(1:show_points), abs(ssa_reconstructed_fft(1:show_points))./max(abs(ssa_reconstructed_fft(1:show_points))), 'b-', 'DisplayName', '重构信号频谱');
hold on;
plot(diff_params.freq_lin(1:show_points), abs(ssa_diff_fft(1:show_points))./max(abs(ssa_diff_fft(1:show_points))), 'r--', 'DisplayName', '一阶差分信号频谱');
xlabel('频率 (Hz)');
ylabel('归一化幅值');
title('SSA重构信号与其一阶差分信号的频谱');
legend('show');
grid on;


% VHPS 变分谐波谱乘积


f_vhps = ssa_diff;
f_vhps_fft = abs(fft(f_vhps));

vhps1 = upsample(f_vhps_fft,1);
vhps2 = upsample(f_vhps_fft,2);
vhps3 = upsample(f_vhps_fft,3);

vhps_output = [];
for i=1:length(vhps1)
    Product = vhps1(i)  * vhps2(i) * vhps3(i) ;
    % Product = vhps1(i)  * vhps3(i) ; % 只采用第三次谐波谱
    vhps_output(i) = [Product];
end

figure(Name = 'vhps upsample');
subplot(311);
plot(diff_params.freq_lin(1:show_points),abs(vhps1(1:show_points)));
title('vhps1 fft');
subplot(312);
plot(diff_params.freq_lin(1:show_points),abs(vhps2(1:show_points)));
title('vhps2 fft');
subplot(313);
plot(diff_params.freq_lin(1:show_points),abs(vhps3(1:show_points)));
title('vhps3 fft');

figure(Name = 'vhps output');   
plot(diff_params.freq_lin(1:show_points),abs(vhps_output(1:show_points)));




end
