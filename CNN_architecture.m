clear;
close all;
clc;

% Dataset's root directory
root_directory = fullfile("Categories");

% Loading the dataset 
dataset = imageDatastore(root_directory, "IncludeSubfolders", true, "LabelSource", "foldernames");

% Counts the number of images for every label
table = countEachLabel(dataset);
disp(table);

% Check if the dataset has been loaded properly
random_numbers = randperm(sum(table.Count), 10); % Generates 10 random numbers between 1 and total number of images in dataset
figure;
for i = 1:10
    subplot(2, 5, i);
    imshow(dataset.Files{random_numbers(i)});
    title(['Truth:' char(dataset.Labels(random_numbers(i)))]);
end

% Getting the size (px px channels) of the dataset
img = readimage(dataset, 1);
[row_pixels, col_pixels, channels] = size(img);

% Dividing dataset into train set and test set (validation set)
ratio = 0.75;
[trainset, testset] = splitEachLabel(dataset, ratio, 'randomized');

% CNN Model

layers=[
    
        imageInputLayer([row_pixels col_pixels channels],'Name','Input_Layer')
        
        convolution2dLayer(3,8,'Padding','same','Name','Conv_1')
        batchNormalizationLayer
        reluLayer
        maxPooling2dLayer(2,'stride',2)
        % Output of this layer will be (64 64 8)

        convolution2dLayer(3,16,'Padding','same','Name','Conv_2')
        batchNormalizationLayer
        reluLayer
        maxPooling2dLayer(2,'Stride',2)
        % Output of this layer will be (32 32 16)

        convolution2dLayer(3,32,'Padding','same','Name','Conv_3')
        batchNormalizationLayer
        reluLayer
        % output of this layer will be (32 32 32)

        convolution2dLayer(3,64,'Padding','same','Name','Conv_4')
        batchNormalizationLayer
        reluLayer
        averagePooling2dLayer(2,'Stride',2)
        % output of this layer will be (16 16 64)
        
        convolution2dLayer(3,128,'Padding','same','Name','Conv_5')
        batchNormalizationLayer
        reluLayer
        % output of this layer will be (16 16 128)

        convolution2dLayer(3,128,'Padding','same','Name','Conv_6')
        batchNormalizationLayer
        reluLayer
        averagePooling2dLayer(2,'Stride',2)
        % output of this layer will be (8 8 128)

        convolution2dLayer(3,256,'Padding',0,'Name','Conv_7')
        batchNormalizationLayer
        reluLayer
        averagePooling2dLayer(2,'Stride',2)
        % output of this layer would be (3 3 256)
        
        dropoutLayer

        fullyConnectedLayer(7)
        softmaxLayer
        classificationLayer
        ];

options = trainingOptions('adam', ...
    'InitialLearnRate',0.001, ...       % Initially tested at 0.01
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',3, ...        %Initially tested at 2
    'LearnRateDropFactor',0.5, ...
    'MaxEpochs',20,...                  % Initially tested at 15
    'Shuffle','every-epoch', ...
    'ValidationData',testset, ...
    'ValidationFrequency',10, ...   
    'MiniBatchSize',64, ...
    'Verbose',false, ...
    'ExecutionEnvironment','gpu', ...
    'Plots','training-progress');

net = trainNetwork(trainset,layers,options);

% Saving CNN (CNN has already been saved)
% CNN_Trained_Model = net;
% save CNN_Trained_Model

% Testing accuracy of model on validation set
predictions = classify(net, testset);
actual_labels = testset.Labels;
accuracy = sum(predictions == actual_labels)/numel(actual_labels)*100;
disp(['Accuracy on validation set: ', num2str(accuracy), ' %']);

% Predicted Labels vs Actual Labels
random_numbers = randperm(numel(predictions), 10);
figure;
for i = 1:10
    subplot(2, 5, i);
    imshow(testset.Files{random_numbers(i)});
    title({['Truth:' char(actual_labels(random_numbers(i)))],['Predicted:' char(predictions(random_numbers(i)))]});
end

% Confusion matrix for performance evaluation
figure;
plotconfusion(actual_labels, predictions);

% Confusion chart for performance evaluation
figure;
chart = confusionchart(actual_labels, predictions, 'RowSummary','row-normalized','ColumnSummary','column-normalized');
