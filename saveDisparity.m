function [ ] = saveDisparity( dir1, dir2, dirTarget )
%SAVEDISPARITY saves disparity between images in two directories in
%dirTarget
%   Given matching images in dir1 and dir2, saves their disparities in
%   dirTarget. Note that dirTarget should end in '/'
% ex: saveDisparity( 'data_road_right/training/image_3',
% 'data_road/training/image_2', 'disparityResults/')

rightFiles = dir(dir1);
leftFiles = dir(dir2);

for i = size(rightFiles, 1):-1:3
    imgIdRight = rightFiles(i).name;
    imgIdLeft = leftFiles(i).name;

    % set the right image and display it (also grayscale it)
    rightImg = double((imread(strcat(dir1 , imgIdRight))));
    rightImg = rgb2gray(rightImg/255);

    % set the left image and display it (also grayscale it)
    leftImg = double(imread(strcat(dir2 , imgIdLeft)));
    leftImg = rgb2gray(leftImg/255);


    disparityMap = disparity(leftImg, rightImg);

    % saves files according right image id
    imwrite(double(disparityMap), colormap('gray'), strcat(dirTarget, imgIdRight));
end

end

