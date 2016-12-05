function[] = createVid(model, fps, videoName)
% creates a video of the road segmentations with bounding boxes
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
    
    seg = segRoad(img, model);
    BM = boundarymask(rgb2gray(seg));
    figure('visible', 'off'); imshow(imoverlay(img,BM,'red'))%,'InitialMagnification',67)
    
    [~,idx,~] = fileparts(imgs(i).name);
    dispmap = disparity(img,imgr);
    P2 = getMatrix(TEST_CALIB_DIR,'P2',idx);
    P3 = getMatrix(TEST_CALIB_DIR,'P3',idx);
    [k2,r2,t2] = Krt_from_P(P2);
    [k3,r3,t3] = Krt_from_P(P3);
    dm = depthMap(dispmap,k2(1,1),abs(t3(1)-t2(1)));
    px = size(dm,1)/2;
    py = size(dm,2)/2;
    f = k2(1,1);
    boxes_3d = boundingBox3(boxes,dm,f,px, py, 0,0,0);
    plotBoxes2(boxes_3d,dm,P2);
    
    res = getframe;
    
    frame = im2frame(res);
    writeVideo(writerObj, frame);

end
close(writerObj);

end