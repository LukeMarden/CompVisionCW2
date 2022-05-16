%Used to test lambda values on the svm classifier
features = ['tiny_image', 'colour_hist', 'bag_of_sifts', 
    'pyramid_sifts', 'pca', 'fisher'];

results = zeros(length(features),2);
for i = 1:length(features)
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
    disp([features(i)]);
    start_time = datetime(now, 'ConvertFrom', 'datenum');
    disp(['Start Time = ' datestr(start_time)]);
    tic;
    predicted_categories = gaussian_naive_bayes_classify(train_image_feats, train_labels, test_image_feats);
    classify_time = toc;
    accuracy = get_accuracy(test_labels, categories, predicted_categories);
    results(i, 1, i) = features(i);
    results(i, 2, i) = accuracy;
    end_time = toc;
    disp(['Total Time = ' num2str(end_time)]); 
end


figure; hold on
plot(data_(1,:), data_(2,:));
hold off
xlabel('Feature');
ylabel('Accuracy');

