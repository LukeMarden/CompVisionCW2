function histogram = get_spatial_sifts(image_paths, bin_size, colour_scheme, level, max_level)
    if level == 0
        histogram = get_histogram(image_paths, bin_size, colour_scheme, 0, max_level);
    else
        previous_level_histogram = get_spatial_sifts(image_paths, bin_size, colour_scheme, level-1, max_level);
        this_histogram = get_histogram(image_paths, bin_size, colour_scheme, 0, max_level);
        histogram = this_histogram + previous_level_histogram;
    end

function histogram = get_histogram(image_paths, bin_size, colour_scheme, level, max_level)
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
        for j = 1:size(image,3)
            %split image accordingly
            [a, b] = size(image(:,:,j));
            split_image = mat2cell(image(:,:,j), ...
                [repelem(floor(a/2^level), 2^level-1), floor(a/2^level)+mod(a, 2^level)], ...
                [repelem(floor(b/2^level), 2^level-1), floor(b/2^level)+mod(b, 2^level)]);
            split_image = split_image(:)';
            split_features = [];
            for k = 1:length(split_image)
                smoothed_image = vl_imsmooth(cell2mat(split_image(k)),2);
                [locations, SIFT_features] = vl_dsift(smoothed_image, 'fast', 'size', bin_size);
                split_features = cat(1, split_features, SIFT_features');
            end
            image_sift_features = cat(2, image_sift_features, split_features);
        end
        distances = vl_alldist2(single(image_sift_features'), vocab');
        [~, I] = min(distances, [], 2);
        image_feats(i, :) = histcounts(I,1:size(vocab,1)+1);

        histogram = (1/(2^(max_level-level+1)))*image_feats;
    end