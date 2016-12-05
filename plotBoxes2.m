%function plotBoxes2(boxes, P)
%Plots all 3d bounding boxes given input struct from boundingBox3
%Input: struct output from boundingBox3 function
py = size(dm,1)/2;
px = size(dm,2)/2;
    for i=1:1%size(img_boxes,1)
        cur_obj = img_boxes(i);
        front = cur_obj.front_box;
        back = cur_obj.back_box;
        %want: [xl,yb,xr,yt]
        %P * [x;y;z;1] = [x,y,s]
        %P * [xl;yb;zf;1]
        xl = front(1,1); %x1,y1 
        yb = front(1,2); %x1,y2
        xr = front(3,1); %x2,y1
        yt = front(2,2); %x2,y2
        zf = front(1,3);
        zb = back(1,3);
        xp = [xl,xr,xr,xl,xl]; %front and back faces of box
        yp = [yb,yb,yt,yt,yb];
        cx1 = [xl,xl]; %Connecting lines
        cy1 = [yb,yb];
        cz1 = [zf,zb];
        cx2 = [xl,xl];
        cy2 = [yt,yt];
        cz2 = [zf,zb];
        cx3 = [xr,xr];
        cy3 = [yt,yt];
        cz3 = [zf,zb];
        cx4 = [xr,xr];
        cy4 = [yb,yb];
        cz4 = [zf,zb];
        zfp = zf * ones(1,5);
        zbp = zb * ones(1,5);
        %figure; hold on;
        plot3(xp,yp,zfp,'r','LineWidth',2);
        plot3(xp,yp,zbp,'r','LineWidth',2);
        plot3(cx1,cy1,cz1,'r','LineWidth',2);
        plot3(cx2,cy2,cz2,'r','LineWidth',2);
        plot3(cx3,cy3,cz3,'r','LineWidth',2);
        plot3(cx4,cy4,cz4,'r','LineWidth',2);
        fontsize = 20;
        text(double(xl),double(yt),double(zf),sprintf('Car-%d',i),...
            'Color','r','FontSize',fontsize,'FontWeight','bold');
    end
    
    function plotBoxes(img,res,top_det,col)
    %res = [res,~] from dpm
    %top_det params are for limiting the plots to the top detections
    %for debugging purposes
    fontsize = 10;
    figure;imagesc(img);axis image;hold on;
    for i=1:min(top_det,size(res,1))
        bounds = res(i,1:4);
        xl = bounds(1);
        yt = bounds(2);
        xr = bounds(3);
        yb = bounds(4);
        xp = [xl,xr,xr,xl,xl];
        yp = [yb,yb,yt,yt,yb];
        plot(xp,yp,'r','LineWidth',2);
        text(xl,yt+fontsize/2,sprintf('Car-%d',i), 'Color',col,'FontSize',fontsize,'FontWeight','bold');
    end
    hold off;
end
%end