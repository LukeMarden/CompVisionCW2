function accuracy = get_accuracy(test_labels, categories, predicted_categories)
num_categories = length(categories);
confusion_matrix = zeros(num_categories, num_categories);
for i=1:length(predicted_categories)
    row = find(strcmp(test_labels{i}, categories));
    column = find(strcmp(predicted_categories{i}, categories));
    confusion_matrix(row, column) = confusion_matrix(row, column) + 1;
end
num_test_per_cat = length(test_labels) / num_categories;
confusion_matrix = confusion_matrix ./ num_test_per_cat;   
accuracy = mean(diag(confusion_matrix));
end

