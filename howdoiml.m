%% how do i do the machine learnings
clear all; close all;
oimg = single(imread('data_road/training/image_2/um_000000.png'))/255;
oimg = rgb2gray(oimg);
timg = single(imread('data_road/training/gt_image_2/um_road_000000.png'))/255;
timg = rgb2gray(timg);

c = mat2cell(oimg, 25*ones(1,15), 23*ones(1,54));
cv = zeros(size(c,1)*size(c,2),size(c{1,1},1)*size(c{1,1},2));

%each row of cv corresponds to a vectorized image patch
for i=1:size(c,1)
    for j=1:size(c,2)
        cv(i*j,:) = reshape(c{i,j},1,[]);
    end
end

[idx,C] = kmeans(cv,2);
%take the weighted sum of the pre-segmented training image 
%classify based on the aggregate pixel value - 
%maybe instead of a binary classification scheme, a ternary scheme would 
%be better (partials)

model = fitcsvm(cv,idx);

% divide a test image
xval = double(imread('data_road/training/image_2/um_000031.png'))/255;
xval = rgb2gray(xval);
xc = mat2cell(xval, 25*ones(1,15), 23*ones(1,54));
xcv = zeros(size(c,1)*size(c,2),size(c{1,1},1)*size(c{1,1},2));

for i=1:size(xc,1)
    for j=1:size(xc,2)
        xcv(i*j,:) = reshape(xc{i,j},1,[]);
    end
end

labels = zeros(size(xcv,1),1);
%for each vector in xcv (image patch, classify it)
for i=1:size(xcv,1)
    labels(i) = predict(model,xcv(i,:));
end

%now that all image patches are classified, assign label value to
%corresponding block and reconstruct the image
for ind=1:size(labels,1)
    [i,j] = ind2sub([size(c,1),size(c,2)],ind)
    c{i,j}(:,:) = labels(ind);
end

res = cell2mat(c);
figure; imagesc(res); axis image; colormap gray;



