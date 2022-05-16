colour = {'grayscale', 'rgb', 'opponent'};
bin_size = [4,16,32,64];
vocab_size = [10,50,100,250,500];
data = cell(1, length(colour));

for i = 1:length(colour)
    if i == 2
        continue
    end
    results = zeros(length(vocab_size),2, length(bin_size));
    for j = 1:length(bin_size)
        for k = 1:length(vocab_size)
            load(["AUTOMATED_SIFT_Results2" + "_" + i + "_" + j + '_' + k + '.mat']);
            predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, 15, 'spearman');
            accuracy = get_accuracy(test_labels, categories, predicted_categories);
            results(k, 1, j) = vocab_size(k);
            results(k, 2, j) = accuracy;
        end
    end
    data{i} = results;
end
save('data_sift.mat', 'data')
for i = 1:length(colour)
    if i == 2
        continue
    end
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