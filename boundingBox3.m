%function [world_boxes]=boundingBox3(boxes,dm,f)

imgl = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,'um_000033.png')))/256);
imgr = rgb2gray(double(imread(fullfile(R_TRAIN_ORIG_DIR,'um_000033.png')))/256);
dispmap = disparity(imgl,imgr);
P2 = getMatrix(TEST_CALIB_DIR,'P2','uu_000073');
P3 = getMatrix(TEST_CALIB_DIR,'P3','uu_000073');
[k2,r2,t2] = Krt_from_P(P2);
[k3,r3,t3] = Krt_from_P(P3);
dm = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));

f = k2(1,1);
py = size(dm,1)/2;
px = size(dm,2)/2;

world_boxes = [];
for i=1:size(boxes,1)
    bounds = boxes(i,1:4);
    y1 = bounds(1);
    x1 = bounds(2);
    y2 = bounds(3);
    x2 = bounds(4);
    box_points = [x1,y1,dm(x1,y1);x1,y2,dm(x1,y2);...
        x2,y1,dm(x2,y1);x2,y2,dm(x2,y2)];
    %for each corner of the box, find the world coordinates
    for j=1:size(box_points,1)
        x = box_points(j,1);
        y = box_points(j,2);
        Z = box_points(j,3);
        new_y = Z * ((y - px)/f);
        new_x = Z * ((x - py)/f);
        box_points(j,1) = new_x;
        box_points(j,2) = new_y;
    end
    world_boxes = cat(3,world_boxes,box_points);
end

%end