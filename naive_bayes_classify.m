function labels = naive_bayes_classify(train_image_feats, train_labels, test_image_feats)

% medians = median(train_image_feats);
% lq = quantile(train_image_feats,0.25,1);
% uq = quantile(train_image_feats,0.75,1);
% 
% above_uq =  sum((train_image_feats>uq), 1);
% above_median = sum((train_image_feats<=uq & train_image_feats>medians), 1);
% above_lq = sum((train_image_feats<=medians & train_image_feats>lq), 1);
% below_lq = sum((train_image_feats<=lq), 1);

categories = unique(train_labels); 
num_categories = length(categories);
pdf_values = zeros(2, size(train_image_feats, 2), num_categories);
probabilities = zeros(size(test_image_feats,1), num_categories);
for i =1:num_categories
    true = strcmp(categories(i), train_labels);
    [index,~] = find(true);
    cat_feats = train_image_feats(index,:);
    pdf_values(1, :, i) = mean(cat_feats);
    pdf_values(2, :, i) = std(cat_feats);
    
    distribution = normpdf(test_image_feats, pdf_values(1, :, i), pdf_values(2, :, i));
    distribution = distribution * 100;
    distribution(isnan(distribution)) = 1;
    probabilities(:, i) = double(prod(distribution, 2));
end
[~,preds] = max(probabilities,[],2);
labels = categories(preds);