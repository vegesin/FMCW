


function [components, reconstructed] = ssa(x, L,diff_params)
    % SSA 奇异谱分析 (优化内存版)
    % 输入参数：
    %   x: 输入时间序列（列向量）
    %   L: 窗口长度
    % 输出参数：
    %   components: 前6个主成分的轨迹矩阵（cell数组）
    %   reconstructed: 前6个主成分重构序列（cell数组）
    
    x = x(:); % 转换为列向量
    N = length(x);
    if L > N/2
        warning('窗口长度L通常应小于N/2');
    end
    
    % 轨迹矩阵构造（标准SSA：L行×K列，K=N-L+1）
    K = N - L + 1;
    X = zeros(L, K);
    for i = 1:K
        X(:, i) = x(i:i+L-1);
    end
    
    % SVD分解
    [U, S, V] = svd(X, 'econ');
    sigma = diag(S);
    
    % 自动确定有效成分数量（前6个或实际有效秩）
    num_components = min(6, sum(sigma > eps(norm(sigma)))); % 关键优化点
    
    % 预分配内存
    components = cell(num_components, 1);
    reconstructed = cell(num_components, 1);
    
    % 仅处理前6个主成分
    for i = 1:num_components
        % 使用矩阵外积优化内存
        X_comp = sigma(i) * (U(:,i) * V(:,i)');
        components{i} = X_comp;
        reconstructed{i} = anti_diagonal_averaging(X_comp);
    end
    
    % 优化绘图内存
    plot_ssa_results(x, reconstructed, L, num_components,diff_params);
    end
    
    % 反对角平均函数（优化版）
    function y = anti_diagonal_averaging(X)
        [L, K] = size(X);
        N = L + K - 1;
        y = zeros(N, 1);
        count = zeros(N, 1);
        
        % 向量化计算提升效率
        for n = 1:N
            [i_range, j_range] = get_anti_diag_indices(n, L, K);
            y(n) = mean(X(sub2ind([L,K], i_range, j_range)));
        end
    end
    
    % 获取反对角索引
    function [i_idx, j_idx] = get_anti_diag_indices(n, L, K)
        i_min = max(1, n-K+1);
        i_max = min(L, n);
        i_idx = i_min:i_max;
        j_idx = n - i_idx + 1;
    end
    
    % 绘图函数（优化内存）
    function plot_ssa_results(original, reconstructed, L, num_comp,diff_params)
        % 合并前num_comp个成分
        Y_recon = sum(cell2mat(reconstructed'), 2);
        
        figure('Name', ['SSA分析 (L=' num2str(L) ', 成分数=' num2str(num_comp) ')'],...
                'Position', [100 100 1000 800], 'Color', 'w');
        
        % 时域对比
        subplot(3,1,1);
        plot(original, 'b-o', 'LineWidth', 1.5, 'MarkerSize', 4);
        hold on;
        plot(Y_recon, 'r--s', 'LineWidth', 1.5, 'MarkerSize', 4);
        legend('原始信号', ['重构(' num2str(num_comp) '成分)']);
        title('时域对比'), grid on;
        
        % % 频域对比
        % Fs = 1; 
        % N = length(original);
        % f = (0:N-1)*(Fs/N);
        
        % subplot(3,1,2)
        % [P_orig, f_orig] = calc_psd(original, Fs);
        % [P_recon, f_recon] = calc_psd(Y_recon, Fs);
        % semilogy(f_orig, P_orig, 'b', 'LineWidth', 1.5)
        % hold on
        % semilogy(f_recon, P_recon, 'r--', 'LineWidth', 1.5)
        % xlim([0 0.5]), legend('原始信号', '重构信号')
        % title('功率谱密度对比'), grid on

        show_points = 500;
        original_fft = fft(original);
        reconstructed_fft = fft(Y_recon);
        subplot(3,1,2);
        plot(diff_params.freq_lin(1:show_points), abs(original_fft(1:show_points))./max(abs(original_fft(1:show_points))), 'b-', 'DisplayName', '滤波信号频谱');
        hold on;
        plot(diff_params.freq_lin(1:show_points), abs(reconstructed_fft(1:show_points))./max(abs(reconstructed_fft(1:show_points))), 'r-', 'DisplayName', '重构信号频谱');
        title('滤波信号与重构信号的频谱');
        xlabel('频率 (Hz)');
        ylabel('归一化幅值');
        legend('show');
        grid on;
        
        % 残差分析
        subplot(3,1,3)
        residual = original - Y_recon;
        plot(residual, 'k-*', 'LineWidth', 1.5)
        title(['重构残差 (MAE=' num2str(mean(abs(residual)), '%.2e') ')'])
        grid on
    end
    
    % % 功率谱计算函数
    % function [Pxx, f] = calc_psd(x, Fs)
    %     N = length(x);
    %     win = hamming(N);
    %     [Pxx, f] = periodogram(x, win, N, Fs);
    % end