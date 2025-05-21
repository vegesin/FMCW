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
    xlabel('时间(s)', 'HorizontalAlignment', 'right');
end

imf_l = size(vmd_u,1);

% 使用 plot3 绘制 vmd 分解后的分量 - 时域
figure(Name=sprintf("VMD 三维时域"));

for i = 1:imf_l
    plot3(diff_params.time_lin,(i)*ones(size(vmd_u(i,:))),vmd_u(i,:), 'DisplayName', sprintf('IMF%d', i));
    hold on;
end

xlabel('时间(s)');
ylabel('IMF 分量');
yticks(1:imf_l + 1);
zlabel('幅度');
title('VMD 时域');
legend show;
grid on;
hold off;
view(3);



figure(Name="VMD 频域");
for i  = 1:vmd_K
    
    vmd_u_fft = fft(vmd_u(i,:));
    [peak_val,peak_index] = max(abs(vmd_u_fft));
    
    subplot(vmd_K,1,i);
    plot(diff_params.freq_lin(1:show_points),abs(vmd_u_fft(1:show_points)./peak_val ));
    xlabel('频率(Hz)','HorizontalAlignment', 'right');
    title(sprintf("VMD IMF%d频域",i));

    Predict_Matrix_VMD(i) = (peak_index-1) * (diff_params.fs / diff_params.n);
    fprintf("[my_vmd]vmd_imf %d freq: %.4f\n", i, Predict_Matrix_VMD(i));
end


% plot3 绘制频谱
figure(Name = 'VMD 3D 频谱');

for i = 1:imf_l
    vmd_imf_fft =  fft(vmd_u(i,:));
    % [peak_val,peak_index] = max(abs(vmd_imf_fft)); 
    %stem(diff_params.freq_lin,abs(vmd_imf_fft(1:diff_params.n)));
    plot3(diff_params.freq_lin(1:show_points),i*ones(1,show_points),abs(vmd_imf_fft(1:show_points)),'DisplayName', sprintf('IMF%d', i));
    hold on;
end
xlabel('频率(Hz)');
ylabel('IMF 分量');
yticks(1:imf_l + 1);
zlabel('幅度');
zticks([]);
% set(gca,'xticklabel',[])
title('VMD 频域');
legend show;
grid on;
hold off;
view(3);

end