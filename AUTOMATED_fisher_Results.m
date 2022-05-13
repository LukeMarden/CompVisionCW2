colour = {'grayscale', 'rgb', 'opponent'};
bin_size = [4,8,16,32,64];
vocab_size = [10,50,100,200,400,750,1000];
data = cell(1, length(colour));

for i = 1:length(colour)
    results = zeros(length(vocab_size),2, length(bin_size));
    for j = 1:length(bin_size)
        for k = 1:length(vocab_size)
            disp([colour(i) + ", bin size:" + bin_size(j) + ", vocab_size:" + vocab_size(k)]);
            start_time = datetime(now, 'ConvertFrom', 'datenum');
            disp(['Start Time = ' datestr(start_time)]);
            tic;
            [means, cov, prior] = build_fisher_vocab(train_image_paths, vocab_size(k), colour{1}, bin_size(j));
            train_image_feats = get_fisher_sifts(train_image_paths, bin_size(j), colour{1}, means, cov, prior);
            test_image_feats  = get_fisher_sifts(test_image_paths, bin_size(j), colour{1}, means, cov, prior);
            save(["AUTOMATED_fisher_Results" + "_" + i + "_" + j + '_' + k + '.mat'], 'train_image_feats', 'test_image_feats');
            predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, 15, 'spearman');
            classify_time = toc;
            disp(['Model Building = ' num2str(classify_time)]); 
            accuracy = get_accuracy(test_labels, categories, predicted_categories);
            results(k, 1, j) = vocab_size(k);
            results(k, 2, j) = accuracy;
            end_time = toc;
            disp(['Total Time = ' num2str(end_time)]); 
        end
    end
    data{i} = results;
end
for i = 1:length(colour)
    data_ = cell2mat(data{i});
    plots = gobjects(length(bin_size), 1);
    figure; hold on
    for j = 1:length(bin_size)
        plots(i) = plot(results(:,1,j), results(:,2, j));
    end
    legend(plots, bin_size)
    xlabel('Vocabulary Size');
    ylabel('Accuracy');
    title(colour(i))
end 
