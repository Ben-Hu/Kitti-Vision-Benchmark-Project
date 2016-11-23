% function [ best ] = bestPlaneForBox( depth, xleft, ytop, xright, ybottom  )
%BESTPLANEFORBOX given a bounding box described by xleft, ytop, xright,
%ybottom for image depth, find the best 3D plane to describe this patch.

% taking 3 points at random from within the bounding box and finding the
% plane they form. Use RANSAC to find the best plane in the depth map given
% within the bounding box.


% TODO: This needs to be vectorised, it runs like a snail.

   
    % vars for tuning ransac
    iterMax = 100;
    threshold = 3;
    
    % setup data
    xVals = (xleft:xright);
    yVals = (ytop:ybottom);
    
    % "instantiate" top number of agreements
    bestAgree = 0;
    
    for i=1:iterMax
       xSample = randsample(xVals, 3,false);
       ySample = randsample(yVals, 3, false);
       
       % create three 3d points from which we can assemble a plane
       p1 = [xSample(1), ySample(1), depth(ySample(1), xSample(1))];
       p2 = [xSample(2), ySample(2), depth(ySample(2), xSample(2))];
       p3 = [xSample(3), ySample(3), depth(ySample(3), xSample(3))];
       
       % the normal to the plane = cross product of two vectors made from
       % our points
       normal = cross(p1-p2, p1-p3);
       
       % given the normal vector build a function for our plane
       syms x y z
       p = [x,y,z];
       
       % take the dot product of the normal and any of our points to get a
       % function that describes this plane
       planeFunction = dot(normal, p-p1);
              
       % iterate through the bounding box and find how many points agree
       % with our plane
       % *NOTE* recall that matlab is weird about coords, hence the
       % inversion of coords here. 
           
       
       [X, Y] = meshgrid((xleft:xright), (ybottom:ytop));


       % create a matrix of points and their boolean agreement
       agreeM = arrayfun(@(x, y, z) getAgreement(x, y, z, pf) ,...
           reshape(X.',1, numel(X)),...
           reshape(Y.', 1, numel(Y)),...
           reshape(depth.', 1, numel(depth)),...
           planefunction);
       
       % the sum of the agreement matrix is this plane's score
       agree = sum(agreeM);
      
       
       % if we beat our best number of agreements, make this our best
       if (agree > bestAgree)
          bestAgree = agree;
          best = planeFunction;
       end
        
    end
    
    % "return" the best planeFunction
    
% end

