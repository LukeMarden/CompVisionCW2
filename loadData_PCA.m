features = {'SIFT', 'SIFT With PCA'}

% data = zeros(length(features), 2);
% for i = 1:length(features)
%     switch string(features(i))
%         case 'SIFT'
%             load("AUTOMATED_SIFT_RESULTS2_3_2_5.mat");
%         case 'SIFT With PCA'
%             vocab = build_vocabulary_PCA(train_image_paths, 500, 'opponent', 16, 4);
%             disp("built vocab")
%             train_image_feats_PCA = get_bags_of_sifts(train_image_paths, 'pca',  16, 'opponent', 0, vocab);
%             disp("train done")
%             test_image_feats_PCA  = get_bags_of_sifts(test_image_paths, 'pca', 16, 'opponent', 0, vocab); 
%             disp("Test done")
%             %train_image_feats_PCA = PCA(train_image_feats_PCA, 0, 4);
%             %test_image_feats_PCA = PCA(test_image_feats_PCA, 0, 4);
%     end
%     predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats, 0.00001);
%     accuracy = get_accuracy(test_labels, categories, predicted_categories);
%     data(i, 2) = accuracy;
% end
% save('pca_data.mat', 'data');


figure; hold on
hold off
bar(data(:, 2));
set(gca, 'XTickLabel', features, 'XTick', 1:numel(features));
xlabel('Variations');
ylabel('Accuracy');
title('Effect of PCA on best performing SIFT')

