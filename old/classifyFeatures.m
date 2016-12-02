%% Classifier Training
clear all; close all;
globals;
%run vlfeat-0.9.20/toolbox/vl_setup.m

%% Load training data-set
trainAll = 0;
if trainAll == 0
    origListing = dir(fullfile(TRAIN_ORIG_DIR,'um_000000.png'));
    segListing = dir(fullfile(TRAIN_SEG_DIR,'um_road_000000.png'));
elseif trainAll == 1
    origListing = dir(fullfile(TRAIN_ORIG_DIR,'um_*.png'));
    segListing = dir(fullfile(TRAIN_SEG_DIR,'um_road_*.png'));
else
   origListing = dir(fullfile(TRAIN_ORIG_DIR,'*.png'));
   segListing = dir(fullfile(TRAIN_SEG_DIR,'*road_*.png'))
end

imgDim = [360,1220];

origImgStack = [];
segImgStack = []; 
for i=1:size(origListing,1)
    cImg = rgb2gray(single(imread(fullfile(TRAIN_ORIG_DIR,origListing(i).name)))/255);
    cImg = cImg(1:imgDim(1),1:imgDim(2));
    origImgStack = cat(3,origImgStack,cImg);    
end

for i=1:size(segListing,1)
    cImg = rgb2gray(single(imread(fullfile(TRAIN_SEG_DIR,segListing(i).name)))/255);
    cImg = cImg(1:imgDim(1),1:imgDim(2));
    segImgStack = cat(3,segImgStack,cImg);
end

id = [];
cv = [];
for k=1:size(origImgStack,3)
    simg = segImgStack(:,:,k);
    rPixVal = max(reshape(simg,1,[]));
    smask = simg(:,:) >= rPixVal;
    
    [keypoints,desc] = vl_sift(origImgStack(:,:,k));
    desc = double(desc)';
    keypoints = round(keypoints)';
    cv = cat(1,cv,desc);
    
    for i=1:size(keypoints,1)
        if smask(keypoints(i,2),keypoints(i,1)) == 1
            id = cat(1,id,1);
        else
            id = cat(1,id,0);
        end
    end
end

model = fitcsvm(cv,id);

%test = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/255);
test = rgb2gray(single(imread('data_road/testing/image_2/um_000031.png'))/255);
test = test(1:imgDim(1),1:imgDim(2));
[tkeypoints,tdesc] = vl_sift(test);

tcv = double(tdesc)';
tkeypoints = round(tkeypoints)';

labels = predict(model,tcv);

res = zeros(imgDim(1),imgDim(2));
for i=1:size(labels,1)
    px = tkeypoints(i,2);
    py = tkeypoints(i,1);
    res(px,py) = labels(i);
end

figure; imagesc(res); axis image; colormap gray;

figure
BW = boundarymask(L);
imshow(imoverlay(im,BW,'cyan'),'InitialMagnification',67)

