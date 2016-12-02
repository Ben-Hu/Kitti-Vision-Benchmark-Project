clear all; close all;
globals;
addpath(genpath('dpm'));
data = load('dpm/VOC2010/car_final.mat');
model = data.model;

%Get dpm detections:
img = double(imread(fullfile(CAR_IMG_L, '000063.png')))/255;
detections = process(img, model, -0.5);
%showboxes(im, bbox);

%Classify each detection
for i=1:size(detections,1)
    bounds = detections(i,1:4);
    x1 = bounds(1);
    y1 = bounds(2);
    x2 = bounds(3);
    y2 = bounds(4);
    
    c_box = max(round([x1,x2,y1,y2]),1);
 
    %3 dimensional patch
    img_data = img(c_box(1):c_box(2),c_box(3):c_box(4),:);
    img_siz_data = cat(1,img_siz_data,size(img_data(:,:)));
    img_data_r = imresize(img_data, [80,120]);
    c_hog = extractHOGFeatures(img_data_r, 'NumBins', 9, 'CellSize', [6, 6]);

    %GRADIENT MAG
    %log normalizes the exposure to a degree, much better results
    img_data_r_bw = log(rgb2gray(img_data_r)); 
    %img_data_r_bw = img_data_r(:,:,1);
    y_filt = [-1,0,1];
    x_filt = [-1;0;1];

    grad_y = conv2(img_data_r_bw,y_filt,'same').^2;
    grad_x = conv2(img_data_r_bw,x_filt,'same').^2;
    grad_mag = sqrt(grad_y + grad_x);
    
    figure; imagesc(img_data); axis image; colormap gray
    %figure; imagesc(img_data_r); axis image; colormap gray
    %figure; imagesc(grad_mag); axis image; colormap gray

    %SHAPE
    %Morphological disk blurring for general shape information
    element = strel('disk', 5);
    supp = imopen(img_data_r_bw, element);
    %figure; imagesc(supp); axis image; colormap gray

    feat_vec = cat(2,c_hog,reshape(grad_mag,1,[]),reshape(supp,1,[]));
    norm_factor = max(abs(feat_vec));
    pred_vec = cat(1,img_vec,feat_vec/norm_factor);

    %Classify for first model
    [svmOut1,~,~] = svmpredict(1,pred_vec,model1,'-b 1');
    
    %Second model
    [svmOut2,~,~] = svmpredict(1,pred_vec,model2,'-b 1');
    
    if svmOut1 ~= svmOut2
        %model belongs to class 1
    else
        %check if model belongs to class 2
        [svmOut3,~,~] = svmpredict(1,pred_vec,model3,'b 1');
        if svmOut2 ~= svmOut3
            %model belongs to class 2
        else
            %...
        end
    end
    
end