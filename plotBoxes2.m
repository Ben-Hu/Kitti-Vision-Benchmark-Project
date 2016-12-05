%function plotBoxes2(boxes, dm, P)
%Plots all 3d bounding boxes given input struct from boundingBox3
%Input: struct output from boundingBox3 function
clear all; close all;
globals;
img = double(imread(fullfile(TRAIN_ORIG_DIR,'um_000033.png')))/256;
imgl = rgb2gray(double(imread(fullfile(TRAIN_ORIG_DIR,'um_000033.png')))/256);
imgr = rgb2gray(double(imread(fullfile(R_TRAIN_ORIG_DIR,'um_000033.png')))/256);
dispmap = disparity(imgl,imgr);
P2 = getMatrix(TEST_CALIB_DIR,'P2','um_000073');
P3 = getMatrix(TEST_CALIB_DIR,'P3','um_000073');
[k2,r2,t2] = Krt_from_P(P2);
[k3,r3,t3] = Krt_from_P(P3);
dm = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));
data = load('dpm/VOC2010/car_final.mat');
model_d = data.model;
boxes = process(img, model_d, -0.5);
P = P2;
%have boxes, dm, P

[k,r,t] = Krt_from_P(P);
f = k(1,1);
px = size(dm,1)/2;
py = size(dm,2)/2;
boxes_3d = boundingBox3(boxes,dm,f,px,py,0,0,0);
figure; imagesc(img); axis image; hold on;


xoff = -420;
yoff = 420;
for i=1:size(boxes_3d,1)
    cur_boxes = boxes_3d(i,:);
    front = cur_boxes.front_box;
    back = cur_boxes.back_box;
    xl = front(1,1); %x1,y1 
    yb = front(1,2); %x1,y2
    xr = front(3,1); %x2,y1
    yt = front(2,2); %x2,y2
    zf = front(1,3);
    zb = back(1,3);
    
    pixf1 = P * [xl;yb;zf;1];
    pixf1 = pixf1/pixf1(3);
    x1 = pixf1(1) + xoff;
    y1 = pixf1(2) + yoff;
    
    pixf2 = P * [xr;yt;zf;1];
    pixf2 = pixf2/pixf2(3);
    x2 = pixf2(1) + xoff;
    y2 = pixf2(2) + yoff;
    
    pixb1 = P * [xl;yb;zb;1];
    pixb1 = pixb1/pixb1(3);
    x1b = pixb1(1) + xoff;
    y1b = pixb1(2) + yoff;
    
    pixb2 = P * [xr;yt;zb;1];
    pixb2 = pixb2/pixb2(3);
    x2b = pixb2(1) + xoff;
    y2b = pixb2(2) + yoff;
   
    xpb = [x1b,x2b,x2b,x1b,x1b];
    ypb = [y1b,y1b,y2b,y2b,y1b];
    plot(ypb,xpb,'g','LineWidth',2);
    
    xp = [x1,x2,x2,x1,x1];
    yp = [y1,y1,y2,y2,y1];
    plot(yp,xp,'r','LineWidth',2);

    plot([y1,y1b],[x1,x1b],'r','LineWidth',2);
    plot([y2,y2b],[x1,x1b],'r','LineWidth',2);
    plot([y1,y1b],[x2,x2b],'r','LineWidth',2);
    plot([y2,y2b],[x2,x2b],'r','LineWidth',2);
    fontsize = 10;
    text(double(y1),double(x1)+fontsize/2,sprintf('Car-%d',i), 'Color','r','FontSize',fontsize,'FontWeight','bold');
end



%end