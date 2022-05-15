% Implementated according to the starter code prepared by James Hays, Brown University
% Michal Mackiewicz, UEA

function image_feats = get_bags_of_sifts(image_paths, setting, bin_size, colour_scheme, spatial_Depth)
% image_paths is an N x 1 cell array of strings where each string is an
% image path on the file system.

% This function assumes that 'vocab.mat' exists and contains an N x 128
% matrix 'vocab' where each row is a kmeans centroid or a visual word. This
% matrix is saved to disk rather than passed in a parameter to avoid
% recomputing the vocabulary every time at significant expense.

% image_feats is an N x d matrix, where d is the dimensionality of the
% feature representation. In this case, d will equal the number of clusters
% or equivalently the number of entries in each image's histogram.

% You will want to construct SIFT features here in the same way you
% did in build_vocabulary.m (except for possibly changing the sampling
% rate) and then assign each local feature to its nearest cluster center
% and build a histogram indicating how many times each cluster was used.
% Don't forget to normalize the histogram, or else a larger image with more
% SIFT features will look very different from a smaller version of the same
% image.
load('vocab.mat');
image_feats = zeros(size(image_paths,1), size(vocab,1));
switch lower(setting)
    case 'normal'
        for i = 1:size(image_paths)
            disp(i);
            switch(colour_scheme)
                case('grayscale')
                    image = imread(char(image_paths(i)));
                    image = rgb2gray(image);
                    image = single(image); 
                case('opponent')
                    image = im2single(imread(image_paths{i}));
                    opponent = image;
                    opponent(:,:,1) = (image(:,:,1)-image(:,:,2))/sqrt(2);
                    opponent(:,:,2) = (image(:,:,1)+image(:,:,2)-2*image(:,:,3))/sqrt(6);
                    opponent(:,:,3) = (image(:,:,1)+image(:,:,2)+image(:,:,3))/sqrt(3);
                    image = opponent;
                case('rgb')
                    image = im2single(imread(image_paths{i}));
                case('normalised_rgb')
                    image = im2single(imread(image_paths{i}));
                    normalised = image;
                    normalised(:,:,1) = image(:,:,1)/(image(:,:,1)+image(:,:,2)+image(:,:,3));
                    normalised(:,:,2) = image(:,:,2)/(image(:,:,1)+image(:,:,2)+image(:,:,3));
                    normalised(:,:,3) = image(:,:,3)/(image(:,:,1)+image(:,:,2)+image(:,:,3));
                    image = normalised;
                case('hsv')
                    image = rgb2hsv(imread(image_paths{i}));
                case('transformed_rgb')
                    image = im2single(imread(image_paths{i}));
                    transformed = image;
                    transformed(:,:,1) = (image(:,:,1)-mean(image(:,:,1)))/std(test,[],1);
                    transformed(:,:,2) = (image(:,:,2)-mean(image(:,:,2)))/std(test,[],2);
                    transformed(:,:,3) = (image(:,:,3)-mean(image(:,:,3)))/std(test,[],3);
                    image = transformed;
            end
            image_sift_features = [];
            for j=1:size(image,3)
                smoothed_image = vl_imsmooth(image(:,:,j),2);
                [~, SIFT_features] = vl_dsift(smoothed_image, 'fast', 'size', bin_size);
                image_sift_features = cat(2, image_sift_features, SIFT_features');
            end

%             [~, SIFT_features] = vl_dsift(image, 'fast','size', bin_size);
            distances = vl_alldist2(single(SIFT_features), vocab');
            [~, I] = min(distances, [], 2);
            image_feats(i, :) = histcounts(I,1:size(vocab,1)+1);
            
            %Normalisation
            total = sum(image_feats(i, :));
            image_feats(i, :) = image_feats(i, :) / total;
        end
        
   case 'spatial'
       for i = 1: size(image_paths)
           image = imread(char(image_paths(i)));
           image = rgb2gray(image);
           image = single(image);
           image = vl_imsmooth(image,2);
           
           histogram = RecursivePyramid(image, vocab, 0, 0, spatial_Depth, bin_size);
           %Normalise the histogram
           total = sum(histogram);
           histogram = histogram / total;
           
           image_feats(i,:) = histogram;
           disp(i);
       end
end
% Useful functions:
% [locations, SIFT_features] = vl_dsift(img) 
%  http://www.vlfeat.org/matlab/vl_dsift.html
%  locations is a 2 x n list list of locations, which can be used for extra
%   credit if you are constructing a "spatial pyramid".
%  SIFT_features is a 128 x N matrix of SIFT features
%   note: there are step, bin size, and smoothing parameters you can
%   manipulate for vl_dsift(). We recommend debugging with the 'fast'
%   parameter. This approximate version of SIFT is about 20 times faster to
%   compute. Also, be sure not to use the default value of step size. It will
%   be very slow and you'll see relatively little performance gain from
%   extremely dense sampling. You are welcome to use your own SIFT feature
%   code! It will probably be slower, though.
% 
% D = vl_alldist2(X,Y) 
%    http://www.vlfeat.org/matlab/vl_alldist2.html
%     returns the pairwise distance matrix D of the columns of X and Y. 
%     D(i,j) = sum (X(:,i) - Y(:,j)).^2
%     Note that vl_feat represents points as columns vs this code (and Matlab
%     in general) represents points as rows. So you probably want to use the
%     transpose operator '  You can use this to figure out the closest
%     cluster center for every SIFT feature. You could easily code this
%     yourself, but vl_alldist2 tends to be much faster.
%}