function createVid()
% creates a video of the road segmentations with bounding boxes
fps = 8; videoName = 'c_all.avi';
globals;
imgs=dir(fullfile(TEST_DIR,'*.png'));

writerObj = VideoWriter(videoName);
writerObj.FrameRate = fps;
open(writerObj);

for i=1:numel(imgs)
    imgname = imgs(i).name;

    img = double(imread([TEST_DIR,'/',imgname]))/256;
    imgr = double(imread([R_TEST_DIR, '/', imgname]));
    img = img(1:360,1:1220,:);
    imgr = imgr(1:360,1:1220,:);
    [~,idx,~] = fileparts(imgs(i).name);
    dispmap = disparity(rgb2gray(img),rgb2gray(imgr));
    P2 = getMatrix(TEST_CALIB_DIR,'P2',idx);
    P3 = getMatrix(TEST_CALIB_DIR,'P3',idx);
    [k2,r2,t2] = Krt_from_P(P2);
    [k3,r3,t3] = Krt_from_P(P3);
    dm = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));
    py = size(dm,1)/2;
    px = size(dm,2)/2;
    f = k2(1,1);

    [orientations, boxes] = getCars(img);
    boxes_3d = boundingBox3(boxes,dm,f,py, px, zeros(1,40));
    
    smodel = load('umall_lbp_model.mat');
    smodel = smodel.model;
    seg = segRoad(img, smodel);
    r = img(:,:,1);
    r(seg) = 1;
    img(:,:,1) = r;

    BM = boundarymask(seg);
    figure('visible', 'off');imshow(imoverlay(img,BM,'red')); hold on;

    %figure; imagesc(img); axis image; hold on;
    plotBoxes2(boxes_3d,dm,P2);


    res = getframe;
    
    frame = im2frame(imresize(res.cdata,[360,1220]));
    writeVideo(writerObj, frame);

end
close(writerObj);

end