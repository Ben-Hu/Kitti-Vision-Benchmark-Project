function plotBoxes3(img_boxes)
%Plots all 3d bounding boxes given input struct from boundingBox3
%for plotting on an open point cloud figure
%Input: struct output from boundingBox3 function
    for i=1:size(img_boxes,1)
        cur_obj = img_boxes(i);
        front = cur_obj.front_box;
        back = cur_obj.back_box;
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
        plot3(xp,yp,zbp,'b','LineWidth',2);
        plot3(cx1,cy1,cz1,'r','LineWidth',2);
        plot3(cx2,cy2,cz2,'r','LineWidth',2);
        plot3(cx3,cy3,cz3,'r','LineWidth',2);
        plot3(cx4,cy4,cz4,'r','LineWidth',2);
        fontsize = 20;
        text(double(xl),double(yt),double(zf),sprintf('Car-%d',i),...
            'Color','r','FontSize',fontsize,'FontWeight','bold');
    end
end