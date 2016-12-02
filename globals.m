DATA_DIR='';

%%ROAD
%Left Image Set
TEST_DIR=fullfile(DATA_DIR,'data_road/testing/image_2');
TEST_CALIB_DIR=fullfile(DATA_DIR,'data_road/testing/calib');

TRAIN_ORIG_DIR=fullfile(DATA_DIR,'data_road/training/image_2');
TRAIN_SEG_DIR=fullfile(DATA_DIR,'data_road/training/gt_image_2');
TRAIN_CALIB_DIR=fullfile(DATA_DIR,'data_road/training/calib/');

%Right Image Set
R_TEST_DIR=fullfile(DATA_DIR,'data_road_right/testing/image_3');
R_TRAIN_ORIG_DIR=fullfile(DATA_DIR,'data_road_right/training/image_3');

%Saved processing output
DISPARITY_DIR=fullfile(DATA_DIR,'disparityTraining');
DEPTH_DIR=fullfile(DATA_DIR,'depthTraining');

%%OBJECT
CAR_IMG_L='data_car_left/training/image_2';
CAR_IMG_R='data_car_right/training/image_3';

%run filter_car_data.sh on label data to filter out training data
%without any car detections (no orientation data)
LABEL_DIR='data_car_left/training/label_2/car_data';

%run vlfeat-0.9.20/toolbox/vl_setup.m;
addpath(genpath('dpm'));
addpath(genpath('libsvm'));
%addpath(genpath('vlfeat-0.9.20'));


