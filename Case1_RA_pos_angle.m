% ===============================================================================
% Case 1: Effects of Angular error and Position Error on Reconstruction Accuracy
% ===============================================================================
clc;clear all;close all;
tic

load MCG_LFM.mat
% leadFieldSet = LF_pos; % 需要更换
leadFieldSet = LF_angle;
leadField = leadFieldSet{1};
[numChannels, numSources] = size(leadField);

% -------------------------------------------------------------------------
% Simulation settings
% -------------------------------------------------------------------------
numTimeSamples = 1000;
signalPeak = 500;
angerrorLevels = [0,1,2,3,4,5];
numErrors = length(angerrorLevels);
% poserrorLevels = [0,1,2,3,4,5];
% numErrors = length(poserrorLevels);
SNR = [5 10 15];
numSnrs = length(SNR);
pcc = zeros(numSources, numSnrs, numErrors);
rmse = zeros(numSources, numSnrs, numErrors);

% -------------------------------------------------------------------------
% Main loop
% -------------------------------------------------------------------------
for errIdx = 1:numErrors
    fprintf('Error level %d / %d ...\n', errIdx, numErrors);
    
    leadFieldError = leadFieldSet{errIdx};

    for snrIdx = 1:numSnrs
        snrDb = SNR(snrIdx);

        for sourceIdx = 1:numSources

            % Generate measurements
            sourceSignal = randn(1, numTimeSamples).* sqrt(2);
            cleanSignal = leadField(:, sourceIdx) * sourceSignal; 

            % Scaled
            scaleFactor = signalPeak / max(abs(cleanSignal(:)));
            scaledSignal = cleanSignal * scaleFactor;

            % Adding gaussian white noise
            signalPower = trace(scaledSignal*scaledSignal') / (numChannels*numTimeSamples);
            noiseStd = sqrt(signalPower / (10^(snrDb/10)));
            noiseSignal = randn(numChannels, numTimeSamples).*noiseStd;
            mixedSignal = scaledSignal + noiseSignal;
            
            % Inversion
            weight = calculate_LCMVweight(leadFieldError(:,sourceIdx), mixedSignal, 0.001);
            
            % Reconstruct source time course
            reconSignal = weight * mixedSignal;

            % Performance metrics
            [pcc(sourceIdx, snrIdx, errIdx),rmse(sourceIdx, snrIdx, errIdx)] = calculate_pcc_rmse(sourceSignal, reconSignal);
        end
    end
end
toc