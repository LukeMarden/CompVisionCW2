% Based on James Hays, Brown University

%This function will sample SIFT descriptors from the training images,
%cluster them with kmeans, and then return the cluster centers.

function vocab = build_vocabulary( image_paths, vocab_size )
% The inputs are images, a N x 1 cell array of image paths and the size of 
% the vocabulary.

% The output 'vocab' should be vocab_size x 128. Each row is a cluster
% centroid / visual word.

vocab = zeros(vocab_size, 128);
%SIFT_list = zeros(128,0);
listSize=0;
for i=1:length(image_paths)
    image = imread(char(image_paths(i)));
    image = rgb2gray(image);
    image = single(image);
    image = vl_imsmooth(image, 2);

    [locations, SIFT_features] = vl_dsift(image, 'fast','size', 64);
    listSize = listSize + size(SIFT_features,2);
end
disp(listSize);
SIFT_list = zeros(128, listSize);

currentIndex = 1;
for i= 1:length(image_paths)
    image2 = imread(char(image_paths(i)));
    image2 = rgb2gray(image2);
    image2 = single(image2);    
    
    image2 = vl_imsmooth(image2,2);
    [locations, SIFT_features2] = vl_dsift(image2, 'fast', 'size', 64);
    for j = 1:size(SIFT_features2,2)
        SIFT_list(:,currentIndex) = SIFT_features2(:,j);
    end
    currentIndex = currentIndex + size(SIFT_features2,2);
    
    %[centers, assignments] = vl_kmeans(single(SIFT_features), vocab_size);
    %vocab(:,i) = centers;
    disp(i);
end
disp("YEAH WE MADE ITTT");

[centers, assignments] = vl_kmeans(single(SIFT_list), vocab_size);
vocab = centers';



%{ 
Useful functions:
[locations, SIFT_features] = vl_dsift(img) 
 http://www.vlfeat.org/matlab/vl_dsift.html
 locations is a 2 x n list list of locations, which can be thrown away here
  (but possibly used for extra credit in get_bags_of_sifts if you're making
  a "spatial pyramid").
 SIFT_features is a 128 x N matrix of SIFT features
  note: there are step, bin size, and smoothing parameters you can
  manipulate for vl_dsift(). We recommend debugging with the 'fast'
  parameter. This approximate version of SIFT is about 20 times faster to
  compute. Also, be sure not to use the default value of step size. It will
  be very slow and you'll see relatively little performance gain from
  extremely dense sampling. You are welcome to use your own SIFT feature
  code! It will probably be slower, though.

[centers, assignments] = vl_kmeans(X, K)
 http://www.vlfeat.org/matlab/vl_kmeans.html
  X is a d x M matrix of sampled SIFT features, where M is the number of
   features sampled. M should be pretty large! Make sure matrix is of type
   single to be safe. E.g. single(matrix).
  K is the number of clusters desired (vocab_size)
  centers is a d x K matrix of cluster centroids. This is your vocabulary.
   You can disregard 'assignments'.

  Matlab has a build in kmeans function, see 'help kmeans', but it is
  slower.
%}

% Load images from the training set. To save computation time, you don't
% necessarily need to sample from all images, although it would be better
% to do so. You can randomly sample the descriptors from each image to save
% memory and speed up the clustering. Or you can simply call vl_dsift with
% a large step size here, but a smaller step size in make_hist.m. 

% For each loaded image, get some SIFT features. You don't have to get as
% many SIFT features as you will in get_bags_of_sift.m, because you're only
% trying to get a representative sample here.

% Once you have tens of thousands of SIFT features from many training
% images, cluster them with kmeans. The resulting centroids are now your
% visual word vocabulary.