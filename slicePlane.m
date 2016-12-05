function [ slicedPC, remainingPC ] = slicePlane( pointCloud, normal, seg)
maxDistance = 2;
maxAngularDistance = 100;

[model1,inlierIndices,outlierIndices] = pcfitplane(pointCloud,...
            maxDistance,normal,maxAngularDistance);

        
inlierIndices =  inlierIndices(seg(inlierIndices) ~=0);
        
slicedPC = pointCloud;
slicedPC.Color(inlierIndices,1) = 255;
remainingPC = select(pointCloud,outlierIndices);

end
