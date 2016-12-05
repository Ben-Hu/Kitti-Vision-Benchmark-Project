clear all; close all;
globals;
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
%showboxes(img, boxes);

f = k2(1,1);

[orientations, boxes] = getCars(img);
boxes_3d = boundingBox3(boxes,dm,f);
pc = getPointCloud(img,dm,f);
pcshow(pc, 'VerticalAxis','X','MarkerSize',300); hold on;
plotBoxes3(boxes_3d);

%plotBoxes2(boxes_3d,img);


    