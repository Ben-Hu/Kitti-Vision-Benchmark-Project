%% Testing the model
test_img = double(imread(fullfile(TRAIN_ORIG_DIR,'um_000000.png')))/255;
test_img = double(imread('data_road/testing/image_2/um_000031.png'))/255;
test_img = test_img(1:im_siz(1),1:im_siz(2),:);

test = 1
if test == 1;
    
classified = zeros(size(test_img));

[labels,num_pix] = superpixels(test_img,300);
BM = boundarymask(labels);
figure; imshow(imoverlay(test_img,BM,'cyan'),'InitialMagnification',67)

idx = label2idx(labels);
x_siz = size(test_img,1);
y_siz = size(test_img,2);

%Classify each superpixel
for i=1:num_pix
    %Form the feature vector to classify for this superpixel
    %3-d Color histogram information
    r_idx = idx{i};
    g_idx = idx{i}+x_siz*y_siz;
    b_idx = idx{i}+2*x_siz*y_siz;
    bins = 0:0.05:1;
    hist_r = histcounts(test_img(r_idx), bins);
    hist_g = histcounts(test_img(g_idx), bins);
    hist_b = histcounts(test_img(b_idx), bins);

    %Histogram of oriented gradients feature vector
    [x,y] = ind2sub(size(test_img),r_idx);
    x_max = max(x); x_min = min(x);
    y_max = max(y); y_min = min(y);
    pix_box = test_img(x_min:x_max, y_min:y_max);
    squished = imresize(pix_box, [20,20]);
    box_hog = extractHOGFeatures(squished,'NumBins', 9, 'CellSize', [6, 6]);

    %Put together the descriptor for this superpixel
    feat_vec = cat(2, hist_r, hist_g, hist_b, box_hog);
    normFactor = max(abs(feat_vec));
    pred_vec = double(feat_vec/normFactor);
    
    [svmOut, svmACC,svm_dec] = svmpredict(1,pred_vec,model,'-b 1');%'-b 0 -q');
    classified(idx{i}) = svmOut * ones(size(idx{i}));
end  

figure;imagesc(classified);axis image;colormap gray;

end