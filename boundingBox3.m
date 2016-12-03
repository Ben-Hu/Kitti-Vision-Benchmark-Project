%function [img_boxes]=boundingBox3(boxes,dm,f)
img = double(imread(fullfile(TRAIN_ORIG_DIR,'um_000033.png')))/256;
imgl = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,'um_000033.png')))/256);
imgr = rgb2gray(double(imread(fullfile(R_TRAIN_ORIG_DIR,'um_000033.png')))/256);
dispmap = disparity(imgl,imgr);
P2 = getMatrix(TEST_CALIB_DIR,'P2','uu_000073');
P3 = getMatrix(TEST_CALIB_DIR,'P3','uu_000073');
[k2,r2,t2] = Krt_from_P(P2);
[k3,r3,t3] = Krt_from_P(P3);
dm = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));

data = load('dpm/VOC2010/car_final.mat');
model_d = data.model;
boxes = process(img, model_d, -0.5);
showboxes(img, boxes);

f = k2(1,1);
py = size(dm,2)/2;
px = size(dm,1)/2;

img_boxes = [];
for i=1:1%size(boxes,1)
    bounds = boxes(i,1:4);
    y1 = round(bounds(1));
    x1 = round(bounds(2));
    y2 = round(bounds(3));
    x2 = round(bounds(4));
    %apply a gaussian element-wise over the patch of the box
    dm_patch = dm(x1:x2, y1:y2); 
    
    %Mask out the depth information of the car using active contour models
    %the max and min of the masked depth information 
    %diameter of 1/2 min dimension image so we get enough coverage
    %initially for the start mask, using a circle mask
    elem_siz = round(min(size(dm_patch,1),size(dm_patch,2))/4); 
    element = fspecial('disk',elem_siz)>0;
    ex = round((size(dm_patch,1)-size(element,1))/2);
    ey = round((size(dm_patch,2)-size(element,2))/2);
    element = padarray(element, [ex ey], 0);
    element = element(1:size(dm_patch,1),1:size(dm_patch,2));
    
    %Get the active contour segmentation of the car depth information
    act = activecontour(dm_patch, element);
    dm_car = dm_patch .* act;
    
    %Filter out any outlier depth information we still have
    dm_car(dm_car<0) = 0;
    
    figure; imagesc(act); axis image; colormap gray;
    figure; imagesc(dm_patch); axis image; colormap gray;
    figure; imagesc(dm_patch.*act); axis image; colormap gray;
    
    %for each corner of the box, find the world coordinates of the 
    %front face of the car, minimum depth in our mask of non-zero value
    front_Z = min(dm_car(dm_car(:)~=0));
    front_box = [x1,y1,front_Z;x1,y2,front_Z;...
    x2,y1,front_Z;x2,y2,front_Z];
    for j=1:size(front_box,1)
        x = front_box(j,1);
        y = front_box(j,2);
        Z = front_box(j,3);
        new_y = Z * ((y - px)/f);
        new_x = Z * ((x - py)/f);
        front_box(j,1) = new_x;
        front_box(j,2) = new_y;
    end
    
    back_Z = max(dm_car(:));
    back_box = [x1,y1,back_Z;x1,y2,back_Z;...
    x2,y1,back_Z;x2,y2,back_Z];
    for j=1:size(back_box,1)
        x = back_box(j,1);
        y = back_box(j,2);
        Z = back_box(j,3);
        new_y = Z * ((y - px)/f);
        new_x = Z * ((x - py)/f);
        back_box(j,1) = new_x;
        back_box(j,2) = new_y;
    end
    carbox.back_box = back_box;
    carbox.front_box = front_box;
    img_boxes = cat(1,img_boxes,carbox);
end

%end