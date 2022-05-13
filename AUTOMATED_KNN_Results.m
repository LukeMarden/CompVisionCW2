k = [1:99];
features = ['tiny_image', 'colour_hist', 'bag_of_sifts', 
    'pyramid_sifts', 'pca', 'fisher'];

results = zeros(length(k),2, length(features));
for i = 1:length(features)
    for j = 1:length(lambda_values)
        disp([features(i) + ', ' + k(j)]);
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
        predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, k(j), 'spearman');
        classify_time = toc;
        disp(['Model Building = ' num2str(classify_time)]); 
        accuracy = get_accuracy(test_labels, categories, predicted_categories);
        results(j, 1, i) = k(j);
        results(j, 2, i) = accuracy;
        end_time = toc;
        disp(['Total Time = ' num2str(end_time)]); 
    end
end

plots = gobjects(length(features), 1);
figure; hold on
for i = 1:length(distance_metric)
    plots(i) = plot(results(:,1,i), results(:,2, i));
end
legend(plots, feature)
xlabel('K Value');
ylabel('Accuracy');

