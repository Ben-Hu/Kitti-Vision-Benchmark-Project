clear all; close all;
globals;
P = getMatrix(TRAIN_CALIB_DIR,'P0','um_000000');
[K,R,t] = Krt_from_P(P);

a = 30; %a in deg, yaw wrt observer
Rz = [cos(a),-sin(a),0;sin(a),cos(a),0;0,0,1]

Px = K * [R * Rz, t]
%projection for yaw given angle of orientation 

test = ones(10,10,10,10)
figure; imshow(test,10)
axis off
view(3), axis vis3d
camproj perspective, rotate3d on