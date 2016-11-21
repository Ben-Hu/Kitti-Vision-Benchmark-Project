DATA_DIR=''

%Left Image Set
TEST_DIR=fullfile(PROJ_DIR,'data_road/testing/image_2');
TEST_CALIB_DIR=fullfile(PROJ_DIR,'data_road/testing/calib');

TRAIN_ORIG_DIR=fullfile(PROJ_DIR,'data_road/training/image_2');
TRAIN__SEG_DIR=fullfile(PROJ_DIR,'data_road/training/gt_image_2');
TRAIN_CALIB_DIR=fullfile(PROJ_DIR,'data_road/training/calib/');

%Right Image Set
R_TEST_DIR=fullfile(PROJ_DIR,'data_road_right/testing/image_2');
R_TEST_CALIB_DIR=fullfile(PROJ_DIR,'data_road_right/testing/calib');

R_TRAIN_ORIG_DIR=fullfile(PROJ_DIR,'data_road_right/training/image_2');
R_TRAIN__SEG_DIR=fullfile(PROJ_DIR,'data_road_right/training/gt_image_2');
R_TRAIN_CALIB_DIR=fullfile(PROJ_DIR,'data_road_right/training/calib/');

%Saved processing output
DISPARITY_DIR='disparityTraining';
DEPTH_DIR='depthTraining';

