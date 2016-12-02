function [classified]=segRoad(img,model)
    %Params depend on model, training params may be further tuned for speed
    %INPUT:
    %img: color m x n x 3 image
    %model: svm trained model struct
    %OUTPUT: Logical mask of segmentation
    classified = zeros(size(img,1),size(img,2));
    
    [labels,num_pix] = superpixels(img,300);
    
    idx = label2idx(labels);
    x_siz = size(img,1);
    y_siz = size(img,2);

    %Classify each superpixel
    for i=1:num_pix
        %Form the feature vector to classify for this superpixel
        %3-d Color histogram information
        r_idx = idx{i};
        g_idx = idx{i}+x_siz*y_siz;
        b_idx = idx{i}+2*x_siz*y_siz;
        bins = 0:0.05:1;
        hist_r = histcounts(img(r_idx), bins);
        hist_g = histcounts(img(g_idx), bins);
        hist_b = histcounts(img(b_idx), bins);

        %Histogram of oriented gradients feature vector
        [x,y] = ind2sub(size(img),r_idx);
        x_max = max(x); x_min = min(x);
        y_max = max(y); y_min = min(y);
        pix_box = img(x_min:x_max, y_min:y_max);
        squished = imresize(pix_box, [20,20]);
        box_hog = extractHOGFeatures(squished,'NumBins', 9, 'CellSize', [6, 6]);

        %Put together the descriptor for this superpixel
        feat_vec = cat(2, hist_r, hist_g, hist_b, box_hog);
        normFactor = max(abs(feat_vec));
        pred_vec = double(feat_vec/normFactor);

        [svmOut, svmACC,svm_dec] = svmpredict(1,pred_vec,model,'-b 0 -q');
        classified(idx{i}) = svmOut * ones(size(idx{i}));
    end  
    classified = classified==1;
end