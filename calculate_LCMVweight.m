function [w,mu] = calculate_LCMVweight(L_j, Msnr, ratio)

% 使用LCMV求逆：单一波束形成器
N_channels = size(Msnr, 1);
C = cov(Msnr');  % 计算数据的协方差矩阵
mu = ratio * trace(C) / N_channels;  
C_reg = C + mu * eye(N_channels);
w = (L_j' / C_reg * L_j) \ (L_j' / C_reg);

