% Gets the camera calibration at index camNum1 and camNum2 for calibration
% file at filePath

% NOTE: in particular, works best when calibs for all cameras are in the
% same text file

function [ P0, P1 ] = getCalib( filePath , camNum1, camNum2)

fileText = fileread(filePath);

fileRows = strsplit(fileText, '\n');

% grab camera 0
intrin0 = strsplit(fileRows{camNum1});

% grab camera 0
intrin1 = strsplit(fileRows{camNum2});

% convert data into useable matrices
P0 = [str2double(intrin0{2}), str2double(intrin0{3}), str2double(intrin0{4}), str2double(intrin0{5});
      str2double(intrin0{6}), str2double(intrin0{7}), str2double(intrin0{8}), str2double(intrin0{9});
      str2double(intrin0{10}), str2double(intrin0{11}), str2double(intrin0{12}), str2double(intrin0{13})];
  
P1 = [str2double(intrin1{2}), str2double(intrin1{3}), str2double(intrin1{4}), str2double(intrin1{5});
      str2double(intrin1{6}), str2double(intrin1{7}), str2double(intrin1{8}), str2double(intrin1{9});
      str2double(intrin1{10}), str2double(intrin1{11}), str2double(intrin1{12}), str2double(intrin1{13})];
  


end

