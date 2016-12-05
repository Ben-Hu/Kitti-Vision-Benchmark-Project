function [ slicedPC, remainingPC ] = slicePlane( pointCloud, normal)
maxDistance = 2;
maxAngularDistance = 100;

[model1,inlierIndices,outlierIndices] = pcfitplane(pointCloud,...
            maxDistance,normal,maxAngularDistance);

slicedPC = pointCloud;
slicedPC.Color(inlierIndices,1) = 255;
remainingPC = select(pointCloud,outlierIndices);

end
