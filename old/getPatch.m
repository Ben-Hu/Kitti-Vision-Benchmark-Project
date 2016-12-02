function [patch]=getPatch(img,x,y,siz)
    offset = siz/2;
    imgp = padarray(img,[offset,offset],0);
    patch = imgp(x:x+siz-1,y:y+siz-1);
end
    