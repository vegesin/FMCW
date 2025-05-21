
% 封装在子函数里面处理EMD


function  my_emd(f_input,diff_params)

fprintf("\n\n-------------------------------- EMD --------------------------------\n");

emd_f = f_input;
show_points = 500;

[emd_imf,emd_residual,emd_info] = emd(emd_f,'Interpolation','pchip');

% IMF
% 时域图像绘制
figure(Name=sprintf("EMD 时域"));

[imf_r, imf_l] = size(emd_imf); % 获得内涵模态分量IMF尺度信息
for i = 1:imf_l
    subplot(imf_l,1,i);
    plot(diff_params.time_lin,emd_imf(:,i));
    xlabel('时间 t/s','HorizontalAlignment', 'right');
    title(sprintf("EMD IMF%d时域",i));
end

% 频域图像绘制
figure(Name=sprintf("EMD 频域"));

Predict_Matrix_EMD = zeros(1,imf_l);    % 初始化预测矩阵，用来保存可能为所求的频率
% CorrC_EMD = zeros(1,imf_l);             % 初始化相关系数矩阵

for i = 1:imf_l
    emd_imf_fft =  fft(emd_imf(:,i));
    [peak_val,peak_index] = max(abs(emd_imf_fft)); 
    
    subplot(imf_l,1,i); 
    %stem(diff_params.freq_lin,abs(emd_imf_fft(1:diff_params.n)));
    plot(diff_params.freq_lin(1:show_points),abs(emd_imf_fft(1:show_points)./peak_val));
    xlabel('频率 f/Hz','HorizontalAlignment', 'right');
    title(sprintf("EMD IMF%d频域",i));
    
    
    Predict_Matrix_EMD(i) = (peak_index-1) * (diff_params.fs / diff_params.n);
    fprintf("[my_emd] emd_imf %d freq: %.4f\n", i, Predict_Matrix_EMD(i));
    
    % 计算每一个IMF和原始数据 Process_emd_heart的相关系数，使用corr函数？ 进行信号筛选，设定阈值
    % CorrC_EMD(i) = corr(emd_imf(:,i),emd_f,'type','Pearson'); % 计算皮尔逊线性相关系数(默认)
    % fprintf("[my_emd] emd_imf %d corrC: %.4f\n", i, CorrC_EMD(i));
end

% 使用 plot3 绘制 EMD 分解后的分量 - 时域
figure(Name=sprintf("EMD 三维时域"));

for i = 1:imf_l
    plot3(diff_params.time_lin,(i)*ones(size(emd_imf(:,i))),emd_imf(:,i), 'DisplayName', sprintf('IMF%d', i));
    hold on;
end

xlabel('时间(s)');
ylabel('IMF 分量');
yticks(1:imf_l + 1);
zlabel('幅值');
legend show;
title('EMD 时域');
grid on;
hold off;
view(3);

% plot3 绘制频谱
figure(Name = 'EMD 3D 频谱');

for i = 1:imf_l
    emd_imf_fft =  fft(emd_imf(:,i));
    % [peak_val,peak_index] = max(abs(emd_imf_fft)); 
    %stem(diff_params.freq_lin,abs(emd_imf_fft(1:diff_params.n)));
    plot3(diff_params.freq_lin(1:show_points),i*ones(1,show_points),abs(emd_imf_fft(1:show_points)),'DisplayName', sprintf('IMF%d', i));
    hold on;
end
xlabel('频率(Hz)');
ylabel('IMF 分量');
yticks(1:imf_l + 1);
zlabel('幅值');
zticks([]);
% set(gca,'xticklabel',[])
title('EMD 频域');
legend show;
grid on;
hold off;
view(3);




% IMF 筛选


% 呼吸频率范围 0.1-0.5Hz；心跳范围：0.8-2Hz

% 获得可能的呼吸频率
Predict_Breathe_EMD = Predict_Matrix_EMD(Predict_Matrix_EMD>=0.1 & Predict_Matrix_EMD <= 0.5);
Predict_Breathe_EMD = unique(Predict_Breathe_EMD);     % 去除重复元素
% 获得可能的心跳频率
Predict_HeartBeat_EMD = Predict_Matrix_EMD(Predict_Matrix_EMD>=0.8 & Predict_Matrix_EMD <=2);
Predict_HeartBeat_EMD = unique(Predict_HeartBeat_EMD); % 去除重复元素

% 呼吸、心跳信号的预测
fprintf("EMD分解模型：\n可能的心跳频率为：")
for i = 1:length(Predict_HeartBeat_EMD)
    fprintf("%.3fHz ",Predict_HeartBeat_EMD(i))
end
fprintf("\n可能的呼吸频率为：")
for i = 1:length(Predict_Breathe_EMD)
    fprintf("%.3fHz ",Predict_Breathe_EMD(i))
end
fprintf("\n")


% % 通过互相关性确定可能的心跳频率
% Predict_Amend = Predict_Matrix_EMD(CorrC_EMD >= 0.6); % 假定相关程度 70% 为呼吸频率
% Predict_Amend = unique(Predict_Amend); % 去除重复频率
% fprintf("通过互相关值猜测的心跳频率为：%.3fHz\n",Predict_Amend);



end