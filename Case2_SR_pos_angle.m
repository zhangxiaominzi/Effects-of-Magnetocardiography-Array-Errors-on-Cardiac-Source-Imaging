% ==========================================================================
% Case 2: Effects of Angular error and Position Error on Spatial Resolution
% ==========================================================================
clc;clear all;close all;
tic

load MCG_pair.mat  % source pairs
load MCG_LFM.mat
% leadFieldSet = LF_pos;  
leadFieldSet = LF_angle;
leadField = leadFieldSet{1};
[numChannels, ~] = size(leadField);

% -------------------------------------------------------------------------
% Simulation settings
% -------------------------------------------------------------------------
sourcePair = pair8';
numPairs = size(sourcePair, 2); 
numDipoles = 2;
numTimeSamples = 1000;
signalPeak = 500;
% angerrorLevels = [0,1,2,3,4,5];
% numErrors = length(angerrorLevels);
poserrorLevels = [0,1,2,3,4,5];
numErrors = length(poserrorLevels);
SNR = [10 15 20];
numSnrs = length(SNR);
pcc = zeros(numPairs, numSnrs, numErrors);

% -------------------------------------------------------------------------
% Main loop
% -------------------------------------------------------------------------
for errIdx = 1:numErrors
    fprintf('Error level %d / %d ...\n', errIdx, numErrors);

    leadFieldError = leadFieldSet{errIdx};

    for snrIdx = 1:numSnrs
        snrDb = SNR(snrIdx);

        for pairIdx = 1:numPairs

            % Generate measurements
            sourceSignal = randn(numDipoles, numTimeSamples).* sqrt(2);
            cleanSignal = leadField(:, sourcePair(:,pairIdx)) * sourceSignal; 

            % Scaled
            scaleFactor = signalPeak / max(abs(cleanSignal(:)));
            scaledSignal = cleanSignal*scaleFactor;

            % Adding gaussian white noise
            signalPower = trace(scaledSignal*scaledSignal') / (numChannels*numTimeSamples);
            noiseStd = sqrt(signalPower / (10^(snrDb/10)));
            noiseSignal = randn(numChannels, numTimeSamples).*noiseStd;
            mixedSignal = scaledSignal + noiseSignal;
            
            % Inversion
            weight = calculate_LCMVweight(leadFieldError(:,sourcePair(:,pairIdx)), mixedSignal, 0.001);% 含误差的LFM
                
            % Reconstruct source time course
            reconSignal = weight * mixedSignal; 

            % Performance metrics
            pcc(pairIdx, snrIdx, errIdx) = calculate_PCC_RED(reconSignal(1,:), reconSignal(2,:));
        end
    end
end
toc
