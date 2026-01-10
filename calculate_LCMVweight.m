function [w,mu] = calculate_LCMVweight(L_j, Msnr, ratio)

% 
N_channels = size(Msnr, 1);
C = cov(Msnr');  % 
mu = ratio * trace(C) / N_channels;  
C_reg = C + mu * eye(N_channels);
w = (L_j' / C_reg * L_j) \ (L_j' / C_reg);

