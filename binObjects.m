%yaw/rotation/orientation of objects bounding boxes
%are given in the ground truth labels
%last index, label information in readLabels.m in the devkit 
%given in radians
%4th value is the 'alpha' e.g. object orientation also in radians

%2d bounding box for reference detections is given 
%in values 5 6 7 8 x1,y1,x2,y2

%3d bounding boxes follow:

%have ground truth for objects + orientations

%to process training data:

%do: for each Car object in the ground truth labels:
%extract features in the 2d bounding box area 
%separate labels/training images into 0-30,30-60,60-90,...330-360 degree bins
%train 12 classifiers using the binned training data

clear all; close all;
globals;
%addpath(genpath('kitti_obj_devkit'));
%modified readLabels to take raw img_idx input

%run filter_car_data.sh on label data to filter out training data
%without any car detections (no orientation data)
LABEL_DIR='obj_training/label_2/car_data';
label_list = dir(fullfile(LABEL_DIR,'*.txt'));


%need dims, 
%x1,y1,x2,y3 2-dims
%each row = detection
%third dim = per training image
detections = [];
alpha = [];

%process labels for each image
for i=1:size(label_list,1)
    [~,idx,~] = fileparts(label_list(i).name);
    obj = readLabel(LABEL_DIR, idx);
    %process each detection in image
    for j=1:size(obj,2)
        c_obj = obj(j);
        %xl, yt, xr, yb
        c_box = [c_obj.x1,c_obj.y1,c_obj.x2,c_obj.y2];
        c_alpha = c_obj.alpha;
        %er this is tricky, different numbers of detections 
        %also box dimensions all different
        %need to do the processing directly in here and get standard
        %feature vectors at this point in reading the data
    end
    
    alpha = cat(1,alpha,obj.alpha);
end


box_dims = [x1, y1, x2, y2];
degs = rad2deg(alpha);





