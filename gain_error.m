function dataOut = gain_error(dataIn,gainerrorLevel)

% -------------------------------------------------------------------------
% Add gain error to the MCG data
% -------------------------------------------------------------------------
if gainerrorLevel == 0
    dataOut = dataIn;
else
    for i = 1:size(dataIn,1) 
      tmp = 1 + (2 * rand(1) - 1) * gainerrorLevel; 
        for j = 1:size(dataIn,2) 
            dataOut(i,j) = dataIn(i,j) * tmp;
        end
    end
end
