function histogram = RecursivePyramid(image, vocab, nonWeightedHistogram, currentLevel, maxLevel)
%RECURSIVEPYRAMID Summary of this function goes here
%   Detailed explanation goes here

%Calculate histogram intersection at this level

%histIntersection = sum(min(vocab, currentSIFT));
%histogramIntersection = (1 / (2^(maxLevel - currentLevel + 1))) * histIntersection; 


[locations, SIFT_features] = vl_dsift(image, 'fast','size', 16);
%SIFT_features = SIFT_features';
localVocab = vocab';
localHistogram = zeros(size(vocab,1), 1);

% Get histogram at this level for how many times each word appears
D2 = zeros(size(SIFT_features,2), size(localVocab,2));
for j = 1:size(SIFT_features,2)
    for k = 1:size(localVocab,2)
        for l = 1:size(SIFT_features,1)
            D2(j,k) = D2(j,k) + abs(single(SIFT_features(l,j)) - single(localVocab(l,k)));
        end
    end
end
    
for j = 1:size(D2,1)
    closestFeat = -1;
    closestFeatDist = -1;
    for k = 1:size(D2,2)
        if D2(j,k) < closestFeatDist || closestFeatDist == -1
            closestFeat = k;
            closestFeatDist = D2(j,k);
        end
    end
    localHistogram(closestFeat) = localHistogram(closestFeat) + 1;
end

%Histogram intersection sum - calculate intersection of this histogram with
%parent histogram
%if currentLevel ~= 0 && ~(isempty(SIFT_features))
    %disp("Hi");
%end
if currentLevel ~= 0
    nonWeightHist = min(localHistogram,nonWeightedHistogram);
else
    nonWeightHist = localHistogram;
end
localHistogram = nonWeightHist;
histogram = ( (1 / (2^ (maxLevel-currentLevel+1) ) ) .* localHistogram);


%Add this new histogram to the old one
%nonWeightHist = nonWeightedHistogram + localHistogram;
%localHistogram = nonWeightHist;
%histogram = ( (1 / (2^ (maxLevel-currentLevel+1) ) ) .* localHistogram);

if currentLevel == maxLevel
    %histogram = 0;
    %Unwind the recursion
else      
    histogram = histogram + RecursivePyramid(image(1:floor(end/2),1:floor(end/2)), vocab, nonWeightHist, currentLevel+1, maxLevel);
    histogram = histogram + RecursivePyramid(image(1:floor(end/2), ceil(end/2) + 1: end), vocab, nonWeightHist, currentLevel+1, maxLevel);
    histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, 1:floor(end/2)), vocab, nonWeightHist, currentLevel+1, maxLevel);
    histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, ceil(end/2) + 1:end), vocab, nonWeightHist, currentLevel+1, maxLevel);
end
%histogram = histogram + (1/(2*maxLevel));
end


% for i = 1:size(SIFT_features,1)
%     for j = 1:size(vocab,1)
%         %D = vl_alldist2(single(SIFT_features(i,:)), vocab(j,:));
%         
%         totalDistance = sum(sum(D), 2);
%         if totalDistance < closestFeatDist || closestFeatDist == -1
%             closestFeatDist = totalDistance;
%             closestFeat = j;
%         end
%     end
%     localHistogram(closestFeat,1) = localHistogram(closestFeat) + 1;
%     closestFeat = -1;
%     closestFeatDist = -1;
% end

