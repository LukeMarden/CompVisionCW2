function colourVec = get_tiny_images(imagePaths, custom, featureSize, colourSpace, average)
%This function either uses our custom resize function of the MATLAB
%imresize function to down sample an image for analysis of pixel colours

if custom == 1
%Using custom resize function

%This function will calculate the number of pixels per bin for a thumbnail
%then take the average colour in this bin and assign it to the final pixel
%colour in the thumbnail. The number of pixels per bin uses the remainder
%from dividing the pixels and thumbnail size and increments the remainder
%by itself until it passes 1, then adding an extra pixel to the bin at this
%index.

%Pre-initialise featureVector for speed
if colourSpace == "grey"
    colourVec = zeros(size(imagePaths,1), featureSize*featureSize);
else
    colourVec = zeros(size(imagePaths,1), featureSize*3*featureSize);
end
%Loop through each image in the folder
for x=1:size(imagePaths,1)
    image = imread(char(imagePaths(x)));
    %Convert the image to greyscale if this setting is enabled
    if colourSpace == "grey"
        image = rgb2gray(image);
    end
    imageSize = size(image);
    yBinSize = double(imageSize(1,1));
    xBinSize = double(imageSize(1,2));
    if size(imageSize,2) < 3
        numColours = 1;
    else
        numColours = double(imageSize(1,3));
    end
    
    %Calculates the number of pixels per bin then rounds it down to the
    %nearest whole number, storing the remainder and incrementing it by
    %itself on each loop iteration until it passes 1, then increasing the
    %number of pixels in the bin at this value. 
    
    %For example if the remainder was 0.2, every 5th bin would have an
    %extra pixel
    yBinSize = yBinSize / featureSize;
    xBinSize = xBinSize / featureSize;
    
    remainderY = yBinSize - floor(yBinSize);
    remainderX = xBinSize - floor(xBinSize);
    
    yBinSize = floor(yBinSize);
    xBinSize = floor(xBinSize);
    
    %Pre-initialise the feature vector for this image for speed
    if numColours == 1
        colourVecTemp = zeros(featureSize,featureSize);
    else
        colourVecTemp = zeros(featureSize,featureSize*3);
    end
    addedBinsX = 0;
    remainderStoreX = 0;
    %Double loop for each pixel in the thumbnail
    
    %Calculates the start and end indexes for each bin in the original
    %image, using the previous extra pixels and remainder to adjust for a
    %decimal number of pixels per bin
    for i=0:featureSize-1
        remainderStoreX = remainderStoreX + remainderX;
        remainderStoreY = remainderY;
        addedBinsY = 0;
        %Adjust for the previous extra pixels in previous iterations by adding them to the local
        %bin size
        localBinSizeX = addedBinsX + xBinSize;
        %The start index in the original image for this thumbnail pixel
        startX = ((i*xBinSize) + addedBinsX) + 1;
        %Handling the case where the current bin needs an extra pixel added
        %to it
        if remainderStoreX >= 1
            localBinSizeX = localBinSizeX + 1;
            addedBinsX = addedBinsX + 1;
            remainderStoreX = remainderStoreX - 1;
        end
        %Loop through the y axis
        for j=0:featureSize-1
            %Start indexes
            localBinSizeY = addedBinsY + yBinSize;
            startY = ((j*yBinSize) + addedBinsY) + 1;
            %Adding an extra pixel if needed
            if remainderStoreY >= 1
                localBinSizeY = localBinSizeY + 1;
                addedBinsY = addedBinsY + 1;
                remainderStoreY = remainderStoreY - 1;
            end
            remainderStoreY = remainderStoreY + remainderY;
             
            % The end indexes in the original image for this thumbnail
            % pixel taking into account
            
            % 1) Rounded down pixels per bin
            % 2) Previous extra pixels added in previous bins
            % 3) Any extra pixels in this bin
            endY = ((j*yBinSize) + localBinSizeY);
            endX = ((i*xBinSize) + localBinSizeX);
                     
            % Make sure the index isn't larger than the dimensions of the
            % original image
            if endY > imageSize(1,1)
                endY = imageSize(1,1);
            end
            if endX > imageSize(1,2)
                endX = imageSize(1,2);
            end
    
            %Take the average colour of the pixels inbetween the starting
            %and end indexes in both the x and y
            if numColours == 1
                if average == "median"
                    colourVecTemp((j + 1),(i + 1)) = median(median(image(startY:endY, startX:endX)));
                else
                    colourVecTemp((j + 1),(i + 1)) = mean(mean(image(startY:endY, startX:endX)));
                end
                %Reduce the dimension to be a 1d feature vector for this
                %image
                colourVec(x,:) = colourVecTemp(:);
                colourVec = colourVec(:,1:featureSize*featureSize);
            else
                %Calculate the mean or median of all the pixels between the
                %indexes in the original image
                if average == "median"
                    colourVecTemp((j + 1),((i*3) + 1)) = median(median(image(startY:endY, startX:endX,1)));
                    colourVecTemp((j + 1),((i*3) + 2)) = median(median(image(startY:endY, startX:endX,2)));
                    colourVecTemp((j + 1),((i*3) + 3)) = median(median(image(startY:endY, startX:endX,3)));
                else
                    colourVecTemp((j + 1),((i*3) + 1)) = mean(mean(image(startY:endY, startX:endX,1)));
                    colourVecTemp((j + 1),((i*3) + 2)) = mean(mean(image(startY:endY, startX:endX,2)));
                    colourVecTemp((j + 1),((i*3) + 3)) = mean(mean(image(startY:endY, startX:endX,3)));
                end
                %Reduce the dimension to be a 1d feature vector for this
                %image
                colourVec(x,:) = colourVecTemp(:);
            end
            colourVec(x,:) = normalize(colourVec(x,:));
        end
    end
end
else
    %Using the MATLAB imresizxe function
    
    %Pre-initialise the feature Vector for speed
    if colourSpace == "grey"
        colourVec = zeros(size(imagePaths,1), featureSize*featureSize);
    else
        colourVec = zeros(size(imagePaths,1), featureSize*3*featureSize);
    end
    %Loop through each image in the folder
    for x=1:size(imagePaths,1)
        image = imread(char(imagePaths(x)));
        %Convert to greyscale if setting enabled
        if colourSpace == "grey"
            image = rgb2gray(image);
        end
        thumbnail = [featureSize, featureSize];
        thumbnail = imresize(image, thumbnail);
        %Pre-initlaise the feature Vector for this image for speed
        if colourSpace == "grey"
            colourVecTemp = zeros(featureSize,featureSize);
        else
            colourVecTemp = zeros(featureSize, featureSize*3);
        end
        %Loop throught the resized image, reducing the dimensionality to
        %make the R, G and B values come one after another in a list
        for i=0:size(thumbnail,1) - 1
            for j=0:size(thumbnail,2) - 1
                if colourSpace == "grey"
                    colourVecTemp(i+1, j+1) = thumbnail(i+1,j+1);
                else
                    colourVecTemp(i+1, (j*3) + 1) = thumbnail(i+1,j+1,1);
                    colourVecTemp(i+1,(j*3) + 2) = thumbnail(i+1,j+1,2);
                    colourVecTemp(i+1,(j*3) + 3) = thumbnail(i+1,j+1,3);
                end
            end
        end
        %Reduce the dimensionality to a 1d feature vector for this image
        colourVec(x,:) = colourVecTemp(:);
    end
    colourVec(x,:) = normalize(colourVec(x,:));
end
end
