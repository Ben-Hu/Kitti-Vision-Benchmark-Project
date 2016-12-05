function [img_boxes]=boundingBox3(boxes,dm,f,px,py,direction)

img_boxes = [];
for i=1:size(boxes,1)
    bounds = boxes(i,1:4);
    %swap x and y
    y1 = round(bounds(1));
    x1 = round(bounds(2));
    y2 = round(bounds(3));
    x2 = round(bounds(4));
    dm_patch = dm(x1:x2, y1:y2); 
    
    %Mask out the depth information of the car using active contour models
    %the max and min of the masked depth information 
    %diameter of 1/2 min dimension image so we get enough coverage
    %initially for the start mask, using a circle mask
    elem_siz = round(min(size(dm_patch,1),size(dm_patch,2))/4); 
    element = fspecial('disk',elem_siz)>0;
    ex = round((size(dm_patch,1)-size(element,1))/2);
    ey = round((size(dm_patch,2)-size(element,2))/2);
    element = padarray(element, [ex ey], 0);
    element = element(1:size(dm_patch,1),1:size(dm_patch,2));
    
    %Get the active contour segmentation of the car depth information
    act = activecontour(dm_patch, element);
    dm_car = dm_patch .* act;
    
    %Filter out any outlier depth information we still have
    dm_car(dm_car<0) = 0;
    
    %figure; imagesc(act); axis image; colormap gray;
    %figure; imagesc(dm_patch); axis image; colormap gray;
    %figure; imagesc(dm_patch.*act); axis image; colormap gray;
    
    %for each corner of the box, find the world coordinates of the 
    %front face of the car, minimum depth in our mask of non-zero value
    front_Z = min(dm_car(dm_car(:)~=0));
    front_box = [x1,y1,front_Z;x1,y2,front_Z;...
    x2,y1,front_Z;x2,y2,front_Z];
    for j=1:size(front_box,1)
        x = front_box(j,1);
        y = front_box(j,2);
        Z = front_box(j,3);
        new_y = Z * ((y - py)/f);
        new_x = Z * ((x - px)/f);
        front_box(j,1) = new_x;
        front_box(j,2) = new_y;
    end
    
    back_Z = min(max(dm_car(:)),front_Z+5);
    back_box = [x1,y1,back_Z;x1,y2,back_Z;...
    x2,y1,back_Z;x2,y2,back_Z];
    for j=1:size(back_box,1)
        x = back_box(j,1);
        y = back_box(j,2);
        Z = back_box(j,3);
        new_y = front_box(j,2);%Z * ((y - py)/f);
        new_x = front_box(j,1);% * ((x - px)/f);
        back_box(j,1) = new_x;
        back_box(j,2) = new_y;
    end
    
    a = 0
    b = direction(i)
    c = 0;
    Rx = [1,0,0;0,cos(a),-sin(a);0,sin(a),cos(a)]; %roll
    Ry = [cos(b),0,sin(b);0,1,0;-sin(b),0,cos(b)]; %pitch -- this + angle of orientation
    Rz = [cos(c),-sin(c),0;sin(c),cos(c),0;0,0,1]; %yaw
    Rf = Rx * Ry * Rz;
    
    % Translate to origin, rotate about axis, translate back
    m = [(front_box(1,1) + front_box(3,1))/2, (front_box(1,2) + front_box(2,2))/2, (front_box(1,3) + front_box(3,3))/2];
    front_box = front_box - m;
    front_box = front_box*Rf;
    front_box = front_box + m;

    mb = [(back_box(1,1) + back_box(3,1))/2, (back_box(1,2) + back_box(2,2))/2, (back_box(1,3) + back_box(3,3))/2];
    back_box = back_box - m;
    back_box = back_box*Rf;
    back_box = back_box + m;

    carbox.back_box = back_box;
    carbox.front_box = front_box;
    img_boxes = cat(1,img_boxes,carbox);
        
end

end