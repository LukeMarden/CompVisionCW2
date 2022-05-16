colour = {'grayscale', 'rgb', 'opponent'};
bin_size = [4,8,16,32,64];
vocab_size = [10,50,100,200,400,750];
data = cell(1, length(colour));

for i = 1:size(colour, 2)
    results = zeros(length(vocab_size),2, length(bin_size));
    for j = 1:size(bin_size, 2)
        for k = 1:size(vocab_size, 2)
            load(["AUTOMATED_fisher_Results" + "_" + i + "_" + j + '_' + k + '.mat']);
            predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, 15, 'spearman');
            accuracy = get_accuracy(test_labels, categories, predicted_categories);
            results(k, 1, j) = vocab_size(k);
            results(k, 2, j) = accuracy;

        end
    end
    data{i} = results;
end
save(['FISHER_ACCURACY_RESULTS.mat'], 'data');


% test_data = zeros(2,5,5);
% test_data(:,:, 1) = [1,2,3,4,5;0.5,0.6,0.7,0.8,0.9];
% test_data(:,:, 2) = [1,2,3,4,5;0.6,0.1,0.3,0.3,0.9];
% test_data(:,:, 3) = [1,2,3,4,5;0.5,0.6,0.9,0.6,0.8];
% test_data(:,:, 4) = [1,2,3,4,5;0.23,0.34,0.32,0.7,0.6];
% test_data(:,:, 5) = [1,2,3,4,5;0.5,0.91,0.9,0.6,0.8];
% data{1} = test_data;
% 
% test_data(:,:, 1) = [1,2,3,4,5;0.6,0.6,0.6,0.6,0.6];
% test_data(:,:, 2) = [1,2,3,4,5;0.6,0.1,0.3,0.3,0.9];
% test_data(:,:, 3) = [1,2,3,4,5;0.5,0.6,0.9,0.6,0.8];
% test_data(:,:, 4) = [1,2,3,4,5;0.23,0.34,0.32,0.7,0.6];
% test_data(:,:, 5) = [1,2,3,4,5;0.5,0.91,0.9,0.6,0.8];
% data{2} = test_data;



for i = 1:length(colour)
    data_ = cell2mat(data(i));
    figure; hold on
    for j = 1:length(bin_size)
        plot(data_(1,:,j), data_(2,:,j));
    end
    hold off
    lines = string(bin_size);
    legend(lines);
    xlabel('Vocabulary Size');
    ylabel('Accuracy');
    title(colour(i))
end
 
