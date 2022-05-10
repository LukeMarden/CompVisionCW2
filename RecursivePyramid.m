function histogram = RecursivePyramid(image, vocab, nonWeightedHistogram, currentLevel, maxLevel)
%RECURSIVEPYRAMID Summary of this function goes here
%   Detailed explanation goes here

%Calculate histogram intersection at this level

%histIntersection = sum(min(vocab, currentSIFT));
%histogramIntersection = (1 / (2^(maxLevel - currentLevel + 1))) * histIntersection; 


[locations, SIFT_features] = vl_dsift(image, 'fast','size', 64);
SIFT_features = SIFT_features';

closestFeat = -1;
closestFeatDist = -1;
localHistogram = zeros(size(vocab,1), 1);

% Get histogram at this level for how many times each word appears
for i = 1:size(SIFT_features,1)
    for j = 1:size(vocab,1)
        D = vl_alldist2(single(SIFT_features(i,:)), vocab(j,:));
        totalDistance = sum(sum(D), 2);
        if totalDistance < closestFeatDist || closestFeatDist == -1
            closestFeatDist = totalDistance;
            closestFeat = j;
        end
    end
    localHistogram(closestFeat,1) = localHistogram(closestFeat) + 1;
    closestFeat = -1;
    closestFeatDist = -1;
end

%Add this new histogram to the old one

nonWeightHist = nonWeightedHistogram + localHistogram;
localHistogram = nonWeightHist;

if currentLevel == maxLevel
    histogram = 0;
    %Unwind the recursion
else      
    histogram = RecursivePyramid(image(1:floor(end/2),1:floor(end/2)), vocab, nonWeightHist, currentLevel+1, maxLevel);
    histogram = histogram + RecursivePyramid(image(1:floor(end/2), ceil(end/2) + 1: end), vocab, nonWeightHist, currentLevel+1, maxLevel);
    histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, 1:floor(end/2)), vocab, nonWeightHist, currentLevel+1, maxLevel);
    histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, ceil(end/2) + 1:end), vocab, nonWeightHist, currentLevel+1, maxLevel);
end
histogram = histogram + ( (1 / (2^ (maxLevel-currentLevel+1) ) ) .* localHistogram);
%histogram = histogram + (1/(2*maxLevel));
end

