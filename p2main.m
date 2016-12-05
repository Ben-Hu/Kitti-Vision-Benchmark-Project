clear all; close all;
globals;
%this script will plot a 3d point cloud with 3d bounding boxes
%as well as plotting a 2d image with road segmentation in addition to what '3d
%bounding boxes' would appear as in the 2d plane

imageName = 'um_000033.png'; %really good road example
imageName = 'umm_000035.png'; %bboxes went wrong
imageName = 'umm_000073.png'; %turning
imageName = 'umm_000077.png'; %single car
imageName = 'uu_000021.png'; %many cars

[~,imid,~] = fileparts(imageName);

img = double(imread(fullfile(TEST_DIR,imageName)))/256;
imgl = rgb2gray(double(imread(fullfile(TEST_DIR,imageName)))/256);
imgr = rgb2gray(double(imread(fullfile(R_TEST_DIR,imageName)))/256);

% img = double(imread(fullfile(TRAIN_ORIG_DIR,'um_000033.png')))/256;
% imgl = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,'um_000033.png')))/256);
% imgr = rgb2gray(double(imread(fullfile(R_TRAIN_ORIG_DIR,'um_000033.png')))/256);

dispmap = disparity(imgl,imgr);
P2 = getMatrix(TEST_CALIB_DIR,'P2',imid);
P3 = getMatrix(TEST_CALIB_DIR,'P3',imid);
[k2,r2,t2] = Krt_from_P(P2);
[k3,r3,t3] = Krt_from_P(P3);
dm = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));

data = load('dpm/VOC2010/car_final.mat');
model_d = data.model;
boxes = process(img, model_d, -0.5);
%showboxes(img, boxes);

f = k2(1,1);
py = size(dm,1)/2;
px = size(dm,2)/2;

[orientations, boxes] = getCars(img);

%TODO: pass orientations and watch it fail
ta = 0;
boxes_3d = boundingBox3(boxes,dm,f,py,px,[deg2rad(ta);deg2rad(ta);deg2rad(ta)]);

pc = getPointCloud(img,dm,f);
pcshow(pc, 'VerticalAxis','X','MarkerSize',300); hold on;
plotBoxes3(boxes_3d);

smodel = load('umall_lbp_model.mat');
smodel = smodel.model;
seg = segRoad(img, smodel);
r = img(:,:,1);
r(seg) = 1;
img(:,:,1) = r;

BM = boundarymask(seg);
figure; imshow(imoverlay(img,BM,'red')); hold on;
plotBoxes2(boxes_3d,dm,P2);


    