clear;
close all;
clc;

% This code preprocess the images to be compatible with the trained ...
% classifiers. Binary images of different size can also be used

% Load RGB images
root_directory = fullfile('RGB_characters');
rgb_data = imageDatastore(root_directory);
num_images = numel(rgb_data.Files);

% Select the classifier
% 1. To use CNN, set classifier = 1
% 2. To use SVM, set classifier = 2

classifier = 2;

if classifier == 1
    load CNN_Trained_Model.mat
    figure;
    for i = 1 : num_images
        subplot(2, 3, i);
        img = readimage(rgb_data, i);
        [size_x, size_y, channels] = size(img);
        if channels ~= 1
            img_mod = rgb2gray(img);
            img_mod = imbinarize(img_mod);
            img_mod = imresize(img_mod, [128 128]);
        else
            img_mod = imresize(img, [128 128]);
        end
        imshow(img);
        label = classify(CNN_Trained_Model_9932, img_mod);
        title(['Predicted:', char(label)]);
    end
elseif classifier == 2
    load SVM_Trained_Model.mat
    figure;
    for i =1 : num_images
        subplot(2, 3, i);
        img = readimage(rgb_data, i);
        [size_x, size_y, channels] = size(img);
        if channels ~= 1
            img_mod = rgb2gray(img);
            img_mod = imbinarize(img_mod);
            img_mod = img_mod(:, :, 1);
            img_mod = imresize(img_mod, [128 128]);
        else
            img_mod = imresize(img, [128 128]);
        end        
        imshow(img);
        [Features] = extractHOGFeatures(img_mod, 'CellSize', [20 20]);
        label = predict(SVM_Trained_Model, Features);
        title(['Predicted:', char(label)]);
    end
end
