function histogram = RecursivePyramid(image, vocab, nonWeightedHistogram, currentLevel, maxLevel, bin_size)
%RECURSIVEPYRAMID Summary of this function goes here
%   Detailed explanation goes here

%Calculate histogram intersection at this level 

    image_sift_features = [];
    for i=1:size(image,3)
        smoothed_image = vl_imsmooth(image(:,:,i),2);
        [~, SIFT_features] = vl_dsift(smoothed_image, 'fast', 'size', bin_size);
        image_sift_features = cat(2, image_sift_features, SIFT_features');
    end
    distances = vl_alldist2(single(image_sift_features'), vocab');
    [~, I] = min(distances, [], 2);
    localHistogram = histcounts(I,1:size(vocab,1)+1);
    
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
        histogram = histogram + RecursivePyramid(image(1:floor(end/2),1:floor(end/2), :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
        histogram = histogram + RecursivePyramid(image(1:floor(end/2), ceil(end/2) + 1: end, :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
        histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, 1:floor(end/2), :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
        histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, ceil(end/2) + 1:end, :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
    end
    %histogram = histogram + (1/(2*maxLevel));
    end
   
