% Based on James Hays, Brown University

%This function will sample SIFT descriptors from the training images,
%cluster them with kmeans, and then return the cluster centers.

function vocab = build_vocabulary(image_paths, vocab_size, colour_scheme, bin_size)
% The inputs are images, a N x 1 cell array of image paths and the size of 
% the vocabulary.

% The output 'vocab' should be vocab_size x 128. Each row is a cluster
% centroid / visual word.
SIFT_list = [];
for i= 1:length(image_paths)
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
%     disp(image_sift_features);
    for j=1:size(image,3)
        smoothed_image = vl_imsmooth(image(:,:,j),2);
        [~, SIFT_features] = vl_dsift(smoothed_image, 'fast', 'size', bin_size);
        image_sift_features = cat(2, image_sift_features, SIFT_features');
    end
    SIFT_list = cat(1, SIFT_list, image_sift_features);
%     disp(i);
end
[centers, ~] = vl_kmeans(single(SIFT_list'), vocab_size);
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