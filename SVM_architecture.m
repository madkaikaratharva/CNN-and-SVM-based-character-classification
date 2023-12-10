clear;
close all;
clc;

% Dataset's root directory
root_directory = fullfile("Categories");

% Loading the dataset 
dataset = imageDatastore(root_directory, "IncludeSubfolders",true,"LabelSource","foldernames");

% Counts the number of images for every label
table = countEachLabel(dataset);
disp(table);

% Check if the dataset has been loaded properly
random_numbers = randperm(sum(table.Count), 10); % Generates 10 random numbers between 1 and the total number of images in dataset

figure;
for i = 1:10
    subplot(2, 5, i);
    img = readimage(dataset, random_numbers(i));
    imshow(img)
    title(['Truth:' char(dataset.Labels(random_numbers(i)))]);
end

% Feature extraction visualization
figure;
for i = 1:10
    subplot(2, 5, i);
    img = readimage(dataset, random_numbers(i));
    [hog, vis] = extractHOGFeatures(img, 'CellSize', [20 20]);
    plot(vis);
    title({'Cellsize = [20 20]' ; ['featuresize = ' num2str(length(hog))]},'Fontsize', 6);
end

% Training
% Dividing dataset into train set and test set randomly (validation set)
ratio = 0.75;
[trainset, testset] = splitEachLabel(dataset, ratio, 'randomized');

% Initializing Parameters for feature extraction
cellsize = [20 20];
[HOG, vis] = extractHOGFeatures(img,'CellSize',cellsize);
num_train_images = numel(trainset.Files);
HOG_feature_size = length(HOG);
train_features = zeros(num_train_images,HOG_feature_size,'single');
train_Labels = trainset.Labels;

% Training 
for i = 1:num_train_images
    img = readimage(trainset, i);
    train_features(i, :) = extractHOGFeatures(img, 'CellSize', cellsize);
end

svm = fitcecoc(train_features, train_Labels);

% Accuracy of the SVM
num_test_images = numel(testset.Files);
test_features = zeros(num_test_images, HOG_feature_size,'single');

for j = 1:num_test_images
    img = readimage(testset,j);
    test_features(j, :) = extractHOGFeatures(img,'CellSize',cellsize);
end

predicated_labels = predict(svm, test_features);

clc;
test_Labels = testset.Labels;
accuracy = sum(predicated_labels == test_Labels)/numel(test_Labels);
disp(accuracy);

% Predicted Labels vs Actual Labels
random_numbers = randperm(numel(predicated_labels), 10);
figure;
for i = 1:10
    subplot(2, 5, i);
    imshow(testset.Files{random_numbers(i)});
    title({['Truth:' char(test_Labels(random_numbers(i)))],['Predicted:' char(predicated_labels(random_numbers(i)))]});
end

% Saving the classifier (already saved)
% SVM_Trained_Model = svm;
% save SVM_Trained_Model

% Confusion matrix for performance evaluation
figure;
plotconfusion(test_Labels, predicated_labels);

% Confusion chart for performance evaluation
figure;
chart = confusionchart(test_Labels, predicated_labels, 'RowSummary','row-normalized','ColumnSummary','column-normalized');


