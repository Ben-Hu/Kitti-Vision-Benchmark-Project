function [ best, curError ] = bestPlane( depth, segmented, highP)
%BESTPLANEFORBOX 
im_siz = [360,1220];

    % crop the image so we can actually perform operations on it
    segmented = segmented(1:im_siz(1),1:im_siz(2));

    % reshape image for processing
    im = reshape(segmented, 1,[]);

    % find non-zeros (segmented image should be binary)
    imOnes = im==1;
    imOnes = find(imOnes==1);

    % get the indeces associated with 1's in the image
    [onesX,onesY] = ind2sub([size(segmented, 1), size(segmented, 2)], imOnes);

    % perform the same operations to get the indeces of the 1's in the high
    % probability map (we'll need these later)
    hp = reshape(highP, 1,[]);
    highPOnes = hp==1;
    highPOnes = find(highPOnes==1);
    [highPX,highPY] = ind2sub([size(highP, 1), size(highP, 2)], highPOnes);

    % adjust itermax for performance
    itermax = 25;
    curError = inf;
    % perform RANSAC on random 3 points
    for i=1:itermax

        % grab 3 random indeces
        randIx = randperm(numel(onesX), 3);

        % take 3 3D points to build a plane
        p1 = [onesX(randIx(1)), onesY(randIx(1)), depth(onesX(randIx(1)), onesY(randIx(1)))];
        p2 = [onesX(randIx(2)), onesY(randIx(2)), depth(onesX(randIx(2)), onesY(randIx(2)))];
        p3 = [onesX(randIx(3)), onesY(randIx(3)), depth(onesX(randIx(3)), onesY(randIx(3)))];


        % the normal to the plane = cross product of two vectors made from
        % our points
        normal = cross(p1-p2, p1-p3);

        % given the normal vector build a function for our plane
        syms x y z
        p = [x,y,z];

        % take the dot product of the normal and any of our points to get a
        % function that describes this plane
        planeFunction = dot(normal, p-p1);

        val = 0;
        
        % iterate over high probability points
        for m=1:size(highPX, 1)
            % take a random point from our high probability map, hp1,hp2,hp3
            hpPoint = [highPX(i), highPY(i), depth(highPX(i), highPY(i))];

              % project that point onto our plane function. Points that
              % lie on the plane should have dist == 0
              dist = subs(planeFunction, p, hpPoint);
              dist = abs(double(dist));

              val = val + dist; 

        end

        % update our "best" if we got a function with less error.
        if (val < curError)
           curError = val;
           best = normal;
        end



    end
%     
%     [m , n] = meshgrid(1:30,1:30);  
%     equa = solve(best, z);
%     o = eval(subs(equa, {x,y}, {m,n}));
%     mesh(m,n, o)


end

