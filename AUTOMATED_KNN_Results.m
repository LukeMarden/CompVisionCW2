k = [1:99];
distance_metric = {'euclidean', 'squaredeuclidean', 'seuclidean', 'cityblock', 'minkowski', 'chebychev', 'cosine', 'correlation', 'hamming', 'jaccard', 'spearman'}; 
features = ['tiny_image', 'colour_hist', 'bag_of_sifts', 
    'pyramid_sifts', 'pca', 'fisher'];

data = cell(1, length(features));
for i = 1:length(features)

    results = zeros(length(k),2, length(distance_metric));
    switch features(i)
        case 'colour_hist'
            train_image_feats = get_colour_histograms(train_image_paths, 'hsv', 6);
            test_image_feats = get_colour_histograms(test_image_paths, 'hsv', 6);
        case 'tiny_image'
            train_image_feats = get_tiny_images(train_image_paths, 1, 12, "", "");
            test_image_feats = get_tiny_images(test_image_paths, 1, 12, "", "");
        case 'bag_of_sifts'
            load(["AUTOMATED_SIFT_Results2_1_1_1.mat"]);
        case 'pyramid_sifts'
        case 'pca'
        case 'fisher'
            load(["AUTOMATED_fisher_Results_1_1_1.mat"]);

    end
    for j = 1:length(distance_metric)
        for k = 1:length(k)
            disp([features(i) + ', distance:' + distance_metric(j) + ', k:' + k(k)]);
            start_time = datetime(now, 'ConvertFrom', 'datenum');
            disp(['Start Time = ' datestr(start_time)]);
            tic; 
            predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, k(k), distance_metric(j));
            classify_time = toc;
            disp(['Model Building = ' num2str(classify_time)]); 
            accuracy = get_accuracy(test_labels, categories, predicted_categories);
            results(k, 1, j) = k(k);
            results(k, 2, j) = accuracy;
            end_time = toc;
            disp(['Total Time = ' num2str(end_time)]); 
        end
    end
    data{i} = results;
end

for i = 1:length(features)
    data_ = cell2mat(data(i));
    figure; hold on
    for j = 1:length(distance_metric)
        plot(data_(1,:,j), data_(2,:,j));
    end
    hold off
    lines = string(distance_metric);
    legend(lines);
    xlabel('K Value');
    ylabel('Accuracy');
    title(features(i))
end

