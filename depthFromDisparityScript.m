% setup paths
pathToDisparity =  'disparityTraining/';
pathToCalib = 'data_road/training/calib/';
dirTarget = 'depthTraining/';

% get disparity files
disparityFiles = dir(pathToDisparity);

% get calibration matrices

% get depth for each disparity file
for i=3:size(disparityFiles, 1)

 % get disparity file and calibs associated
 disparity = double((imread([pathToDisparity, disparityFiles(i).name])));
 [P0, P1] = getCalib([pathToCalib, disparityFiles(i).name(1:end-3), 'txt'], 1,2);
 
 depth = zeros(size(disparity, 1), size(disparity, 2));
 for m=1:size(disparity,1)
     for n=1 : size(disparity,2)
         depth(m,n) = depthFromDisparity(disparity(m,n), P0, P1);
     end
     
 end
 
 % Some correction to account for infinities and normalize a little to get
 % a better visual result. Comment this section out for raw data s = sort(unique(depth));
 depth(depth==inf) = s(end-1)+ 40;
 
 % I found the below operations to give a reasonable result for
 % visualisation
 depth = log(depth*50) *5;
 imwrite(double(depth), colormap('jet'), strcat(dirTarget, disparityFiles(i).name));

  
end

