
%% Classifier Training
clear all; close all;
globals;
%run vlfeat-0.9.20/toolbox/vl_setup.m
addpath(genpath('libsvm'));

%fixing image dimensions since training data has images of different
%resolutions
im_siz = [360,1220];
window = [20,20];
windowFac = [im_siz(1)/window(1),im_siz(2)/window(2)];

%360x1220, 20x20 window

%% Load training data- + preprocess
trainingSet = 2;
if trainingSet == 0
    origListing = dir(fullfile(TRAIN_ORIG_DIR,'um_000000.png'));
    segListing = dir(fullfile(TRAIN_SEG_DIR,'um_road_000000.png'));
elseif trainingSet == 1    
    origListing = dir(fullfile(TRAIN_ORIG_DIR,'um_*.png'));
    segListing = dir(fullfile(TRAIN_SEG_DIR,'um_road_*.png'));
else
    origListing = dir(fullfile(TRAIN_ORIG_DIR,'*.png'));
    segListing = dir(fullfile(TRAIN_SEG_DIR,'*road_*.png'));
end

origImgStack = []; 
segImgStack = []; 

for i=1:size(origListing,1)
    cImg = double(imread(fullfile(TRAIN_ORIG_DIR,origListing(i).name)))/255;
    %base smoothing
    cImg = cImg(1:im_siz(1),1:im_siz(2),:);
    %cImg = conv2(cImg,fspecial('Gaussian', [25,25], 0.5), 'same');
    origImgStack = cat(4,origImgStack,cImg);    
end

for i=1:size(segListing,1)
    %cImg = rgb2gray(double(imread(fullfile(TRAIN_SEG_DIR,segListing(i).name)))/255);
    cImg = double(imread(fullfile(TRAIN_SEG_DIR,segListing(i).name)))/255;
    cImg = cImg(:,:,3); %Road segment channel
    %base smoothing
    cImg = cImg(1:im_siz(1),1:im_siz(2));
    %cImg = conv2(cImg,fspecial('Gaussian', [25,25], 0.5), 'same');
    segImgStack = cat(3,segImgStack,cImg);
end

%% Prepare training data for classifier
tdA = [];
clA = [];
for k=1:size(origImgStack,4)
    tdP = [];
    tdN = [];
    clP = [];
    clN = [];
    cur_img = origImgStack(:,:,:,k);
    simg = segImgStack(:,:,k);
    rPixVal = max(reshape(simg,1,[]));
    smask = simg(:,:) >= rPixVal;
    %figure; imagesc(smask); axis image; colormap gray;
    
    [labels,num_pix] = superpixels(cur_img,300);
    %BM = boundarymask(L);
    %figure; imshow(imoverlay(cur_img,BM,'cyan'),'InitialMagnification',67)

    %color_info = zeros(size(cur_img));
    idx = label2idx(labels);
    x_siz = size(cur_img,1);
    y_siz = size(cur_img,2);
    %For each superpixel, compute the mean color of each channel within the
    %super pixel area
    %and compute the HoG feature descriptor for the superpixel area
    for i=1:num_pix
        %Vector indices for each color channel
        r_idx = idx{i};
        g_idx = idx{i}+x_siz*y_siz;
        b_idx = idx{i}+2*x_siz*y_siz;
        %Assign the superpixel pixels in mean_color_info to the mean color value
        %of the pixels within each superpixel
        %color_info(r_idx) = mean(cur_img(r_idx));
        %color_info(g_idx) = mean(cur_img(g_idx));
        %color_info(b_idx) = mean(cur_img(b_idx));

        %since super pixels are all different sizes, uses a histogram of color
        %values
        bins = 0:0.05:1;
        hist_r = histcounts(cur_img(r_idx), bins);
        hist_g = histcounts(cur_img(g_idx), bins);
        hist_b = histcounts(cur_img(b_idx), bins);

        %for every index in the superpixel, find the x and y coords
        %can use r_idx, will be the same for g and b channels in their
        %respective dimension
        [x,y] = ind2sub(size(cur_img),r_idx);
        x_max = max(x); x_min = min(x);
        y_max = max(y); y_min = min(y);

        %best fitting box that bounds the area of the superpixel is given by
        %these max/min coordinates
        pix_box = cur_img(x_min:x_max, y_min:y_max);
        %resize the box so the hog feature vectors we get are a standard length
        %might be bad
        squished = imresize(pix_box, [20,20]);
        box_hog = extractHOGFeatures(squished,'NumBins', 9, 'CellSize', [6, 6]);

        %Local Binary Patterns - texture features
        %More neighbours = more detail around each pix.
        %Much better results adding LBP information to feature descriptor
        lbp = extractLBPFeatures(squished, 'NumNeighbors', 12);
        
        feat_vec = cat(2, hist_r, hist_g, hist_b, box_hog, lbp);
        normFactor = max(abs(feat_vec));
        
        %Find what class this feature belongs to 
        sMax = size(idx{i},1) * rPixVal;
        cSum = sum(smask(idx{i}));
        if cSum >= sMax/2 
            tdP = cat(1,tdP,feat_vec/normFactor);
            clP = cat(1,clP,1);
        else
            tdN = cat(1,tdN,feat_vec/normFactor);
            clN = cat(1,clN,-1);
        end
        
    end
 
    %equalize neg & pos training samples if needed
    numNeg = size(tdN,1);
    numPos = size(tdP,1);
    if size(tdN,1) > size(tdP,1)
        negSample = randsample(size(tdN,1),size(tdP,1));
        tdN = tdN(negSample(:),:);
        clN = clN(negSample(:),:);
    elseif size(tdP,1) > size(tdN,1)
        posSample = randsample(size(tdP,1),size(tdN,1));
        tdP = tdP(posSample(:),:);  
        clP = clP(posSample(:),:);
    end
    
    clA = cat(1,clA,clP,clN);
    tdA = cat(1,tdA,tdP, tdN);
end
tdA = double(tdA);
clA = double(clA);

model = svmtrain(clA,tdA,'-c 0 -t 2 -g 0.07 -c 10 -b 1');


