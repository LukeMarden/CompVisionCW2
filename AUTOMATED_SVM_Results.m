%Used to test lambda values on the svm classifier
lambda_values = [0.00001:0.00001:1];
features = ['tiny_image', 'colour_hist', 'bag_of_sifts', 
    'pyramid_sifts', 'pca', 'fisher'];

results = zeros(length(lambda_values),2, length(features));
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
    for j = 1:length(lambda_values)
        disp([features(i) + ', ' + lambda_values(j)]);
        start_time = datetime(now, 'ConvertFrom', 'datenum');
        disp(['Start Time = ' datestr(start_time)]);
        tic;
        predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats, lambda_values(j));
        classify_time = toc;
        accuracy = get_accuracy(test_labels, categories, predicted_categories);
        results(j, 1, i) = lambda_values(j);
        results(j, 2, i) = accuracy;
        end_time = toc;
        disp(['Total Time = ' num2str(end_time)]); 
    end
end


figure; hold on
for j = 1:length(features)
    plot(data_(1,:,j), data_(2,:,j));
end
hold off
lines = string(features);
legend(lines);
xlabel('Lamba Values');
ylabel('Accuracy');

