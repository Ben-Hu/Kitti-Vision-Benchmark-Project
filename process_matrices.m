%% Processing Camera Matrices
clear all; close all;
CALIB_DIR='/Users/Ben/Desktop/csc420/project/data_road/training/calib/'
tarDir = fullfile(CALIB_DIR,'P0');

%list of files in given directory
listing = dir(fullfile(tarDir,'*.txt'));

%for every file, process it
P = zeros(4,3,size(listing,1));
for i=1:size(listing,1)
    filePath = fullfile(tarDir, listing(i).name)
    fileID = fopen(filePath,'r');
    formatSpec = '%f';
    cP = fscanf(fileID,formatSpec);
    cP = reshape(cP,4,3);
    P(:,:,i) = cP;
    fclose(fileID);
end
