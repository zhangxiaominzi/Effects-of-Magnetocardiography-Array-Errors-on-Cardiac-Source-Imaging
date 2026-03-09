function [initSourceIdx, refinedSourceIdx] = alternating_projections(measData, numCandidates, leadField, numActiveSources, MaxIters)


[numChannels, ~] = size(leadField);

% ---------------------------------------------------------------------
% Covariance matrix with trace-based diagonal regularization
% ---------------------------------------------------------------------
regFactor = 1e-3;
dataCov = measData * measData';
dataCov = dataCov + regFactor * trace(dataCov) * eye(numChannels);

% ---------------------------------------------------------------------
% Phase 1: Sequential initialization
% ---------------------------------------------------------------------
initSourceIdx = zeros(1, numActiveSources);

% Step 1: find the first source over the full candidate set
candidateScore = zeros(numCandidates, 1);
for candIdx = 1:numCandidates
    lfVec = leadField(:,candIdx);
    candidateScore(candIdx) = (lfVec'*dataCov*lfVec) / (lfVec'*lfVec);
end
[~, bestIdx] = max(candidateScore); % obtain the 1st source location
initSourceIdx(1) = bestIdx;

% Step 2: sequentially add remaining sources
for srcIdx = 2:numActiveSources
    candidateScore = zeros(numCandidates,1);

    selectedLeadField = leadField(:, initSourceIdx(1:srcIdx-1));
    projMat = selectedLeadField * pinv(selectedLeadField'*selectedLeadField)*selectedLeadField';
    orthProjMat = eye(size(projMat,1)) - projMat;

    for candIdx = 1:numCandidates
        lfVec = leadField(:,candIdx);
        candidateScore(candIdx) = (lfVec'*orthProjMat*dataCov*orthProjMat*lfVec) / (lfVec'*orthProjMat*lfVec);
    end

    [~,bestIdx] = max(candidateScore);
    initSourceIdx(srcIdx) = bestIdx;
end

% ---------------------------------------------------------------------
% Phase 2: Alternating refinement
% ---------------------------------------------------------------------
refinedSourceIdx = initSourceIdx;

for iterIdx = 1:MaxIters
    prevSourceIdx = refinedSourceIdx;

    for srcIdx = 1:numActiveSources
        candidateScore = zeros(numCandidates,1);

        otherIdx = refinedSourceIdx;
        otherIdx(srcIdx) = [];

        selectedLeadField = leadField(:,otherIdx);
        projMat = selectedLeadField * pinv(selectedLeadField'*selectedLeadField)*selectedLeadField';
        orthProjMat = eye(size(projMat,1)) - projMat; 

        for candIdx = 1:numCandidates
            lfVec = leadField(:,candIdx);
            candidateScore(candIdx) = (lfVec'*orthProjMat*dataCov*orthProjMat*lfVec) / (lfVec'*orthProjMat*lfVec);
        end

        [~, bestIdx] = max(candidateScore);
        refinedSourceIdx(srcIdx) = bestIdx;
    end

    if iterIdx > 1 && isequal(refinedSourceIdx,prevSourceIdx)
        % No improvement vs. previous iteration
        break
    end
end