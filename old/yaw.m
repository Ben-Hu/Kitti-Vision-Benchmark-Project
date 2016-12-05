clear all; close all;
globals;
addpath(genpath('dpm'));

img = double(imread(fullfile(CAR_IMG_L, '000264.png')))/255;

P = getMatrix(TRAIN_CALIB_DIR,'P0','um_000000');
[K,R,t] = Krt_from_P(P);

a = deg2rad(0); %a in deg, yaw wrt observer
b = deg2rad(45);
c = deg2rad(0);
Rx = [1,0,0;0,cos(a),-sin(a);0,sin(a),cos(a)]; %roll
Ry = [cos(b),0,sin(b);0,1,0;-sin(b),0,cos(b)]; %pitch -- this + angle of orientation
Rz = [cos(c),-sin(c),0;sin(c),cos(c),0;0,0,1]; %yaw
Rf = Rx * Ry * Rz;

Px = K * [R * Rz, t]
%projection for yaw given angle of orientation 
tform = maketform('projective',Rf);
imw = imtransform(img, tform, 'bicubic','fill', 0);

data = load('dpm/VOC2010/car_final.mat');
model_ = data.model;
img = double(imread(fullfile(CAR_IMG_L, '000264.png')))/255;
detections = process(img, model_, -0.5);
showboxes(img, detections);

% figure;imagesc(img);axis image;hold on;
% for i=1:min(top_det,size(res,1))
%     bounds = res(i,1:4);
%     xl = bounds(1);
%     yt = bounds(2);
%     xr = bounds(3);
%     yb = bounds(4);
%     xp = [xl,xr,xr,xl,xl];
%     yp = [yb,yb,yt,yt,yb];
%     plot(xp,yp,'r','LineWidth',2);
%     text(xl,yt+fontsize/2,sprintf('Car-%d',i), 'Color',col,'FontSize',fontsize,'FontWeight','bold');
% end
% hold off;

 
% test = ones(10,10,10,10)
% figure; imshow(test,10)
% axis off
% view(3), axis vis3d
% camproj perspective, rotate3d on