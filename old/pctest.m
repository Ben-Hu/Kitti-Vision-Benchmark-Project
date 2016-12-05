clear all; close all;
globals;
simg = double(imread(fullfile(TRAIN_SEG_DIR,'um_road_000000.png')))/255;
simg = simg(:,:,3);

rPixVal = max(reshape(simg,1,[]));
smask = simg(:,:) >= rPixVal;

img = double(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/256;

imgl = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/256);
imgr = rgb2gray(double(imread(fullfile(R_TRAIN_ORIG_DIR,'um_000000.png')))/256);
dispmap = disparity(imgl,imgr);
P2 = getMatrix(TEST_CALIB_DIR,'P2','uu_000073');
P3 = getMatrix(TEST_CALIB_DIR,'P3','uu_000073');
[k2,r2,t2] = Krt_from_P(P2);
[k3,r3,t3] = Krt_from_P(P3);
depth = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));


%img = img .* smask;

im_siz = [360,1220];
img = img(1:im_siz(1),1:im_siz(2),:);

% crop depth just in case
depth = depth(1:im_siz(1),1:im_siz(2));

% All index permutations
[X,Y] = meshgrid(1:im_siz(1),1:im_siz(2));
idx=cat(2,X',Y');
idx=reshape(idx,[],2);

% Form the point coordinate matrix
pc = zeros(size(idx,1),3);
for i=1:size(idx,1)
    if img(idx(i,1),idx(i,2)) ~= 0
        pc(i,:) = [idx(i,1),idx(i,2),depth(idx(i,1),idx(i,2))];
    end
end


py = size(img,1)/2;
px = size(img,2)/2;
f = k2(1,1);

for i=1:size(pc,1)
    x = pc(i,1);
    y = pc(i,2);
    Z = pc(i,3);
    new_y = Z * ((y - px)/f);
    new_x = Z * ((x - py)/f);
    pc(i,1) = new_x;
    pc(i,2) = new_y;
end

% Build the 3d point cloud
colors = reshape(img,[],3);
pc_o = pointCloud(pc, 'Color', colors);

% show the point cloud
pcshow(pc_o);