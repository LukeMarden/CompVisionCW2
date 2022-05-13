function reducedVector = PCA(features)
%PCA Reduce dimensionality of the data
%   Recursively reduces the dimensionality of data using PCA
if mod(size(features,1),2) == 0
    endIndex = size(features,1);
else
    endIndex = size(features,1) -1;
end
for i = 1:endIndex/2
    x = (i*2) - 1;
    y = i*2;
    meanX = mean(features(x,:));
    meanY = mean(features(y,:));
    minusMeanX = features(x,:) - meanX;
    minusMeanY = features(y,:) - meanY;
    slope = (sum (minusMeanX .* minusMeanY)) / (sum(minusMeanX .* minusMeanX));
    yIntercept = meanY - (slope .* meanX);
    disp("Line of best fit is");
    text = "Y = ";
    text2 = "x + ";
    disp(text + slope + text2 + yIntercept);
    % Get orthagonal line
    orthSlope = (-1 / slope);
    yInterceptOrth = meanY - ( orthSlope .* meanX );
    disp("Orthagonal line is");
    disp(text + orthSlope + text2 + yInterceptOrth);
    angle = atan(meanY / meanX);
    % Translate points to be around the origin then rotate and translate
    % back
    features(x,:) = features(x,:) - meanX;
    features(y,:) = features(y,:) - meanY;
    %Rotate
    currentX = features(x,:);
    currentY = features(y,:);
    features(x,:) = ( currentX .* cos(angle) ) - ( currentY .* sin(angle) );
    features(y,:) = ( currentX .* sin(angle) ) + ( currentY .* cos(angle) );
    %Translate back
    features(x,:) = features(x,:) + meanX;
    features(y,:) = features(y,:) + meanY;
end
reducedVector = 0;

