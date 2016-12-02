clear all; close all;
globals;
im_siz = [360,1220];
test_img = double(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/255;
test_img = test_img(1:im_siz(1),1:im_siz(2),:);



[L,N] = superpixels(test_img,300);
%BM = boundarymask(L);
%figure; imshow(imoverlay(test_img,BM,'cyan'),'InitialMagnification',67)

%color_info = zeros(size(test_img));
idx = label2idx(L);
x_siz = size(test_img,1);
y_siz = size(test_img,2);
%For each superpixel, compute the mean color of each channel within the
%super pixel area
%and compute the HoG feature descriptor for the superpixel area
traind = [];
for i=1:N
    %Vector indices for each color channel
    r_idx = idx{i};
    g_idx = idx{i}+x_siz*y_siz;
    b_idx = idx{i}+2*x_siz*y_siz;
    %Assign the superpixel pixels in mean_color_info to the mean color value
    %of the pixels within each superpixel
    %color_info(r_idx) = mean(test_img(r_idx));
    %color_info(g_idx) = mean(test_img(g_idx));
    %color_info(b_idx) = mean(test_img(b_idx));
    
    %since super pixels are all different sizes, uses a histogram of color
    %values
    bins = 0:0.05:1;
    hist_r = histcounts(test_img(r_idx), bins);
    hist_g = histcounts(test_img(g_idx), bins);
    hist_b = histcounts(test_img(b_idx), bins);
    
    %for every index in the superpixel, find the x and y coords
    %can use r_idx, will be the same for g and b channels in their
    %respective dimension
    [x,y] = ind2sub(size(test_img),r_idx);
    x_max = max(x); x_min = min(x);
    y_max = max(y); y_min = min(y);
    
    %best fitting box that bounds the area of the superpixel is given by
    %these max/min coordinates
    pix_box = test_img(x_min:x_max, y_min:y_max);
    %resize the box so the hog feature vectors we get are a standard length
    %might be bad
    squished = imresize(pix_box, [20,20]);
    box_hog = extractHOGFeatures(squished,'NumBins', 9, 'CellSize', [6, 6]);
    
    feat_vec = cat(2, hist_r, hist_g, hist_b, box_hog);
    normFactor = max(abs(feat_vec));
    traind = cat(1,traind,feat_vec/normFactor);
end

