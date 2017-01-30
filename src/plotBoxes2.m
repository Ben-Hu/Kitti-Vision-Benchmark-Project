function plotBoxes2(boxes_3d, dm, P)
%Plots all 3d bounding boxes given input struct from boundingBox3
%Input: struct output from boundingBox3 function

[k,r,t] = Krt_from_P(P);
f = k(1,1);
px = size(dm,1)/2;
py = size(dm,2)/2;;
xoff = -420;
yoff = 420;
for i=1:size(boxes_3d,1)
    cur_boxes = boxes_3d(i,:);
    front = cur_boxes.front_box;
    back = cur_boxes.back_box;
    xl = front(1,1); %x1,y1 
    yb = front(1,2); %x1,y2
    xr = front(3,1); %x2,y1
    yt = front(2,2); %x2,y2
    zf = front(1,3);
    zb = back(1,3);
    
    pixf1 = P * [xl;yb;zf;1];
    pixf1 = pixf1/pixf1(3);
    x1 = pixf1(1) + xoff;
    y1 = pixf1(2) + yoff;
    
    pixf2 = P * [xr;yt;zf;1];
    pixf2 = pixf2/pixf2(3);
    x2 = pixf2(1) + xoff;
    y2 = pixf2(2) + yoff;
    
    pixb1 = P * [xl;yb;zb;1];
    pixb1 = pixb1/pixb1(3);
    x1b = pixb1(1) + xoff;
    y1b = pixb1(2) + yoff;
    
    pixb2 = P * [xr;yt;zb;1];
    pixb2 = pixb2/pixb2(3);
    x2b = pixb2(1) + xoff;
    y2b = pixb2(2) + yoff;
   
    xpb = [x1b,x2b,x2b,x1b,x1b];
    ypb = [y1b,y1b,y2b,y2b,y1b];
    plot(ypb,xpb,'b','LineWidth',4);
    
    xp = [x1,x2,x2,x1,x1];
    yp = [y1,y1,y2,y2,y1];
    plot(yp,xp,'g','LineWidth',4);

    plot([y1,y1b],[x1,x1b],'g','LineWidth',4);
    plot([y2,y2b],[x1,x1b],'g','LineWidth',4);
    plot([y1,y1b],[x2,x2b],'g','LineWidth',4);
    plot([y2,y2b],[x2,x2b],'g','LineWidth',4);
    fontsize = 15;
    text(double(y1),double(x1)+fontsize/2,sprintf('Car-%d',i), 'Color','g','FontSize',fontsize,'FontWeight','bold');
end



end