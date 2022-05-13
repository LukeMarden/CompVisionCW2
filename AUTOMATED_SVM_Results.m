%Used to test lambda values on the svm classifier
lambda_values = [0.00001:0.00001:1];
features = ['tiny_image', 'colour_hist', 'bag_of_sifts', 
    'pyramid_sifts', 'pca', 'fisher'];

results = zeros(length(lambda_values),2, length(features));
for i = 1:length(features)
    for j = 1:length(lambda_values)
        disp([features(i) + ', ' + lambda_values(j)]);
        start_time = datetime(now, 'ConvertFrom', 'datenum');
        disp(['Start Time = ' datestr(start_time)]);
        tic;
        %best version of all features
        switch features(i)
            case 'colour_hist'
                train_image_feats = get_colour_histograms(train_image_paths, 'hsv', 6);
                test_image_feats = get_colour_histograms(test_image_paths, 'hsv', 6);
            case 'tiny_image'
                train_image_feats = get_tiny_images(train_image_paths, 1, 12, "", "");
                test_image_feats = get_tiny_images(test_image_paths, 1, 12, "", "");
        end
        predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats, lambda_values(j));
        classify_time = toc;
        disp(['Model Building = ' num2str(classify_time)]); 
        accuracy = get_accuracy(test_labels, categories, predicted_categories);
        results(j, 1, i) = lambda_values(j);
        results(j, 2, i) = accuracy;
        end_time = toc;
        disp(['Total Time = ' num2str(end_time)]); 
    end
end

plots = gobjects(length(features), 1);
figure; hold on
for i = 1:length(features)
    plots(i) = plot(results(:,1,i), results(:,2, i));
end
legend(plots, feature)
xlabel('Lambda Value');
ylabel('Accuracy');

