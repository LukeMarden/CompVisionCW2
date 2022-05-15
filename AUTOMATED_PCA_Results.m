colour = {'grayscale', 'rgb', 'opponent'};
bin_size = [4,64];
vocab_size = [10,100];
data = cell(1, length(colour));
data_PCA = cell(1,length(colour));

data_path = 'data/';
categories = {'Kitchen', 'Store', 'Bedroom', 'LivingRoom', 'House', ...
       'Industrial', 'Stadium', 'Underwater', 'TallBuilding', 'Street', ...
       'Highway', 'Field', 'Coast', 'Mountain', 'Forest'};
abbr_categories = {'Kit', 'Sto', 'Bed', 'Liv', 'Hou', 'Ind', 'Sta', ...
    'Und', 'Bld', 'Str', 'HW', 'Fld', 'Cst', 'Mnt', 'For'};
num_train_per_cat = 100; 
[train_image_paths, test_image_paths, train_labels, test_labels] = ...
    get_image_paths(data_path, categories, num_train_per_cat);


for i = 1:length(colour)
    results = zeros(length(vocab_size),2, length(bin_size));
    results_PCA = zeros(length(vocab_size),2, length(bin_size));
    for j = 1:length(bin_size)
        for k = 1:length(vocab_size)
            disp([colour(i) + ", bin size:" + bin_size(j) + ", vocab_size:" + vocab_size(k)]);
            start_time = datetime(now, 'ConvertFrom', 'datenum');
            disp(['Start Time = ' datestr(start_time)]);
            tic;               
            vocab = build_vocabulary(train_image_paths, vocab_size(k), colour{i}, bin_size(j)); %Also allow for different sift parameters
            save('vocab.mat', 'vocab')
            train_image_feats = get_bags_of_sifts(train_image_paths, 'normal',  bin_size(j), colour{i}); %Allow for different sift parameters
            test_image_feats  = get_bags_of_sifts(test_image_paths, 'normal', bin_size(j), colour{i}); 
            train_image_feats_PCA = PCA(train_image_feats, 0, 4);
            test_image_feats_PCA = PCA(test_image_feats, 0, 4);
            save(["AUTOMATED_PCA_Results" + "_" + i + "_" + j + '_' + k + '.mat'], 'train_image_feats', 'test_image_feats');
            predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, 15, 'spearman');
            predicted_categories_PCA = k_nearest_neighbour_classifier(train_image_feats_PCA, train_labels, test_image_feats_PCA, 15, 'spearman');
            classify_time = toc;
            disp(['Model Building = ' num2str(classify_time)]); 
            accuracy = get_accuracy(test_labels, categories, predicted_categories);
            accuracy_PCA = get_accuracy(test_labels, categories, predicted_categories_PCA);
            results(k, 1, j) = vocab_size(k);
            results(k, 2, j) = accuracy;
            results_PCA(k,1,j) = vocab_size(k);
            results_PCA(k,2,j) = accuracy_PCA;
            end_time = toc;
            disp(['Total Time = ' num2str(end_time)]); 
        end
    end
    data{i} = results;
    data_PCA{i} = results_PCA;
end
save("Non-PCA_Results", "data");
save("PCA_Results", "data_PCA");
for i = 1:length(colour)
    %data_ = cell2mat(data(i));
    plots = gobjects(length(bin_size), 1);
    figure; hold on
    for j = 1:length(bin_size)
        plots(i) = plot(results(:,1,j), results(:,2, j));
    end
    %legend(plots, bin_size)
    xlabel('Vocabulary Size');
    ylabel('Accuracy');
    title(colour(i))
end 


