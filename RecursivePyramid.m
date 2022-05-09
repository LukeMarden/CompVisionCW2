function histogramIntersection = RecursivePyramid(image, vocab, currentSIFT, currentLevel, maxLevel)
%RECURSIVEPYRAMID Summary of this function goes here
%   Detailed explanation goes here

%Calculate histogram intersection at this level
histogramIntersection = 0;

histIntersection = sum(min(vocab, currentSIFT));
histogramIntersection = (1 / (2^(maxLevel - currentLevel + 1))) * histIntersection; 


if currentLevel == maxLevel
    %Unwind the recursion
else
    histogramIntersection = histogramIntersection + RecursivePyramid(image(1:floor(end/2),1:floor(end/2)), vocab, currentSIFT, currentLevel+1, maxLevel);
    histogramIntersection = histogramIntersection + RecursivePyramid(image(1:floor(end/2), ceil(end/2) + 1: end), vocab, currentSIFT, currentLevel+1, maxLevel);
    histogramIntersection = histogramIntersection + RecursivePyramid(image(ceil(end/2) + 1:end, 1:floor(end/2)), vocab, currentSIFT, currentLevel+1, maxLevel);
    histogramIntersection = histogramIntersection + RecursivePyramid(image(ceil(end/2) + 1:end, ceil(end/2) + 1:end), vocab, currentSIFT, currentLevel+1, maxLevel);
    %Call this function on the 4 sub areas
end
histogramIntersection = histogramIntersection + (1/(2*maxLevel));
end

