function [image_feats] = get_colour_histograms(image_paths, colour_space, quantisation_level)
    %handles missing parameters
    switch nargin
        case 1
            colour_space = 'rgb';
            quantisation_level = 16;
        case 2
            quantisation_level = 16;
    end
    %initialises array for features to be held
    image_feats = zeros(length(image_paths), quantisation_level^3);
    for i = 1:length(image_paths)
        %converts to set colour space and then normalises
        switch(colour_space)
            case 'rgb'
                image = im2double(imread(image_paths{i}));
            case 'hsv'
                image = rgb2hsv(imread(image_paths{i}));
            case 'xyz'
                image = rgb2xyz(imread(image_paths{i}));
                image = image/1.0888;
            case 'lab'
                image = rgb2lab(imread(image_paths{i}));
                image(:,:,1) = image(:,:,1)/100;
                image(:,:,2) = (image(:,:,2)+128)/255;
                image(:,:,3) = (image(:,:,3)+128)/255;
            case 'ycbcr'
                image = rgb2ycbcr(im2double(imread(image_paths{i})));
                image(:,:,1) = (image(:,:,1)-16/255)/((235-16)/255);
                image(:,:,2) = (image(:,:,2)-16/255)/((240-16)/255);
                image(:,:,3) = (image(:,:,3)-16/255)/((240-16)/255);
            case 'yiq' 
                image = rgb2ntsc(imread(image_paths{i}));
                image(:,:,2) = (image(:,:,2)+0.5959)/1.1918;
                image(:,:,3) = (image(:,:,3)+0.5229)/1.0458;
        end
        %gives each value a set group based on quantisation level
        quantised = round(image*(quantisation_level-1)) + 1;
        %moves into 3 colomns, each referring to a combination
        image = reshape(quantised, [], 3);
        %counts each unique value
        [value, ~, counts] = unique(image,'rows'); 

        counts = groupcounts(counts);
        %feature vector for this image
        results = zeros(quantisation_level, quantisation_level, quantisation_level);
        for j = 1:size(value, 1)
            results(value(j,1), value(j,2), value(j,3)) = counts(j);
        end
        %adds feature vector to final output
        image_feats(i,:) = results(:).';
    end
    
end

