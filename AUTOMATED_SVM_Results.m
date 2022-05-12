%Used to test lambda values on the svm classifier
lambda_values = [0.0001:0.0001:1];
% feature = 'hist';
feature = 'tiny';


% switch feature
%     case 'hist'
%         train_image_feats = get_colour_histograms(train_image_paths, 'hsv', 6);
%         test_image_feats = get_colour_histograms(test_image_paths, 'hsv', 6);
%     case 'tiny'
%         train_image_feats = get_tiny_images(train_image_paths, 1, 12, "", "");
%         test_image_feats = get_tiny_images(test_image_paths, 1, 12, "", "");
% end

results = zeros(length(lambda_values),2);
for i = 1:length(lambda_values)
    disp(lambda_values(i));
    start_time = datetime(now, 'ConvertFrom', 'datenum');
    disp(['Start Time = ' datestr(start_time)]);
    tic;
    predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats, lambda_values(i));
    classify_time = toc;
    disp(['Model Building = ' num2str(classify_time)]); 
    accuracy = get_accuracy(test_labels, categories, predicted_categories);
    results(i,1) = lambda_values(i);
    results(i,2) = accuracy;
    end_time = toc;
    disp(['Total Time = ' num2str(end_time)]);        
end

plots = gobjects(length(lambda_values), 1);
figure; hold on

plot(results(:,1), results(:,2));
xlabel('Lambda Value');
ylabel('Accuracy');

