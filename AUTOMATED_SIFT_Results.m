colour = {'grayscale', 'rgb', 'opponent'};
bin_size = [4,16,32,64];
vocab_size = [10,50,100,250,500];
data = cell(1, length(colour));

data_path = 'data/';
categories = {'Kitchen', 'Store', 'Bedroom', 'LivingRoom', 'House', ...
       'Industrial', 'Stadium', 'Underwater', 'TallBuilding', 'Street', ...
       'Highway', 'Field', 'Coast', 'Mountain', 'Forest'};
abbr_categories = {'Kit', 'Sto', 'Bed', 'Liv', 'Hou', 'Ind', 'Sta', ...
    'Und', 'Bld', 'Str', 'HW', 'Fld', 'Cst', 'Mnt', 'For'};
num_train_per_cat = 100; 
[train_image_paths, test_image_paths, train_labels, test_labels] = ...
    get_image_paths(data_path, categories, num_train_per_cat);


% for i = 1:1%length(colour)
%     results = zeros(length(vocab_size),2, length(bin_size));
%     for j = 1:length(bin_size)
%         for k = 1:length(vocab_size)
% %             if i == 1
% %                 if j == 1
% %                     continue;
% %                 elseif j == 2
% %                     if k == 1 || k == 2 || k==3 || k==4
% %                         continue
% %                     end
% %                 end 
% %                 
% %             end
%             disp([colour(i) + ", bin size:" + bin_size(j) + ", vocab_size:" + vocab_size(k)]);
%             start_time = datetime(now, 'ConvertFrom', 'datenum');
%             disp(['Start Time = ' datestr(start_time)]);
%             tic;               
%             vocab = build_vocabulary(train_image_paths, vocab_size(k), colour{i}, bin_size(j)); %Also allow for different sift parameters
% %             save('vocab.mat', 'vocab')
%             train_image_feats = get_bags_of_sifts(train_image_paths, 'normal',  bin_size(j), colour{i}, 0, vocab); %Allow for different sift parameters
%             test_image_feats  = get_bags_of_sifts(test_image_paths, 'normal', bin_size(j), colour{i}, 0, vocab); 
%             save(["AUTOMATED_SIFT_Results2" + "_" + i + "_" + j + '_' + k + '.mat'], 'train_image_feats', 'test_image_feats');
%             predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, 15, 'spearman');
%             classify_time = toc;
%             disp(['Model Building = ' num2str(classify_time)]); 
%             accuracy = get_accuracy(test_labels, categories, predicted_categories);
%             results(k, 1, j) = vocab_size(k);
%             results(k, 2, j) = accuracy;
%             end_time = toc;
%             disp(['Total Time = ' num2str(end_time)]); 
%         end
%     end
%     data{i} = results;
% end
% save('data_sift.mat', 'data')
% for i = 1:length(colour)
%     %data_ = cell2mat(data(i));
%     plots = gobjects(length(bin_size), 1);
%     figure; hold on
%     for j = 1:length(bin_size)
%         plots(i) = plot(results(:,1,j), results(:,2, j));
%     end
%     %legend(plots, bin_size)
%     xlabel('Vocabulary Size');
%     ylabel('Accuracy');
%     title(colour(i))
% end 

%Spatial pyramid testing
bin_size = [8,16];
vocab_size = [100,250,500];
spatial_Depth = [1,2,4];
data_Pyr = cell(length(colour), length(spatial_Depth));

for i = 3:length(colour)
    if i == 2
        continue;
    end
    results = zeros(length(vocab_size),2, length(bin_size));
    for j = 2:length(bin_size)
        for k = 1:length(vocab_size)
            for l = 1:length(spatial_Depth)
                disp([colour(i) + ", bin size:" + bin_size(j) + ", vocab_size:" + vocab_size(k) + ', depth:' + spatial_Depth(l)]);
                start_time = datetime(now, 'ConvertFrom', 'datenum');
                disp(['Start Time = ' datestr(start_time)]);
                tic;               
                vocab = build_vocabulary(train_image_paths, vocab_size(k), colour{i}, bin_size(j)); %Also allow for different sift parameters
%                 save('vocab.mat', 'vocab')
                train_image_feats = get_bags_of_sifts(train_image_paths, 'spatial',  bin_size(j), colour{i}, spatial_Depth(l), vocab); %Allow for different sift parameters
                test_image_feats  = get_bags_of_sifts(test_image_paths, 'spatial', bin_size(j), colour{i}, spatial_Depth(l),vocab); 
                save(["AUTOMATED_SPATIAL_Results2" + "_" + i + "_" + j + '_' + k + '_' + l + '.mat'], 'train_image_feats', 'test_image_feats');
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
    end
    data_Pyr{i, l} = results;
end