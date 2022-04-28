function [labels] = k_nearest_neighbour_classifier(train_features,train_labels, test_features, k, distance_metric)
    %handling missing parameters
    switch(nargin)
        case 3
            k = 1;
            distance_metric = 'euclidean';
        case 4
            distance_metric = 'euclidean';
    end
    %finds all distances between each point
    distances = pdist2(test_features, train_features, distance_metric); %smallest
    %sorts each row from smallest to biggest
    [~, ind] = sort(distances, 2);
    %slices the set to find the first k 
    ind = ind(:,1:k);
    %finds the classes of the smallest distances and find most common
    labels = cellstr(mode(categorical(train_labels(ind)), 2)); 
    %cellstr changes a categorical array to a cell array
end
