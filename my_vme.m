% 封装 VMD 调用VMD论文代码

% 封装 vme 变分模态提取
function my_vme(vme_f,diff_params)

fprintf("\n\n-------------------------------- VME --------------------------------\n");
show_points = 500;

% input parameters
vme_alpha = 20000; % Alpha- compactness of mode constraint
vme_tua = 0; % vme_tua- time-step of the dual ascent.
vme_tol = 1e-7; % vme_tol- tolerance of convergence criterion
vme_omega = 0.006;

fs = diff_params.fs;



% u       - the desired mode
% u_hatd  - spectra of the desired mode
% omega   - estimated mode center-frequency

[vme_u,vme_u_hat,vme_out_omega] = vme(vme_f,vme_alpha,vme_omega,fs,vme_tua,vme_tol); % vme_u_hat 是fftshift之后的

vme_u_fft = fft(vme_u);
[peak_val,peak_index] = max(abs(vme_u_fft));

figure(Name=sprintf("VME"));
subplot(211);
plot(diff_params.time_lin,vme_u);
title("VME 心跳信号时域");
xlabel('时间(s)','HorizontalAlignment', 'right');
% grid on ;

subplot(212);
plot(diff_params.freq_lin(1:show_points),abs(vme_u_fft(1:show_points)./ peak_val));
title("VME 心跳信号频域");
% grid on ;
xlabel('频率(Hz)','HorizontalAlignment', 'right');

vme_heart_freq = (peak_index-1) * (diff_params.fs / diff_params.n);
fprintf("[my_vme] vme heart freq: %.4f\n",vme_heart_freq);


    
end