function histogram = RecursivePyramid(image, vocab, nonWeightedHistogram, currentLevel, maxLevel, bin_size)
%RECURSIVEPYRAMID Return a histogram created by intersections of sub levels
%of an image
%   A recursive function that will calculate the histogram count for each
%   vocab word for the current image passed, then use any parent histograms and
%   their intersection with the current histogram to calculate histogram at
%   this level. This histogram intersection is then weighted by the level
%   and summed with all other histograms

%Calculate histogram at this level 
    image_sift_features = [];
    for i=1:size(image,3)
        smoothed_image = vl_imsmooth(image(:,:,i),2);
        [~, SIFT_features] = vl_dsift(smoothed_image, 'step', 8, 'fast', 'size', bin_size);
        image_sift_features = cat(2, image_sift_features, SIFT_features');
    end
    distances = vl_alldist2(single(image_sift_features'), vocab');
    [~, I] = min(distances, [], 2);
    localHistogram = histcounts(I,1:size(vocab,1)+1);
    
    % Get the intersection of this histogram with the parent histogram
    if currentLevel ~= 0
        nonWeightHist = min(localHistogram,nonWeightedHistogram);
    else
        nonWeightHist = localHistogram;
    end
    localHistogram = nonWeightHist;
    % Apply weighting to the histogram intersection result
    histogram = ( (1 / (2^ (maxLevel-currentLevel+1) ) ) .* localHistogram);
    
    % Unwind if we are at the maximum depth, otherwise call this function
    % on the 4 quarters of this image and sum the results
    if currentLevel == maxLevel
        %Unwind the recursion
    else      
        histogram = histogram + RecursivePyramid(image(1:floor(end/2),1:floor(end/2), :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
        histogram = histogram + RecursivePyramid(image(1:floor(end/2), ceil(end/2) + 1: end, :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
        histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, 1:floor(end/2), :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
        histogram = histogram + RecursivePyramid(image(ceil(end/2) + 1:end, ceil(end/2) + 1:end, :), vocab, nonWeightHist, currentLevel+1, maxLevel, bin_size);
    end
    end
   