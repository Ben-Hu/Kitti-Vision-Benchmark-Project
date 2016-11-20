%% Classifier Training
clear all; close all;
globals;
%% Load training data-set
origListing = dir(fullfile(TRAIN_ORIG_DIR,'um_*.png'));
segListing = dir(fullfile(TRAIN_SEG_DIR,'um_road_*.png'));

origImgStack = zeros(370,1225);
segImgStack = zeros(370,1225);

for i=1:size(origListing,1)
    cImg = rgb2gray(single(imread(fullfile(TRAIN_ORIG_DIR,origListing(i).name)))/255);
    cImg = cImg(1:370,1:1225);
    origImgStack = cat(3,origImgStack,cImg);    
end

for i=1:size(segListing,1)
    cImg = rgb2gray(single(imread(fullfile(TRAIN_SEG_DIR,segListing(i).name)))/255);
    cImg = cImg(1:370,1:1225);
    segImgStack = cat(3,segImgStack,cImg);
end

allCV = [];
idxS = []; %zeros(size(origImgStack,3),1);
for k=1:size(origImgStack,3)
    oimg = origImgStack(:,:,i);
    c = mat2cell(oimg, 37*ones(1,10), 25*ones(1,49));
    cv = zeros(size(c,1)*size(c,2),size(c{1,1},1)*size(c{1,1},2));
    
    simg = segImgStack(:,:,i);
    rPixVal = max(reshape(simg,1,[]));
    smask = simg(:,:) >= rPixVal;
    cs = mat2cell(smask, 37*ones(1,10), 25*ones(1,49));
    cvs = zeros(size(cs,1)*size(cs,2),size(cs{1,1},1)*size(cs{1,1},2));
    sMax = rPixVal * 37 * 25;
    %sum min = 0;
   
    %each row of cv corresponds to a vectorized image patch
    for i=1:size(c,1)
        for j=1:size(c,2)
            %for each image patch, add to the vector cumulation
            cv(i*j,:) = reshape(c{i,j},1,[]);
            %classify each image patch based on smask sum val
            %take the weighted sum of the pre-segmented training image 
            %classify based on the aggregate pixel value - 
            cSum = cs{i,j};
            if (sMax - cSum) < 50 
                idxS = cat(1,idxS,2);
            else
                idxS = cat(1,idxS,1);
            end
        end
    end
    allCV = cat(1,allCV,cv);
end

[idx,C] = kmeans(cv,2);

model = fitcsvm(cv,idx);
model2 = fitcsvm(allCV,idxS);

% divide a test image with window fn
xval = rgb2gray(double(imread('data_road/testing/image_2/um_000031.png'))/255);
xval = xval(1:370,1:1225);
xc = mat2cell(xval, 37*ones(1,10), 25*ones(1,49));
xcv = zeros(size(xc,1)*size(xc,2),size(xc{1,1},1)*size(xc{1,1},2));

% make vectors from window patches
for i=1:size(xc,1)
    for j=1:size(xc,2)
        xcv(i*j,:) = reshape(xc{i,j},1,[]);
    end
end

%for each vector in xcv (image patch, classify it)
labels = zeros(size(xcv,1),1);
for i=1:size(xcv,1)
    labels(i) = predict(model2,xcv(i,:));
end

%now that all image patches are classified, assign label value to
%corresponding block and reconstruct the image
for ind=1:size(labels,1)
    [i,j] = ind2sub([size(c,1),size(c,2)],ind)
    c{i,j}(:,:) = labels(ind);
end
res = cell2mat(c);

figure; imagesc(res); axis image; colormap gray;



