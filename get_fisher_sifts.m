% Implementated according to the starter code prepared by James Hays, Brown University
% Michal Mackiewicz, UEA

function image_feats = get_fisher_sifts(image_paths, bin_size, colour_scheme, mean, covariance, prior)
    load('vocab.mat');
    image_feats = zeros(size(image_paths,1), size(vocab,1));
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

%         image_feats(i, :) = vl_fisher(double(image_sift_features), mean', covariance', prior');
        
%         %Normalisation
%         total = sum(image_feats(i, :));
%         image_feats(i, :) = image_feats(i, :) / total;
    end
    image_feats = mean';