% 封装 VMD 调用VMD论文代码


function my_vmd(vmd_f,diff_params)

fprintf("\n\n-------------------------------- VMD --------------------------------\n");
show_points = 500;


% vmd 参数
% some sample parameters for VMD
vmd_alpha = 20000;       % moderate bandwidth constraint
vmd_tau = 0;            % noise-tolerance (no strict fidelity enforcement)
vmd_K = 7;              % modes
vmd_DC = 0;             % no DC part imposed
vmd_init = 0;           % initialize omegas uniformly
vmd_tol = 1e-7;

[vmd_u,vmd_u_hat,vmd_omega] = VMD(vmd_f,vmd_alpha,vmd_tau,vmd_K,vmd_DC,vmd_init,vmd_tol);


Predict_Matrix_VMD = zeros(1,vmd_K);
% vmd_omega,   vmd_u,         vmd_u_hat
% 82x3 double, 3x5000 double, 5000x3 complex double

figure(Name='VMD 时域');
for i  = 1:vmd_K
    subplot(vmd_K,1,i);
    plot(diff_params.time_lin,vmd_u(i,:));
    title(sprintf("VMD IMF%d时域",i));
    xlabel('时间 t/s', 'HorizontalAlignment', 'right');
end

figure(Name="VMD 频域");
for i  = 1:vmd_K
    
    vmd_u_fft = fft(vmd_u(i,:));
    [peak_val,peak_index] = max(abs(vmd_u_fft));
    
    subplot(vmd_K,1,i);
    plot(diff_params.freq_lin(1:show_points),abs(vmd_u_fft(1:show_points)./peak_val ));
    xlabel('频率 f/Hz','HorizontalAlignment', 'right');
    title(sprintf("VMD IMF%d频域",i));

    Predict_Matrix_VMD(i) = (peak_index-1) * (diff_params.fs / diff_params.n);
    fprintf("[my_vmd]vmd_imf %d freq: %.4f\n", i, Predict_Matrix_VMD(i));
end

end