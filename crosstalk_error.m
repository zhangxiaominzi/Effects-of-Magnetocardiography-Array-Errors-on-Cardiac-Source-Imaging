function dataOut = crosstalk_error(dataIn,sensorPos,crosstalkLevel)

% -------------------------------------------------------------------------
% Add crosstalk to the MCG data
% -------------------------------------------------------------------------
if crosstalkLevel == 0
    dataOut = dataIn;
else
% -------------------------------------------------------------------------
% Creat the crosstalk matrix
% -------------------------------------------------------------------------
% obtain the distance between the sensors
    numChannels = size(sensorPos,1);
    distance = zeros(numChannels);
    for i = 1:numChannels
        for j = 1:numChannels
            if(i == j)
                distance(i,j) = 50;
            else
                distance(i,j) = norm(sensorPos(i,:)-sensorPos(j,:));
            end        
        end
    end
    distanceMin = min(distance,[],'all'); 
    scale = (distanceMin./distance).^3; % set the crosstalk is inversely proportional to the cube of distance
    scale = scale.*crosstalkLevel; 
    scale(logical(eye(size(scale)))) = 1; % set the diagonal velue of scale to be 1

    tmp = zeros(size(dataIn));
    for t = 1:size(dataIn,2)
        for i = 1:numChannels       
              tmp(i,t) = scale(i,1:numChannels)*dataIn(1:numChannels,t);     
        end 
    end
    dataOut = tmp;
end



