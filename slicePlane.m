function [ slicedPC, remainingPC ] = slicePlane( pointCloud, normal)
maxDistance = 5;
maxAngularDistance = 5;

[model1,inlierIndices,outlierIndices] = pcfitplane(pointCloud,...
            maxDistance,normal,maxAngularDistance);

slicedPC = pointCloud;
slicedPC.Color(inlierIndices,1) = 255;
remainingPC = select(pointCloud,outlierIndices);

end
