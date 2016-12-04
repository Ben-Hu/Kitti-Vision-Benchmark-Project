function [pc_o] = getPointCloud(img, depth, f)
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

py = size(img,1)/2;
px = size(img,2)/2;
for i=1:size(pc,1)
    x = pc(i,1);
    y = pc(i,2);
    Z = pc(i,3);
    new_y = Z * ((y - px)/f);
    new_x = Z * ((x - py)/f);
    pc(i,1) = new_x;
    pc(i,2) = new_y;
end

% Build the 3d point cloud
colors = reshape(img,[],3);
pc_o = pointCloud(pc, 'Color', colors);
pc_o = pcdenoise(pc_o);
% show the point cloud
% pcshow(pc_o, 'VerticalAxis','X','MarkerSize',300); hold on;
end
