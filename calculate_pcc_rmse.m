function [PCC, RMSE] = calculate_pcc_rmse(trueSignal, reconSignal)


if ~isequal(size(trueSignal), size(reconSignal))
    error('trueSignal and reconSignal must have the same size.');
end

% -------------------------------------------------------------------------
% Calculate the correlation coefficient
% -------------------------------------------------------------------------
pcc = corrcoef(trueSignal,reconSignal);
PCC = pcc(1,2);

% -------------------------------------------------------------------------
% Calculate the relative mean squared error
% -------------------------------------------------------------------------
epsVal = 1e-12;


trueRowNorm  = sqrt(sum(trueSignal.^2, 2)) + epsVal;
reconRowNorm = sqrt(sum(reconSignal.^2, 2)) + epsVal;

trueNormed  = trueSignal  ./ trueRowNorm;
reconNormed = reconSignal ./ reconRowNorm;

RMSE = (norm((trueNormed - reconNormed),2) / norm(trueNormed,2))^2;


