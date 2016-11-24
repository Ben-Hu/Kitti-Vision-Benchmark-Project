%% Classifier Training
clear all; close all;
globals;
run vlfeat-0.9.20/toolbox/vl_setup.m
addpath(genpath('libsvm'));

im_siz = [360,1220];
window = [10,10];
windowFac = [im_siz(1)/window(1),im_siz(2)/window(2)];

%360x1220, 20x20 window

%% Load training data- + preprocess
trainingSet = 1;
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
    cImg = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,origListing(i).name)))/255);
    %base smoothing
    cImg = conv2(cImg(1:im_siz(1),1:im_siz(2)),fspecial('Gaussian', [25,25], 0.5), 'same');
    origImgStack = cat(3,origImgStack,cImg);    
end

for i=1:size(segListing,1)
    cImg = rgb2gray(double(imread(fullfile(TRAIN_SEG_DIR,segListing(i).name)))/255);
    %base smoothing
    cImg = conv2(cImg(1:im_siz(1),1:im_siz(2)),fspecial('Gaussian', [25,25], 0.5), 'same');
    segImgStack = cat(3,segImgStack,cImg);
end

%% Prepare training data for classifier
allCV = [];
idxS = [];
for k=1:size(origImgStack,3)
    %(pre)instantiations
    oimg = origImgStack(:,:,k);
    c = mat2cell(oimg, window(1)*ones(1,windowFac(1)), window(2)*ones(1,windowFac(2)));
    cvP = [];
    cvN = [];
    idxP = [];
    idxN = [];
    
    simg = segImgStack(:,:,k);
    rPixVal = max(reshape(simg,1,[]));
    smask = simg(:,:) >= rPixVal;
    cs = mat2cell(smask, window(1)*ones(1,windowFac(1)), window(2)*ones(1,windowFac(2)));
    %cvs = zeros(size(cs,1)*size(cs,2),size(cs{1,1},1)*size(cs{1,1},2));
    sMax = 1 * window(1) * window(2); 
    
    maxcSum = 0;
    mincSum = inf;
    
    %each row of cv corresponds to a vectorized image patch for cur image
    for i=1:size(c,1)
        for j=1:size(c,2)
            %for each image patch, add to the vector cumulation
            %normalize the image patch data
            %classify each image patch based on smask sum val:
            %take the weighted sum of the ground truth segmentation mask &
            %classify based on the aggregate pixel value within window area 
            cSum = sum(reshape(cs{i,j},1,[]));
            
            if cSum > maxcSum
                maxcSum = cSum;
            end
            if cSum < mincSum
                mincSum = cSum;
            end
           
            %May been to adjust threshold for classification, 
            %1/2 road pix && balancing number of neg samples now
            if cSum >= sMax/2 
                idxP = cat(1,idxP,1);
                tcv = reshape(c{i,j},1,[]);
                normFactor = max(abs(tcv));
                cvP = cat(1,cvP,tcv/normFactor);
            else
                idxN = cat(1,idxN,-1);
                tcv = reshape(c{i,j},1,[]);
                normFactor = max(abs(tcv));
                cvN = cat(1,cvN,tcv/normFactor);
            end
        end
    end
    %equalize neg & pos training samples if needed
    if size(cvN,1) > size(cvP,1)
        negSample = randsample(size(cvN,1),size(cvP,1));
        cvN = cvN(negSample(:),:);
        idxN = idxN(negSample(:),:);
    elseif size(cvP,1) > size(cvN,1)
        posSample = randsample(size(cvP,1),size(cvN,1));
        cvP = cvP(posSample(:),:);  
        idxP = idxP(posSample(:),:);
    end
    idxS = cat(1,idxS,cat(1,idxP,idxN));
    cv = cat(1,cvP,cvN);
    allCV = cat(1,allCV,cv);
end

% [idxS,C] = kmeans(allCV,2);
% model2 = fitcsvm(allCV,idxS);
model = svmtrain(idxS,allCV,'-c 0 -t 2 -g 0.07 -c 10 -b 1');

%% Testing the model
% divide a test image with window fn
xval = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/255);
%xval = rgb2gray(double(imread('data_road/testing/image_2/um_000031.png'))/255);
xval = xval(1:im_siz(1),1:im_siz(2));
% xc = mat2cell(xval, 20*ones(1,windowFac(1)), 20*ones(1,windowFac(2)));
% xcv = zeros(size(xc,1)*size(xc,2),size(xc{1,1},1)*size(xc{1,1},2));
% 
% % make vectors from window patches
% for i=1:size(xc,1)
%     for j=1:size(xc,2)
%         xcv(i*j,:) = reshape(xc{i,j},1,[]);
%     end
% end
% 
% %for each vector in xcv (image patch, classify it)
% %labels = predict(model2,xcv)
% labels=[];
% for i=1:size(xcv,1)
%     [svmOut, svmACC, svm_dec] = svmpredict(1,xcv(i,:),model,'-b 1');
%     labels=cat(1,labels,svmOut);
% end
% 
% %now that all image patches are classified, assign label value to
% %corresponding block and reconstruct the image
% for ind=1:size(labels,1)
%     [i,j] = ind2sub([size(c,1),size(c,2)],ind);
%     c{i,j}(:,:) = labels(ind);
% end
% res = cell2mat(c);

% figure; imagesc(res); axis image; colormap gray;

%may want to tune this to get better run time, e.g. classify pixel
%groups depending on the amount of precision/accuracy wanted.

classified = zeros(size(xval));
%scored = zeros(size(xval));
k = 10;
for xp = 1:size(xval,1)
    for yp = 1:size(xval,2)
        imgPatch = getPatch(xval,xp,yp,k);
        imgPatch = reshape(imgPatch,1,[]);
        [svmOut, svmACC,svm_dec] = svmpredict(1,imgPatch,model,'-b 0 -q');
        classified(xp,yp) = svmOut;
        %scored(xp,yp) = svm_dec(2);
    end
end

figure;imagesc(classified);axis image;colormap gray;
%figure;imagesc(scored);axis image;colormap gray;

% - Check machine learning keys/parameters   
% - try and get an even number of road/non-road training examples.
    %-random sampling of features/patches accomplishes - statistical error
    %-try diff features - e.g. sliding window lec. gradient orientation,
    %etc. pix. vals 2d/3d    
% - SVM labels should be -1 +1 (apparently they hate 0,1 depending on library)
% - Input data must be normalised
% 	each columns of X should have a mean of 0 and a standard deviation of 1 (for example)
% 	Or min value -1 max value +1
% try decision forests - easier setup

%figure; imagesc(res); axis image; colormap gray;



