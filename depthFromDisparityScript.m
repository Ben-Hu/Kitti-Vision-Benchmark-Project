globals;

% get disparity files
disparityFiles = dir(DISPARITY_DIR);

% get depth for each disparity file
for i=3:size(disparityFiles, 1)

 % get disparity file and calibs associated
 disparity = double((imread([DISPARITY_DIR, disparityFiles(i).name])));
 
 % get calibration matrices
 P0 = getMatrix(TRAIN_CALIB_DIR,'P2',disparityFiles(i).name(1:end-4));
 P1 = getMatrix(TRAIN_CALIB_DIR,'P3',disparityFiles(i).name(1:end-4));
 
 depth = zeros(size(disparity, 1), size(disparity, 2));
 for m=1:size(disparity,1)
     for n=1 : size(disparity,2)
         depth(m,n) = depthFromDisparity(disparity(m,n), P0, P1);
     end
     
 end
 
 % Some correction to account for infinities and normalize a little to get
 % a better visual result. Comment this section out for raw data 
 s = sort(unique(depth));
 depth(depth==inf) = s(end-1)+ 40;
 
 % I found the below operations to give a reasonable result for
 % visualisation
 depth = log(depth*50) *5;
 imwrite(double(depth), colormap('jet'), strcat(DEPTH_DIR, disparityFiles(i).name));

  
end

