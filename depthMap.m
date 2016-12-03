function [dm]=depthMap(dispMap,f,T)
    fun = @(d) (f*T)/d;
    dm = arrayfun(fun,dispMap);
    %Threshold out anything past 500m, to max Z < 500
    dm(dm>200) = max(dm(dm<200));
end
