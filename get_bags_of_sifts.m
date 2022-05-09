% Implementated according to the starter code prepared by James Hays, Brown University
% Michal Mackiewicz, UEA

function image_feats = get_bags_of_sifts(image_paths, setting)
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
switch lower(setting)
    case ''
        load('vocab.mat');

        image_feats = zeros(size(image_paths,1), size(vocab,1));
        for i = 1: size(image_paths)
            image = imread(char(image_paths(i)));
            image = rgb2gray(image);
            image = single(image);
            image = vl_imsmooth(image, 2);

            [locations, SIFT_features] = vl_dsift(image, 'fast','size', 64);
            closestFeat = -1;
            closestFeatDist = -1;

            histogram = zeros(50, 1);
            SIFT_features = SIFT_features';
            for j = 1:size(SIFT_features,1)
                for k=1:size(vocab,1)
                    D = vl_alldist2(single(SIFT_features(j,:)), vocab(k,:));
                    totalDistance = sum(sum(D), 2);
                    if totalDistance < closestFeatDist || closestFeatDist == -1
                        closestFeatDist = totalDistance;
                        closestFeat = k;
                    end
                end
                %Increase histogram for closest vocab word for this image 
                histogram(closestFeat,1) = histogram(closestFeat) + 1;
            end
            disp("One hist down");
            image_feats(i,:) = histogram;
        end
   case 'spatial'
       disp("I'm a little teapot");
       
       load('vocab.mat');
       for i = 1: size(image_paths)
           image = imread(char(image_paths(i)));
           image = rgb2gray(image);
           image = single(image);
           image = vl_imsmooth(image,2);
           
           subImage1 = image(1:end/2, 1: end/2);
           subImage2 = image(1:end/2, end/2 + 1: end);
           subImage3 = image(end/2 + 1:end, 1:end/2);
           subImage4 = image(end/2 + 1:end, end/2 + 1:end);
           %montage({subImage1, subImage2,subImage3,subImage4})
           
           disp("Short and stout")
           [domlocations, domSIFT_features] = vl_dsift(image, 'fast','size', 64);
           [sub1Locations, sub1LSIFT_features] = vl_dsift(subImage1, 'fast','size', 64);
           [sub2locations, sub2SIFT_features] = vl_dsift(subImage2, 'fast','size', 64);
           [sub3locations, sub3SIFT_features] = vl_dsift(subImage3, 'fast','size', 64);
           [sub4locations, sub4SIFT_features] = vl_dsift(subImage4, 'fast','size', 64);
           disp("Here's is my handle")
           
           maxLevel = 1;
           currentLevel = 1;
           intersectionSum = 0;
           for x = 1:(4^currentLevel) + 1
               switch x
                   case 1
                       localSIFT = domSIFT_features';
                   case 2
                       localSIFT = sub1LSIFT_features';
                   case 3
                       localSIFT = sub2LSIFT_features';
                   case 4
                       localSIFT = sub3LSIFT_features';
                   case 5
                       localSIFT = sub4LSIFT_features';
               end
               for j = 1:size(localSIFT,1)
                   for k = 1:size(vocab,1)
                      levelXIntersection = sum(min(vocab(k,:), localSIFT(j,:)));
                      levelXIntersection = (1 / (2^(maxLevel - currentLevel + 1))) * levelXIntersection; 
                      %intersectionSum = intersectionSum + levelXIntersection;
                   end
               end
               
           end

       end
       disp("Here is my spout"); 
end
        
%{
Useful functions:
[locations, SIFT_features] = vl_dsift(img) 
 http://www.vlfeat.org/matlab/vl_dsift.html
 locations is a 2 x n list list of locations, which can be used for extra
  credit if you are constructing a "spatial pyramid".
 SIFT_features is a 128 x N matrix of SIFT features
  note: there are step, bin size, and smoothing parameters you can
  manipulate for vl_dsift(). We recommend debugging with the 'fast'
  parameter. This approximate version of SIFT is about 20 times faster to
  compute. Also, be sure not to use the default value of step size. It will
  be very slow and you'll see relatively little performance gain from
  extremely dense sampling. You are welcome to use your own SIFT feature
  code! It will probably be slower, though.

D = vl_alldist2(X,Y) 
   http://www.vlfeat.org/matlab/vl_alldist2.html
    returns the pairwise distance matrix D of the columns of X and Y. 
    D(i,j) = sum (X(:,i) - Y(:,j)).^2
    Note that vl_feat represents points as columns vs this code (and Matlab
    in general) represents points as rows. So you probably want to use the
    transpose operator '  You can use this to figure out the closest
    cluster center for every SIFT feature. You could easily code this
    yourself, but vl_alldist2 tends to be much faster.
%}