% Michal Mackiewicz, UEA
% This code has been adapted from the code 
% prepared by James Hays, Brown University

%% Step 0: Set up parameters, vlfeat, category list, and image paths.

%FEATURE = 'tiny image';
%FEATURE = 'colour histogram';
% FEATURE = 'bag of sift';
%FEATURE = 'spatial pyramids';
% FEATURE = 'pca';
FEATURE = 'fisher';

% CLASSIFIER = 'nearest neighbor';
CLASSIFIER = 'svm';

% Set up paths to VLFeat functions. 
% See http://www.vlfeat.org/matlab/matlab.html for VLFeat Matlab documentation
% This should work on 32 and 64 bit versions of Windows, MacOS, and Linux
%run('vlfeat/toolbox/vl_setup')

data_path = 'data/';

%This is the list of categories / directories to use. The categories are
%somewhat sorted by similarity so that the confusion matrix looks more
%structured (indoor and then urban and then rural).
categories = {'Kitchen', 'Store', 'Bedroom', 'LivingRoom', 'House', ...
       'Industrial', 'Stadium', 'Underwater', 'TallBuilding', 'Street', ...
       'Highway', 'Field', 'Coast', 'Mountain', 'Forest'};
   
%This list of shortened category names is used later for visualization.
abbr_categories = {'Kit', 'Sto', 'Bed', 'Liv', 'Hou', 'Ind', 'Sta', ...
    'Und', 'Bld', 'Str', 'HW', 'Fld', 'Cst', 'Mnt', 'For'};
    
%number of training examples per category to use. Max is 100. For
%simplicity, we assume this is the number of test cases per category, as
%well.
num_train_per_cat = 100; 

%This function returns cell arrays containing the file path for each train
%and test image, as well as cell arrays with the label of each train and
%test image. By default all four of these arrays will be 1500x1 where each
%entry is a char array (or string).
fprintf('Getting paths and labels for all train and test data\n')
[train_image_paths, test_image_paths, train_labels, test_labels] = ...
    get_image_paths(data_path, categories, num_train_per_cat);
%   train_image_paths  1500x1   cell      
%   test_image_paths   1500x1   cell           
%   train_labels       1500x1   cell         
%   test_labels        1500x1   cell          

%% Step 1: Represent each image with the appropriate feature
% Each function to construct features should return an N x d matrix, where
% N is the number of paths passed to the function and d is the 
% dimensionality of each image representation. See the starter code for
% each function for more details.

fprintf('Using %s representation for images\n', FEATURE)

switch lower(FEATURE)    
    case 'tiny image'
        train_image_feats = get_tiny_images(train_image_paths, 1, 12, "", "");
        test_image_feats = get_tiny_images(test_image_paths, 1, 12, "", "");
    case 'colour histogram'
        train_image_feats = get_colour_histograms(train_image_paths, 'hsv', 6);
        test_image_feats  = get_colour_histograms(test_image_paths,'hsv', 6);
     case 'bag of sift'
         bin_size = 64; 
        if ~exist('vocab.mat', 'file')
            fprintf('No existing dictionary found. Computing one from training images\n')
            vocab_size = 200; % you need to test the influence of this parameter
            
            vocab = build_vocabulary(train_image_paths, vocab_size, 'grayscale', bin_size); %Also allow for different sift parameters
            save('vocab.mat', 'vocab')
        end
        if ~exist('image_feats.mat', 'file')
            train_image_feats = get_bags_of_sifts(train_image_paths, 'normal', bin_size, 'grayscale'); %Allow for different sift parameters
            test_image_feats  = get_bags_of_sifts(test_image_paths, 'normal', bin_size, 'grayscale'); 
            save('image_feats.mat', 'train_image_feats', 'test_image_feats')
        end
      case 'spatial pyramids'
          bin_size = 64; 
          if ~exist('vocab.mat', 'file')
            fprintf('No existing dictionary found. Computing one from training images\n')
            vocab_size = 50; % you need to test the influence of this parameter
            vocab = build_vocabulary(train_image_paths, vocab_size, 'grayscale', bin_size); %Also allow for different sift parameters
            save('vocab.mat', 'vocab')
          end
          
          if ~exist('image_feats.mat', 'file')
            train_image_feats = get_bags_of_sifts(train_image_paths, 'spatial', bin_size, 'grayscale'); %Allow for different sift parameters
            test_image_feats  = get_bags_of_sifts(test_image_paths, 'spatial', bin_size, 'grayscale'); 
            save('image_feats.mat', 'train_image_feats', 'test_image_feats')
          end
      case 'pca'
          if exist('vocab.mat','file')
              %Apply fisher LDA to each feature vector in the vocab
              result = pca(vocab);
          end
    case 'fisher'
        bin_size = 8; 
        vocab_size = 200;
        [means, cov, prior] = build_fisher_vocab(train_image_paths, vocab_size, 'grayscale', bin_size);
        train_image_feats = get_fisher_sifts(train_image_paths, bin_size, 'grayscale', means, cov, prior);
        test_image_feats  = get_fisher_sifts(test_image_paths, bin_size, 'grayscale', means, cov, prior); 
end
%% Step 2: Classify each test image by training and using the appropriate classifier
% Each function to classify test features will return an N x 1 cell array,
% where N is the number of test cases and each entry is a string indicating
% the predicted category for each test image. Each entry in
% 'predicted_categories' must be one of the 15 strings in 'categories',
% 'train_labels', and 'test_labels'. See the starter code for each function
% for more details.

fprintf('Using %s classifier to predict test set categories\n', CLASSIFIER)

switch lower(CLASSIFIER)    
    case 'nearest neighbor'
        predicted_categories = k_nearest_neighbour_classifier(train_image_feats, train_labels, test_image_feats, 15, 'spearman');
    case 'support vector machine'
        predicted_categories = svm_classify(train_image_feats, train_labels, test_image_feats, 0.0001);
    case 'guassian_naive_bayes'
        predicted_categories = naive_bayes_classify(train_image_feats, train_labels, test_image_feats);
end

%% Step 3: Build a confusion matrix and score the recognition system
% You do not need to code anything in this section. 

% This function will recreate results_webpage/index.html and various image
% thumbnails each time it is called. View the webpage to help interpret
% your classifier performance. Where is it making mistakes? Are the
% confusions reasonable?
create_results_webpage( train_image_paths, ...
                        test_image_paths, ...
                        train_labels, ...
                        test_labels, ...
                        categories, ...
                        abbr_categories, ...
                        predicted_categories)