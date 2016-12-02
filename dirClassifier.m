clear all; close all;
globals;
%addpath(genpath('kitti_obj_devkit'));
%using modified readLabels to take raw img_idx input
data_set = 2;
if data_set == 0
    label_list = dir(fullfile(LABEL_DIR,'000063.txt'));
elseif data_set == 1
    label_list = dir(fullfile(LABEL_DIR,'00006*.txt'));
elseif data_set == 2
    label_list = dir(fullfile(LABEL_DIR,'0000*.txt'));
else
    label_list = dir(fullfile(LABEL_DIR,'*.txt'));
end
%process labels for each image
tdA = [];
dirA = [];
%For tuning analysis
img_siz_data = [];
for i=1:size(label_list,1)%63:63%
    [~,idx,~] = fileparts(label_list(i).name);
    obj = readLabel(LABEL_DIR, idx);
    img = single(imread(fullfile(CAR_IMG_L, sprintf('%s.png', idx))))/255;
    
    img_vec = [];
    %process each detection in image
    for j=1:size(obj,2)%3:3%
        c_obj = obj(j);
        %xl, yt, xr, yb
        c_box = max(round([c_obj.y1,c_obj.y2,c_obj.x1,c_obj.x2]),1);
        c_alpha = c_obj.alpha;
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
        
        %figure; imagesc(grad_mag); axis image; colormap gray
        %figure; imagesc(img_data); axis image; colormap gray
        %figure; imagesc(img_data_r); axis image; colormap gray
        
        %SHAPE
        %Morphological disk blurring for general shape information
        element = strel('disk', 5);
        supp = imopen(img_data_r_bw, element);
        %figure; imagesc(supp); axis image; colormap gray
       
        feat_vec = cat(2,c_hog,reshape(grad_mag,1,[]),reshape(supp,1,[]));
        norm_factor = max(abs(feat_vec));
        img_vec = cat(1,img_vec,feat_vec/norm_factor);
        
        %idx
        dirA = cat(1, dirA, rad2deg(c_alpha));
        %SIFT(features)
        %[keypoints,desc] = vl_sift(img_data_r);
        %[keypoints_g,desc_g] = vl_sift(mag_grad);
        %there are alot of keypoints, need to extract relevant ones
        %figure; imagesc(mag_grad); axis image; colormap gray;   
        
        %find which feature descriptor map to which items by using
        %reference images/descriptors for say a license plate, tire, etc.
        %and only using the descriptors of minimum euclidean distance,
        %depending on the angle of orientation we are binning for.          
    end
    tdA = cat(1,tdA,img_vec);
end

ref_x1 = mode(img_siz_data(:,1));
ref_y1 = mode(img_siz_data(:,2));
ref_x2 = mean(img_siz_data(:,1));
ref_y2 = mean(img_siz_data(:,2));

%save('obj_tdA.mat', 'tdA');
%save('obj_dirA.mat', 'dirA');

%BINNING DATA 
%Equal sampling per bin
%Note: Label dataset alpha has the domain L:Pos R:Neg 0:F 180:B

%(12)150:180  %180 gets binned here
%(11)120:150
%(10)90:120
%(9)60:90
%(8)30:60
%(7)0:30

%(6)0:-30
%(5)-30:-60
%(4)-60:-90
%(3)-90:-120
%(2)-120:-150
%(1)-150:180

bins = cat(2,-1*[180:-30:30],0:30:180);
binned = discretize(dirA,bins);

for i=1:size(bins,2)
    eval(sprintf('bin%d = [];',i));
end
for i=1:size(bins,2)
    eval(sprintf('bin%d = cat(2, bin%d, tdA(find(binned==%d),:));',i,i,i));
end

cv = cat(1, bin1, bin2);
idx = cat(1, ones(size(bin1,1),1), zeros(size(bin2,1),1)); %-1*ones(size(bin2,1),1));

test = svmtrain(idx,cv,'-c 0 -t 2 -g 0.07 -c 10 -b 1');

