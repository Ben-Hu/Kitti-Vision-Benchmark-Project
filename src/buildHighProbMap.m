function [highP] = buildHighP(pathToSegmented)

im_siz = [360,1220];
segmentedFiles = dir(pathToSegmented);


error = 0;
% Set minimum number of high probability points
errorThresh = 10000;

% number of sample images
samples = 20;

while(error < errorThresh)

    % take some number of sample images to get an idea of where we will likely
    % find road
    index = randsample((3:size(segmentedFiles, 1)), samples);


    % iterate load a random sample of images, 
    for i=1:numel(index)
        % fiddle with the image to make it processable
        segmented = double((imread([pathToSegmented, segmentedFiles(index(i)).name])));
%         segmented = rgb2gray(segmented/255);
        segmented = segmented(1:im_siz(1),1:im_siz(2));
        rPixVal = max(reshape(segmented,1,[]));
        segmented = segmented(:,:) >= rPixVal;

        % if we don't have a highprobability image yet, let this be one
        if(i==1)
            highP = segmented;
        else
            % element wise multiplication will only keep 1's that occur in both
            % images
            highP = highP.*segmented; 
        end
    end

    errorCount = find(highP==1);
    error = size(errorCount);
    

end


end


