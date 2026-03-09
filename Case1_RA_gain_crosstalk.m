% =========================================================================
% Case 1: Effects of Crosstalk and Gain Error on Reconstruction Accuracy
% =========================================================================
clc;clear all;close all;
tic

load MCG_LFM.mat
leadField = LF_pos{1};  % error-free leadField
[numChannels, numSources] = size(leadField);
sensorPos  = sensor.p; 

% -------------------------------------------------------------------------
% Simulation settings
% -------------------------------------------------------------------------
numTimeSamples = 1000; 
signalPeak = 500;
gainerrorLevels = [0 0.01 0.02 0.03 0.04 0.05];
numErrors = length(gainerrorLevels);
% crosstalkLevels = [0 0.01 0.02 0.03 0.04 0.05];
% numErrors = length(crosstalkLevels);
SNR = [5 10 15];
numSnrs = numel(SNR);
pcc = zeros(numSources, numSnrs, numErrors);
rmse = zeros(numSources, numSnrs, numErrors);

% -------------------------------------------------------------------------
% Main loop
% -------------------------------------------------------------------------
for sourceIdx = 1: numSources
    fprintf('Processing source %d / %d ...\n', sourceIdx, numSources);   

    leadFieldVec = leadField(:, sourceIdx);

    for snrIdx = 1:numSnrs
        snrDb = SNR(snrIdx);

        for errIdx = 1: numErrors

            % Generate measurements
            sourceSignal = randn(1, numTimeSamples).* sqrt(2);
            cleanSignal = leadFieldVec * sourceSignal;

            % Scaled
            scaleFactor = signalPeak / max(abs(cleanSignal(:)));
            scaledSignal = cleanSignal * scaleFactor;

            % Adding gaussian white noise
            signalPower = trace(scaledSignal*scaledSignal') / (numChannels*numTimeSamples);
            noiseStd = sqrt(signalPower / (10^(snrDb/10)));
            noiseSignal = noiseStd * randn(numChannels, numTimeSamples);
            mixedSignal = scaledSignal + noiseSignal;
    
            % Adding error
            mixedSignal = gain_error(mixedSignal,gainerrorLevels(errIdx));
            % mixedSignal = crosstalk_error(mixedSignal,sensorPos,crosstalkLevels(errIdx));
    
            % Inversion
            weight = calculate_LCMVweight(leadFieldVec, mixedSignal, 0.001); 
                
            % Reconstruct source time course
            reconSignal = weight * mixedSignal;

            % Performance metrics
            [pcc(sourceIdx, snrIdx, errIdx),rmse(sourceIdx, snrIdx, errIdx)] = calculate_pcc_rmse(sourceSignal, reconSignal);
        end
    end
end

toc
