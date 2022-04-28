function colourVec = tinyImage(imagePaths, custom, featureSize, colourSpace, average)
    if custom == 1
    if colourSpace == "grey"
        colourVec = zeros(size(imagePaths,1), featureSize*featureSize);
    else
        colourVec = zeros(size(imagePaths,1), featureSize*3*featureSize);
    end
    for x=1:size(imagePaths,1)
        image = imread(char(imagePaths(x)));
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
        
        yBinSize = yBinSize / featureSize;
        xBinSize = xBinSize / featureSize;
        
        remainderY = yBinSize - floor(yBinSize);
        remainderX = xBinSize - floor(xBinSize);
        
        yBinSize = floor(yBinSize);
        xBinSize = floor(xBinSize);
        
        %Access all pixels in the bin and calculate mean colour
        if numColours == 1
            colourVecTemp = zeros(featureSize,featureSize);
        else
            colourVecTemp = zeros(featureSize,featureSize*3);
        end
        addedBinsX = 0;
        remainderStoreX = 0;
        for i=0:featureSize-1
            remainderStoreX = remainderStoreX + remainderX;
            remainderStoreY = remainderY;
            addedBinsY = 0;
            localBinSizeX = addedBinsX + xBinSize;
            startX = ((i*xBinSize) + addedBinsX) + 1;
            if remainderStoreX >= 1
                localBinSizeX = localBinSizeX + 1;
                addedBinsX = addedBinsX + 1;
                remainderStoreX = remainderStoreX - 1;
            end
            for j=0:featureSize-1
                localBinSizeY = addedBinsY + yBinSize;
                startY = ((j*yBinSize) + addedBinsY) + 1;
                if remainderStoreY >= 1
                    localBinSizeY = localBinSizeY + 1;
                    addedBinsY = addedBinsY + 1;
                    remainderStoreY = remainderStoreY - 1;
                end
                remainderStoreY = remainderStoreY + remainderY;
                       
                endY = ((j*yBinSize) + localBinSizeY);
                endX = ((i*xBinSize) + localBinSizeX);
                              
                if endY > imageSize(1,1)
                    endY = imageSize(1,1);
                end
                if endX > imageSize(1,2)
                    endX = imageSize(1,2);
                end
        
                if numColours == 1
                    if average == "median"
                        colourVecTemp((j + 1),(i + 1)) = median(median(image(startY:endY, startX:endX)));
                    else
                        colourVecTemp((j + 1),(i + 1)) = mean(mean(image(startY:endY, startX:endX)));
                    end
                    colourVec(x,:) = colourVecTemp(:);
                    colourVec = colourVec(:,1:featureSize*featureSize);
                else
                    if average == "median"
                        colourVecTemp((j + 1),((i*3) + 1)) = median(median(image(startY:endY, startX:endX,1)));
                        colourVecTemp((j + 1),((i*3) + 2)) = median(median(image(startY:endY, startX:endX,2)));
                        colourVecTemp((j + 1),((i*3) + 3)) = median(median(image(startY:endY, startX:endX,3)));
                    else
                        colourVecTemp((j + 1),((i*3) + 1)) = mean(mean(image(startY:endY, startX:endX,1)));
                        colourVecTemp((j + 1),((i*3) + 2)) = mean(mean(image(startY:endY, startX:endX,2)));
                        colourVecTemp((j + 1),((i*3) + 3)) = mean(mean(image(startY:endY, startX:endX,3)));
                    end
                    
                    colourVec(x,:) = colourVecTemp(:);
                end
                colourVec(x,:) = normalize(colourVec(x,:));
            end
        end
    end
    else
        if colourSpace == "grey"
            colourVec = zeros(size(imagePaths,1), featureSize*featureSize);
        else
            colourVec = zeros(size(imagePaths,1), featureSize*3*featureSize);
        end
        for x=1:size(imagePaths,1)
            image = imread(char(imagePaths(x)));
            if colourSpace == "grey"
                image = rgb2gray(image);
            end
            thumbnail = [featureSize, featureSize];
            thumbnail = imresize(image, thumbnail);
            if colourSpace == "grey"
                colourVecTemp = zeros(featureSize,featureSize);
            else
                colourVecTemp = zeros(featureSize, featureSize*3);
            end
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
            colourVec(x,:) = colourVecTemp(:);
        end
        colourVec(x,:) = normalize(colourVec(x,:));
    end
end