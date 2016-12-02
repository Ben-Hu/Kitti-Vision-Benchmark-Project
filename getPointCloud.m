function [pointCloud] = getPointCloud(depth, numBuckets, bucketSize)
%GETPOINTCLOUD returns a 3d matrix point cloud that represents depth.
%Note that any value greater than numBuckets*bucketSize will be clipped to
%numBuckets*bucketSize
% I had good success with buckets 300 buckets of size 2, 

im_siz = [360,1220];

% crop depth just in case
 depth = depth(1:im_siz(1),1:im_siz(2));

% build meshgrids to store 3d data
[X,Y] = meshgrid(1:size(depth,2),1:size(depth,1));

% setup the point cloud
pointCloud = zeros(size(depth, 1), size(depth,2));

% bucketDepth is based on depth, so just rename (is this bad form?)
bucketDepth = depth;

% iterate over our target number of buckets,
for i=1:numBuckets
    bucket = i*bucketSize;
    % reassign value for each point that lies within this bucket
    bucketDepth(bucketDepth>bucket & bucketDepth<bucket+bucketSize) = bucket;
end

% Clip the highest values
bucketDepth(bucketDepth>bucket) = bucket;

% Build the 3d point cloud
pointCloud(:,:,1) = X;
pointCloud(:,:,2) = Y;
pointCloud(:,:,3) = bucketDepth;

% show the point cloud
% pcshow(pls2);

end