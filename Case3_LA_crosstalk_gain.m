% =========================================================================
% Case 3: Effects of Crosstalk and Gain Error on Localisation Accuracy of
%         Correlated Sources
% =========================================================================
clc;close all;clear all
tic

load MCG_LFM.mat
leadField = LF_pos{1};
[numChannels, numSources] = size(leadField);
sensorsPos = sensor.p; 

% -------------------------------------------------------------------------
% Simulation settings
% -------------------------------------------------------------------------
numTrials = 500; % Monte-Carlo repetitions
numTimeSamples = 500; 
signalPeak = 500;
numDipoles = 3; rng(4); % number of active sources
% numDipoles = 2; rng(400);
sourceCorr = 0.8; 
apMaxIters = 6; % AP maximal number of iterations
SNR = [0 5 10 15];
numSnrs = length(SNR);
crosstalkLevels = [0 0.01 0.02 0.03 0.04 0.05];
numErrors = length(crosstalkLevels);
% gainerrorLevels = [0 0.02 0.04 0.06 0.08 0.10];
% numErrors = length(gainerrorLevels);
trueSourceIdx = randi(numSources,numDipoles,numTrials); 
metricLE = zeros(numTrials,numSnrs,numErrors); % result_Case3_crosstalk_S3_corr8 = metricLE;

% -------------------------------------------------------------------------
% Main loop
% -------------------------------------------------------------------------
for trialIdx = 1:numTrials
    fprintf('Trial %d / %d\n', trialIdx, numTrials);

    currTrueIdx = trueSourceIdx(:, trialIdx);

    for snrIdx = 1:numSnrs 
        snrDb = SNR(snrIdx);

        for errIdx = 1:numErrors

            % Generate measurements
            sourceSignal = gen_correlated_sources(sourceCorr,numTimeSamples,numDipoles);
            cleanSignal = leadField(:,currTrueIdx') * sourceSignal;
            
            % Scaled
            scaleFactor = signalPeak / max(abs(cleanSignal(:)));
            scaledSignal = cleanSignal * scaleFactor;
            
            % Adding gaussian white noise
            signalPower = trace(scaledSignal*scaledSignal') / (numChannels*numTimeSamples);
            noiseStd = sqrt(signalPower / (10^(snrDb/10)));
            noiseSignal = randn(numChannels,numTimeSamples).*noiseStd;
            mixedSignal = scaledSignal + noiseSignal;

            % Adding error
            % mixedSignal = gain_error(mixedSignal, gainerrorLevels(errIdx));
            mixedSignal = crosstalk_error(mixedSignal,sensorsPos,crosstalkLevels(errIdx));

            % Inversion 
            [~,estSourceIdx] = alternating_projections(mixedSignal, numSources, leadField, numDipoles, apMaxIters); 
            
            % Performance metrics
            locAccuracy = zeros(numDipoles,1);
            tmpDist = zeros(numDipoles,1);
            for s = 1:numDipoles
                for n = 1:numDipoles
                    tmpDist(n) = norm(diff(source.p([currTrueIdx(s) estSourceIdx(n)],:))); % distance in mm
                end
                locAccuracy(s) = min(tmpDist);             
            end
            
            metricLE(trialIdx,snrIdx,errIdx) = mean(locAccuracy);
        end
    end
end
toc
