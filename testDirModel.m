%clear all; close all;
close all;

globals;
addpath(genpath('dpm'));
%addpath(genpath('vlfeat-0.9.20'));
%Get dpm detections:
img = single(imread(fullfile(CAR_IMG_L, '000021.png')))/255; %-180
%img = single(imread(fullfile(TEST_CAR_IMG_L, '000005.png')))/255; %fails
img = single(imread(fullfile(TEST_CAR_IMG_L, '000037.png')))/255;
%img = single(imread(fullfile(TEST_CAR_IMG_L, '000033.png')))/255;
%img = single(imread(fullfile(TEST_CAR_IMG_L, '000100.png')))/255;
%img = single(imread(fullfile(TEST_CAR_IMG_L, '000202.png')))/255;
%img = single(imread(fullfile(TEST_CAR_IMG_L, '001000.png')))/255;
img = fliplr(img);
%figure; imagesc(img); axis image;
data = load('dpm/VOC2010/car_final.mat');
model_d = data.model;
detections = process(img, model_d, -0.5);
showboxes(img, detections);

%Classify each detection
for i=1:size(detections,1)
    bounds = detections(i,1:4);
    y1 = bounds(1);
    x1 = bounds(2);
    y2 = bounds(3);
    x2 = bounds(4);
    
    c_box = max(round([x1,x2,y1,y2]),1);
 
    %3 dimensional patch
    img_data = img(c_box(1):c_box(2),c_box(3):c_box(4),:);
    %img_siz_data = cat(1,img_siz_data,size(img_data(:,:)));
    if min(size(img_data,1),size(img_data,2)) < 40
        %do not process objects with boxes less than 40px in smallest
        %dimension
        fprintf('object %d lt 40px, not guessing\n',i);
        break;
    end
    
    img_data_r = imresize(img_data, [104,154]);
    [c_hog,vis] = extractHOGFeatures(img_data_r, 'NumBins', 12, 'CellSize', [8, 8], 'BlockSize', [13,19],'UseSignedOrientation', true);
    %imshow(img_data_r); hold on; plot(vis);
    
    %GRADIENT MAG
    %log normalizes the exposure to a degree, much better results
    img_data_r_bw = rgb2gray(img_data_r); 
    %img_data_r_bw = img_data_r(:,:,1);
%     y_filt = [-1,0,1];
%     x_filt = [-1;0;1];
% 
%     grad_y = conv2(img_data_r_bw,y_filt,'same').^2;
%     grad_x = conv2(img_data_r_bw,x_filt,'same').^2;
%     grad_mag = sqrt(grad_y + grad_x);
%     
%     figure; imagesc(img_data); axis image; colormap gray
%     %figure; imagesc(img_data_r); axis image; colormap gray
%     %figure; imagesc(grad_mag); axis image; colormap gray
%    
%     %SHAPE
%     %Morphological disk blurring for general shape information
%     element = strel('disk', 5);
%     supp = imopen(img_data_r_bw, element);
%     %figure; imagesc(supp); axis image; colormap gray
    
%     [keyp,desc] = vl_sift(img_data_r_bw);
%     if size(desc,2) < 10
%         fprintf('Detection %s only had %d points\n',i,size(desc,2));
%         break
%     end
%     sift_samp = randsample(1:size(desc,2),20,true);
%     sift_vec = reshape(desc(:,sift_samp),1,[]); 
%     


    points = detectSURFFeatures(img_data_r_bw);
    %Pick strongest x points from detected SURF features
    if size(points,1) < 10
        fprintf('Image %s only had %d points for obj %d\n',idx,size(points,1),j);
        num_discarded = num_discarded + 1;
        continue;
    end
    top_points = points.selectStrongest(10);
    [desc,vpoints,vis] = extractHOGFeatures(img_data_r_bw,top_points,'NumBins', 12, 'CellSize', [8, 8], 'BlockSize', [2,2],'UseSignedOrientation', true);
    surf_vec = reshape(desc,1,[]);

    feat_vec = surf_vec;%c_hog;%sift_vec;%cat(2,c_hog,sift_vec); %cat(2,c_hog,reshape(grad_mag,1,[]),reshape(supp,1,[]));
    norm_factor = max(abs(feat_vec));
    pred_vec = double(feat_vec/norm_factor);
    
    %load('car_dir_model_900s_C8.mat');
    %load('car_dir_model_sift_s20_dA_c8_w100x300.mat');
    %load('car_dir_d4_b13-19_c8_n12_w104-154.mat');
    load('car_dir_model_surfxhog_c5560e4.mat');
    models = [model_1,model_2,model_3,model_4,model_5,model_6,model_7,model_8,...
        model_9,model_10,model_11,model_12,model_1];
    
    for j=1:size(models,2)-1
        pred(j,:) = [models(j),models(j+1)];
    end
    [svmOut1,~,~] = svmpredict(1,pred_vec,model_1,'-b 1');
    %class = 1; %Default
    dir_guess = 1;
    for j=1:size(pred,1)
        [svmOut1,~,~] = svmpredict(1,pred_vec,pred(i,1),'-b 1');
        [svmOut2,~,~] = svmpredict(1,pred_vec,pred(i,2),'-b 1');
        if svmOut1~=svmOut2
            dir_guess = i;
            c = 1;
            break
        end
    end
    bins = cat(2,-1*[180:-30:30],0:30:180);
    
    if j==12 && dir_guess == 1
        fprintf('Not confident about orientation of object\n');
        c = 0;
    end
    dir_res = bins(dir_guess);
    fprintf('Estimated orientation is %d\n',dir_res);
    figure; imagesc(img_data_r); axis image; title(sprintf('D:%d C:%d',dir_res, c));
    %load('car_dir_model_sift_s20_dA_c8_w100x300.mat');    fprintf('Direction is %d\n',dir_res);
    
%     %Classify for first model_
%     [svmOut1,~,~] = svmpredict(1,pred_vec,model_1,'-b 1');
%     %Second model_
%     [svmOut2,~,~] = svmpredict(1,pred_vec,model_2,'-b 1');
%     if svmOut1 ~= svmOut2
%         %model_ belongs to class 1
%     else
%         %check if model_ belongs to class 2
%         [svmOut3,~,~] = svmpredict(1,pred_vec,model_3,'b 1');
%         if svmOut2 ~= svmOut3
%             %model_ belongs to class 2
%         else
%             %...
%         end
%     end
%     This reduces to the above
    
end