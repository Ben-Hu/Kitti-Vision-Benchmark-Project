function [tdA,clA]=sampleData(tdP,tdN)
    clN = -1*ones(size(tdN,1),1);
    clP = ones(size(tdP,1),1);
    if size(tdN,1) > size(tdP,1)
        negSample = randsample(size(tdN,1),size(tdP,1));
        tdN = tdN(negSample(:),:);
        clN = clN(negSample(:),:);
    elseif size(tdP,1) > size(tdN,1)
        posSample = randsample(size(tdP,1),size(tdN,1));
        tdP = tdP(posSample(:),:);  
        clP = clP(posSample(:),:);
    end        
    clA = double(cat(1,clP,clN));
    tdA = double(cat(1,tdP, tdN));
end
