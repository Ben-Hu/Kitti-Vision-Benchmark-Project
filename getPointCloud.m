function [pc_o] = getPointCloud(img, depth)
%GETPOINTCLOUD returns a 3d matrix point cloud that represents depth.

im_siz = [360,1220];
img = img(1:im_siz(1),1:im_siz(2),:);

% crop depth just in case
depth = depth(1:im_siz(1),1:im_siz(2));

% All index permutations
[X,Y] = meshgrid(1:im_siz(1),1:im_siz(2));
idx=cat(2,X',Y');
idx=reshape(idx,[],2);

% Form the point coordinate matrix
pc = zeros(size(idx,1),3);
for i=1:size(idx,1)
    pc(i,:) = [idx(i,1),idx(i,2),depth(idx(i,1),idx(i,2))];
end

% Build the 3d point cloud
colors = reshape(img,[],3);
pc_o = pointCloud(pc, 'Color', colors);

% show the point cloud
% pcshow(pc_o);
end
