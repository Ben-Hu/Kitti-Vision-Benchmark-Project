clear all; close all
globals;
addpath(genpath('dpm'));
data = load('dpm/VOC2010/car_final.mat');
model = data.model;

data_r = load('models_lsvm/car_2.mat');
model_r = data_r.model;

%im = rgb2gray(single(imread('data_road/testing/image_2/um_000031.png'))/255);
im = single(imread('data_road/training/image_2/um_000013.png'))/255;

im = single(imread('obj_training/000010.png'))/255;
imr = im;

figure; imagesc(im); axis image; 

% upsample the image to better detect smaller objects 
% TODO: tune f param
% f = 1.5;
% imr = imresize(im,f); 

% TODO: tune threshold, using model default
[ds, bs] = imgdetect(imr, model, model.thresh);

%TODO: tune NMS thresholds
nms_thresh = 0.5;
top = nms(ds, nms_thresh);
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end

% if ~isempty(ds)
%     % resize back
%     ds(:, 1:end-2) = ds(:, 1:end-2)/f;
%     bs(:, 1:end-2) = bs(:, 1:end-2)/f;
% end;

plotBoxes(im, ds(top,:), 3, 'r');

%TODO: get viewpoints + HoG(or other feature) over detection
%for classifier training data
%6 classifiers 360/2 180/2 90/2 45/2 intervals
%Y = binary viewpoint
%X = feature descriptor (need scale invariance)

function plotBoxes(img,res,top_det,col)
    %res = [res,~] from dpm
    %top_det params are for limiting the plots to the top detections
    %for debugging purposes
    fontsize = 10;
    figure;imagesc(img);axis image;hold on;
    for i=1:min(top_det,size(res,1))
        bounds = res(i,1:4);
        xl = bounds(1);
        yt = bounds(2);
        xr = bounds(3);
        yb = bounds(4);
        xp = [xl,xr,xr,xl,xl];
        yp = [yb,yb,yt,yt,yb];
        plot(xp,yp,'r','LineWidth',2);
        text(xl,yt+fontsize/2,sprintf('Car-%d',i), 'Color',col,'FontSize',fontsize,'FontWeight','bold');
    end
    hold off;
end

%simpler detections
% clear all; close all;
% globals;
% addpath(genpath('dpm'));
% data = load('dpm/VOC2010/car_final.mat');
% model = data.model;
% 
% im = single(imread('obj_training/000010.png'))/255;
% bbox = process(im, model, -0.5);
% showboxes(im, bbox);