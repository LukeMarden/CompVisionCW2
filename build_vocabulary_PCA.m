function vocab = build_vocabulary_PCA(image_paths, vocab_size, colour_scheme, bin_size, compressionLevel)
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
        [~, SIFT_features] = vl_dsift(smoothed_image, 'step', 8, 'fast', 'size', bin_size);
        SIFT_features = PCA(SIFT_features, 0, compressionLevel);
        image_sift_features = cat(1, image_sift_features, SIFT_features);
    end
    SIFT_list = cat(2, SIFT_list, image_sift_features);
%     disp(i);
end
[centers, ~] = vl_kmeans(single(SIFT_list), vocab_size);
vocab = centers';

