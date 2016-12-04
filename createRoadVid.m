function[] = createRoadVid(model, fps, videoName)
% creates a 5fps video of the road segmentations
imgs=dir(fullfile(TEST_DIR,'*.png'));

writerObj = VideoWriter(videoName);
writerObj.FrameRate = fps;
open(writerObj);

for i=1:numel(imgs)
    imgname = imgs(i).name;

    img = double(imread([TEST_DIR,'/',imgname]));
    seg = segRoad(img/256, model);
    r = img(:,:,1);
    r(seg) = 1;
    img(:,:,1) = r;
    
    frame = im2frame(img/256);
    writeVideo(writerObj, frame);

end
close(writerObj);

end