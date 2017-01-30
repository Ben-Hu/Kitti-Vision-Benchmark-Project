function [ agreement ] = getAgreement(x,y,z, planeFunction)
%GETAGREEMENT Summary of this function goes here
%   Detailed explanation goes here

      syms x y z
      p = [x,y,z];
      % grab the 3D point
      curP = [x,y,z];
                
       % project that point onto our plane function. Points that
      % lie on the plane should have dist == 0
      dist = subs(planeFunction, p, curP);
      dist = double(dist);
                
      % check if this point is close to our plane (modify
      % threshold to tweak for particular results)
       if(-threshold < dist < threshold) 
          agreement = 1;      
       else
          agreement = 0;
       end


end

