function [dm]=depthMap(dispMap,f,T)
    dm = zeros(size(dispMap,1),size(dispMap,2));
    for i=1:size(dispMap,1)
        for j=1:size(dispMap,2)
            Z =  (f * T) / dispMap(i,j); 
            dm(i,j) = Z;
        end
    end
end
