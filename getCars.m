function [orientations,boxes] = getCars(img);
    %Input: Image
    %Output: 
    %orientations [direction in radians, confidence 0 or 1]
    %detections 2d bounding boxes for cars
    globals;
    addpath(genpath('dpm'));

    data = load('dpm/VOC2010/car_final.mat');
    model_d = data.model;
    detections = process(img, model_d, -0.5);
    showboxes(img, detections);
    
    boxes = [];
    orientations = [];
    %Classify each detection
    for i=1:size(detections,1)
        bounds = detections(i,1:4);
        y1 = bounds(1);
        x1 = bounds(2);
        y2 = bounds(3);
        x2 = bounds(4);
        c_box = max(round([x1,x2,y1,y2]),1);

        %3 dimensional patch
        img_data = img(c_box(1):c_box(2),c_box(3):c_box(4),:);

        if min(size(img_data,1),size(img_data,2)) < 40
            %do not process objects with boxes less than 40px in smallest dim
            fprintf('object %d lt 40px, not guessing\n',i);
            continue;
        end

        points = detectSURFFeatures(rgb2gray(img_data));
        %Pick strongest x points from detected SURF features
        if size(points,1) < 5
            %Not enough points for detection, need at least 5
            fprintf('Image only had %d points for obj %d\n',size(points,1),i);
            continue;
        end
        
        %Extract hog features around detected surf keypoints
        top_points = points.selectStrongest(5);
        [desc,~,~] = extractHOGFeatures(rgb2gray(img_data),top_points,'NumBins', 12, 'CellSize', [8, 8], 'BlockSize', [2,2],'UseSignedOrientation', true);
        surf_vec = reshape(desc,1,[]);
        feat_vec = surf_vec;
        norm_factor = max(abs(feat_vec));
        pred_vec = double(feat_vec/norm_factor);

        %load('car_dir_model_900s_C8.mat');
        %load('car_dir_model_sift_s20_dA_c8_w100x300.mat');
        %load('car_dir_d4_b13-19_c8_n12_w104-154.mat');
        load('car_dir_model_surfxhog_lt40_5kp_gray_218b.mat'); %'Least bad'
        %load('car_dir_model_surfxhog_c2_b4_8b0c391_fin.mat');

        models = [model_1,model_2,model_3,model_4,model_5,model_6,model_7,model_8,...
            model_9,model_10,model_11,model_12,model_1];

        for j=1:size(models,2)-1
            pred(j,:) = [models(j),models(j+1)];
        end

        %class = 1; %Default direction if not confident
        dir_guess = 1;
        for j=1:size(pred,1)
            [svmOut1,~,~] = svmpredict(1,pred_vec,pred(i,1),'-b 1');
            [svmOut2,~,~] = svmpredict(1,pred_vec,pred(i,2),'-b 1');
            if svmOut1~=svmOut2
                dir_guess = i;
                c = 1;
                break
            end
        end
        bins = cat(2,-1*[180:-30:30],0:30:180);

        if j==12 && dir_guess == 1
            fprintf('Not confident about orientation of object\n');
            c = 0;
        end
        dir_res = bins(dir_guess);
        fprintf('Estimated orientation is %d\n',dir_res);
        %figure; imagesc(img_data); axis image; title(sprintf('D:%d C:%d',dir_res, c));
        boxes = cat(1,boxes,detections(i,1:4))
        orientations = cat(1,orientations,[deg2rad(dir_res),c]);

        % Logic for what is happening above with the pred array:    
        %     %Classify for first model_
        %     [svmOut1,~,~] = svmpredict(1,pred_vec,model_1,'-b 1');
        %     %Second model_
        %     [svmOut2,~,~] = svmpredict(1,pred_vec,model_2,'-b 1');
        %     if svmOut1 ~= svmOut2
        %         %model_ belongs to class 1
        %     else
        %         %check if model_ belongs to class 2
        %         [svmOut3,~,~] = svmpredict(1,pred_vec,model_3,'b 1');
        %         if svmOut2 ~= svmOut3
        %             %model_ belongs to class 2
        %         else
        %             %...
        %         end
        %     end
        %     This reduces to the above
    end
end