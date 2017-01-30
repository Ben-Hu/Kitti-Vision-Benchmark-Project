function [sliced, error] = fitPlanePipe(fileID)
% performs full pipeline for fitting a plane to an image's point cloud.
% Given a fileID eg 'um_000000'
globals;

% load the model
load('um_lbp_model.mat');

% TODO: add seg dir to globals
% highPMap = buildHighP('segResults/');
highP = buildHighP(TRAIN_SEG_DIR);

    
    disp = double(imread(fullfile(DISPARITY_DIR, sprintf('%s%s.png',fileID,'_left_disparity'))))/256;
    img = double(imread(fullfile(TEST_DIR, sprintf('%s.png',fileID))))/256;
    
    P0 = getMatrix(TRAIN_CALIB_DIR, 'P0', fileID);
    P1 = getMatrix(TRAIN_CALIB_DIR, 'P1', fileID);
    
    f = P0(1,1);
    
    % baseline
    dFrom1 = P0(1,4) / P0(1,1) / -1;
    dFrom2 = P1(1,4) / P1(1,1) / -1;
    baseline = abs(dFrom1 - dFrom2);
    
    depth = depthMap(disp, f, baseline);
    pc_o = getPointCloud(img, depth, f);
    
    % road seg
    rdSeg = segRoad(img, model);
        
    [normal, error] = bestPlane(depth, rdSeg, highP);
    
    [sliced, remaining] = slicePlane(pc_o, normal, rdSeg);
    
    pcshow(sliced, 'MarkerSize',200);
end
    
    
    
    
    
    
    
    
    
