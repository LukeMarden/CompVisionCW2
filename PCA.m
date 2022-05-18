function reducedVector = PCA(features, curentCompressNo, maxCompressNo)
%PCA Reduce dimensionality of the data
%   Recursively reduces the dimensionality of data using PCA
odd = false;
reducedVector = 0;
% Split the data differently if it is odd or even, with split ignoreing the
% last value
if mod(size(features,1),2) == 0
    endIndex = size(features,1);
    reducedVector = zeros(endIndex/2, size(features,2));
else
    endIndex = size(features,1) -1;
    reducedVector = zeros((endIndex/2) + 1, size(features,2));
    odd = true;
end
% Calculate mean of data, angle of mean and axis, rotate all points by
% angle around origin
for i = 1:endIndex/2
    x = (i*2) - 1;
    y = i*2;
    meanX = mean(features(x,:));
    meanY = mean(features(y,:));

    %Angle between mean and x axis
    angle = atan(meanY / meanX);    
    rotatedWithIndex = zeros(size(features,1) + 1, size(features,2));
    rotatedWithIndex(end,:) = 1:size(features,2);
    rotatedWithIndex(1:end-1, :) = features;
    
    % Translate points to be around the origin then rotate and translate
    % back
    rotatedWithIndex(x,:) = rotatedWithIndex(x,:) - meanX;
    rotatedWithIndex(y,:) = rotatedWithIndex(y,:) - meanY;
    %Rotate
    currentX = rotatedWithIndex(x,:);
    currentY = rotatedWithIndex(y,:);
    rotatedWithIndex(x,:) = ( currentX .* cos(angle) ) - ( currentY .* sin(angle) );
    rotatedWithIndex(y,:) = ( currentX .* sin(angle) ) + ( currentY .* cos(angle) );
    %Translate back
    rotatedWithIndex(x,:) = rotatedWithIndex(x,:) + meanX;
    rotatedWithIndex(y,:) = rotatedWithIndex(y,:) + meanY;
    %Use x values to reduce dimensionality of data
    reducedVector(i,:) = rotatedWithIndex(x,:);
    if odd == true
        reducedVector(end, :) = features(end,:);
    end
    
end
%Recursively
currentCompressNo = curentCompressNo + 1;
if currentCompressNo ~= maxCompressNo
    reducedVector = PCA(reducedVector, currentCompressNo, maxCompressNo);
end



