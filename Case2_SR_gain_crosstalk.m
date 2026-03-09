% =========================================================================
% Case 2: Effects of Crosstalk and Gain Error on Spatial Resolution
% =========================================================================
clc;clear all;close all;
tic

load MCG_pair.mat
load MCG_LFM.mat 
leadField = LF_pos{1};
[numChannels, ~] = size(leadField);
sensorPos = sensor.p;  

% -------------------------------------------------------------------------
% Simulation settings
% -------------------------------------------------------------------------
sourcePair = pair8';
numPairs = size(sourcePair, 2);
numDipoles = 2;
numTimeSamples = 1000;
signalPeak = 500;
% gainerrorLevels = [0 0.01 0.02 0.03 0.04 0.05];
% numErrors = length(gainerrorLevels);
crosstalkLevels  = [0 0.01 0.02 0.03 0.04 0.05];
numErrors = length(crosstalkLevels);
SNR = [10 15 20];
numSnrs = length(SNR);
pcc = zeros(numPairs, numSnrs, numErrors);

% -------------------------------------------------------------------------
% Main loop
% -------------------------------------------------------------------------
for pairIdx = 1: numPairs     
    fprintf('Processing source pair %d / %d ...\n', pairIdx, numPairs);
    
    leadFieldVec = leadField(:, sourcePair(:,pairIdx));

    for snrIdx = 1:numSnrs
        snrDb = SNR(snrIdx);

        for errIdx = 1: numErrors

            % Generate measurements
            sourceSignal = randn(numDipoles, numTimeSamples).* sqrt(2);
            cleanSignal =  leadFieldVec * sourceSignal;
            
            % Scaled
            scaleFactor = signalPeak / max(abs(cleanSignal(:)));
            scaledSignal = cleanSignal*scaleFactor;

            % Adding gaussian white noise
            signalPower = trace(scaledSignal*scaledSignal') / (numChannels*numTimeSamples);
            noiseStd = sqrt(signalPower / (10^(snrDb/10)));
            noiseSignal = randn(numChannels, numTimeSamples).*noiseStd;
            mixedSignal = scaledSignal + noiseSignal;
    
            % Adding error
            % mixedSignal = gain_error(mixedSignal,gainerrorLevels(errIdx));
            mixedSignal = crosstalk_error(mixedSignal,sensorPos,crosstalkLevels(errIdx));
    
            % Inversion
            weight = calculate_LCMVweight(leadFieldVec, mixedSignal, 0.001);  
                
            % Reconstruct source time course
            reconSignal = weight * mixedSignal;

            % Performance metrics
            pcc(pairIdx, snrIdx, errIdx) = calculate_PCC_RED(reconSignal(1,:),reconSignal(2,:));
        end
    end
end

toc


