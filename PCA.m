function reducedVector = PCA(features, curentCompressNo, maxCompressNo)
%PCA Reduce dimensionality of the data
%   Recursively reduces the dimensionality of data using PCA
odd = false;
reducedVector = 0;
if mod(size(features,1),2) == 0
    endIndex = size(features,1);
    reducedVector = zeros(endIndex/2, size(features,2));
else
    endIndex = size(features,1) -1;
    reducedVector = zeros((endIndex/2) + 1, size(features,2));
    odd = true;
end
%reducedVector = zeros(endIndex/2, size(features,2));
for i = 1:endIndex/2
    x = (i*2) - 1;
    y = i*2;
    meanX = mean(features(x,:));
    meanY = mean(features(y,:));
%     minusMeanX = features(x,:) - meanX;
%     minusMeanY = features(y,:) - meanY;
%     slope = (sum (minusMeanX .* minusMeanY)) / (sum(minusMeanX .* minusMeanX));
%     yIntercept = meanY - (slope .* meanX);


%     Cartesian line of best fit
%     pointY = (slope * -50) + yIntercept;
%     pointY2 = (slope * 50) + yIntercept;
%     line = [pointY -50; pointY2 50];
%     scatter(features(x,:), features(y,:));
%     hold on
%     plot(line(:,2), line(:,1));
%     hold off
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
    
%     line2 = [min(features(x,:)) meanX max(features(x,:)); meanY meanY meanY];
%     
%     scatter(features(x,:), features(y,:));
%     hold on
%     plot(line2(1,:), line2(2,:));
%     hold off
end
currentCompressNo = curentCompressNo + 1;
if currentCompressNo ~= maxCompressNo
    reducedVector = PCA(reducedVector, currentCompressNo, maxCompressNo);
end


    % Get orthagonal line
%     orthSlope = (-1 / slope);
%     yInterceptOrth = meanY - ( orthSlope .* meanX );
%     disp("Orthagonal line is");
%     disp(text + orthSlope + text2 + yInterceptOrth);

%     disp("Line of best fit is");
%     text = "Y = ";
%     text2 = "x + ";
%     disp(text + slope + text2 + yIntercept);



