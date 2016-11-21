% orient yourself in a folder containing both left and right heirarchies

% get list of right files (dir does alpha order by default), also assumes
% that image names in right and left cameras are matching
rightFiles = dir('data_road_right/training/image_3');
leftFiles = dir('data_road/training/image_2');

rightImagePath = 'data_road_right/training/image_3/';
leftImagePath = 'data_road/training/image_2/';






%%

% for i = size(rightFiles, 1):-1:3
%     imgId = rightFiles(i).name;
% 
%     % set the right image and display it (also grayscale it)
%     rightImg = double((imread(strcat(rightImagePath , imgId))));
%     rightImg = rgb2gray(rightImg/255);
% 
%     % set the left image and display it (also grayscale it)
%     leftImg = double(imread(strcat(leftImagePath , imgId)));
%     leftImg = rgb2gray(leftImg/255);
% 
% 
%     disparityMap = disparity(leftImg, rightImg);
% 
%     imwrite(double(disparityMap), colormap('gray'), strcat('disparityTraining/', imgId));
% end
