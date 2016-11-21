DATA_DIR=''

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

