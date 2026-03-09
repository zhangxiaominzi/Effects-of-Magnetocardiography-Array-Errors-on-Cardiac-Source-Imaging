% =========================================================================
% Case 3: Effects of Angular error and Position Error on Localisation 
%         Accuracy of Correlated Sources
% =========================================================================
clc;close all;clear all
tic

load MCG_LFM.mat
leadFieldSet = LF_angle;
% leadFieldSet = LF_pos;
leadField = leadFieldSet{1};
[numChannels, numSources] = size(leadField); 

% -------------------------------------------------------------------------
% Simulation settings
% -------------------------------------------------------------------------
numTrials = 500; % Monte-Carlo repetitions
numTimeSamples = 500; % time samples
signalPeak = 500;
numDipoles = 3; rng(4); % number of active sources
% numDipoles = 2; rng(400);
sourceCorr = 0.8; % inter-sources correlation
apMaxIters = 6; % AP maximal number of iterations
SNR = [0 5 10 15];
numSnrs = length(SNR);
errorLevels = [0,1,2,3,4,5];
numErrors = length(errorLevels);
trueSourceIdx = randi(numSources,numDipoles,numTrials); 
metricLE = zeros(numTrials,numSnrs,numErrors); 

% -------------------------------------------------------------------------
% Main loop
% -------------------------------------------------------------------------
for trialIdx = 1:numTrials
    fprintf('Trial %d / %d\n', trialIdx, numTrials);

    currTrueIdx = trueSourceIdx(:, trialIdx);

    for snrIdx = 1:numSnrs
        snrDb = SNR(snrIdx);

        for errIdx = 1:numErrors

            leadFieldError = leadFieldSet{errIdx};

            % Generate measurements
            sourceSignal = gen_correlated_sources(sourceCorr,numTimeSamples,numDipoles); 
            cleanSignal = leadField(:,currTrueIdx') * sourceSignal;  

            % Scaled
            scaleFactor = signalPeak / max(abs(cleanSignal(:)));
            scaledSignal = cleanSignal * scaleFactor;

            % Adding gaussian white noise
            signalPower = trace(scaledSignal*scaledSignal')/(numChannels*(numTimeSamples));
            noiseStd = sqrt(signalPower/(10^(snrDb/10)));
            noiseSignal = randn(numChannels,numTimeSamples).*noiseStd;
            mixedSignal = scaledSignal + noiseSignal; 
            
            % Inversion  
            [~,estSourceIdx] = alternating_projections(mixedSignal, numSources, leadFieldError, numDipoles, apMaxIters);
            
            % Performance metrics
            locAccuracy = zeros(numDipoles,1);
            tmpDist = zeros(numDipoles,1);
            for s = 1:numDipoles
                for n = 1:numDipoles
                    tmpDist(n)  = norm(diff(source.p([currTrueIdx(s) estSourceIdx(n)],:))); % distance in mm
                end
                locAccuracy(s) = min(tmpDist);             
            end

            metricLE(trialIdx,snrIdx,errIdx) = mean(locAccuracy); 
        end
    end
end

toc

