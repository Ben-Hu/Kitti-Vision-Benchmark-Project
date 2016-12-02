% numFaces = 600;
% [x,y,z] = sphere(numFaces);
% I = im2double(imread('visionteam1.jpg'));
% J = flipud(imresize(I,size(x))); %Reshaping to size of solid you are projecting onto
% pcshow([x(:),y(:),z(:)],reshape(J,[],3));
% 
% ptCloud = pcread('teapot.ply');
% player = pcplayer(ptCloud.XLimits,ptCloud.YLimits,ptCloud.ZLimits);
% show(player);
% view(player,ptCloud);

clear all; close all;
globals;
img = double(imread(fullfile(TEST_DIR,'uu_000074.png')))/256;
dispmap = double(imread('tmp/uu_000073_disp.png'))/256;
P2 = getMatrix(TEST_CALIB_DIR,'P2','uu_000073');
P3 = getMatrix(TEST_CALIB_DIR,'P3','uu_000073');
[k2,r2,t2] = Krt_from_P(P2);
[k3,r3,t3] = Krt_from_P(P3);

dm = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));
C = [0 255]; 
%figure; imagesc(depthmap,C); axis image; colormap gray;
dm(dm>500) = max(dm(dm<500));
layers = 0:3:500;
assignment = discretize(dm,layers);

idx = label2idx(assignment);
stack = zeros([size(img),size(idx,2)]);
x_siz = size(img,1);
y_siz = size(img,2);
for i=1:size(idx,2)
    c_layer = stack(:,:,:,i);
    r_idx = idx{i};
    g_idx = idx{i}+x_siz*y_siz;
    b_idx = idx{i}+2*x_siz*y_siz;
    c_layer(r_idx) = img(r_idx);
    c_layer(g_idx) = img(g_idx);
    c_layer(b_idx) = img(b_idx);
    stack(:,:,:,i) = c_layer;
    %[xr,yr] = ind2sub([x_siz,y_siz],r_idx);
    %pt = patch(xr,yr,'red');
end

%sanity check
%test = sum(stack,4);
%figure; iamgesc(test); axis image;

for i=1:20%size(layers,2)
    figure; imagesc(stack(:,:,:,i)); axis image;
    %just need to figure out how to display this in a 3d 'grid'
    %write to ply file format
    %axis equal; view(3); axis tight; axis vis3d; grid off; 
end

for i=1:size(stack,4)
    clvl_r = stack(:,:,1,i);
    clvl_g = stack(:,:,1,i);
    clvl_b = stack(:,:,1,i);   
end


