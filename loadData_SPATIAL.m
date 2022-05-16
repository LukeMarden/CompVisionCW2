colour = {'grayscale', 'rgb', 'opponent'};
bin_size = [8,16];
vocab_size = [100,250,500];
spatial_Depth = [1,2,3];
data = cell(length(colour), length(spatial_Depth));

for i = 1:length(colour)
    if i == 2
        continue;
    end
    results = zeros(length(vocab_size),2, length(bin_size));
    for j = 1:length(bin_size)
        for k = 1:length(vocab_size)
            for l = 1:length(spatial_Depth)
                load(["AUTOMATED_SIFT_Results2" + "_" + i + "_" + j + '_' + k + '.mat']);
                predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, 15, 'spearman');
                accuracy = get_accuracy(test_labels, categories, predicted_categories);
                results(k, 1, j) = vocab_size(k);
                results(k, 2, j) = accuracy;
            end
        end
    end
    data{i, l} = results;
end
save('data_spatial.mat', 'data');
for i = 1:length(colour)
    if i == 2
        continue
    end
    for j = 1:length(spatial_Depth)
        data_ = cell2mat(data(i, j));
        figure; hold on
        for k = 1:length(bin_size)
            plot(data_(1,:,k), data_(2,:,k));
        end
        hold off
        lines = string(bin_size);
        legend(lines);
        xlabel('Vocabulary Size');
        ylabel('Accuracy');
        title([colour(i) + ', Max Depth:' + spatial_Depth(j)]);
    end
    
end