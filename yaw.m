clear all; close all;
globals;
P = getMatrix(TRAIN_CALIB_DIR,'P0','um_000000');
[K,R,t] = Krt_from_P(P);

a = 30; %a in deg, yaw wrt observer
b = 30;
c = 30;
Rx = [1,0,0;0,cos(a),-sin(a);0,sin(a),cos(a)]; %roll
Ry = [cos(b),0,sin(b);0,1,0;-sin(b),0,cos(b)]; %pitch
Rz = [cos(c),-sin(c),0;sin(c),cos(c),0;0,0,1]; %yaw

Px = K * [R * Rz, t]
%projection for yaw given angle of orientation 

img = double(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/256;
tform = maketform('projective',Ry);
imw = imtransform(img, tform, 'bicubic','fill', 0);
figure; imagesc(imw); axis image

test = ones(10,10,10,10)
figure; imshow(test,10)
axis off
view(3), axis vis3d
camproj perspective, rotate3d on