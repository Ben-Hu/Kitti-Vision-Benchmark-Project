clear all; close all
globals;
addpath(genpath('dpm'));
im = rgb2gray(single(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/255);
%figure; imagesc(img); axis image;
data = load('dpm/VOC2010/car_final.mat');
model = data.model;

f = double(1.5);
%scale up
im_r = imresize(im,f); 

[ds, bs] = imgdetect(im_r, model, model.thresh);

%TODO: tune thresholds
nms_thresh = 0.5;
top = nms(ds, nms_thresh);
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end
if ~isempty(ds)
    % resize back
    ds(:, 1:end-2) = ds(:, 1:end-2)/f;
    bs(:, 1:end-2) = bs(:, 1:end-2)/f;
end;
plotBoxes(im, ds(top,:), inf, 'r');

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
        text(xl,yt+fontsize/2,'Placeholder','Color',col,'FontSize',fontsize,'FontWeight','bold');
    end
    hold off;
end