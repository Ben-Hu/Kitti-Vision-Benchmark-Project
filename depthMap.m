function [dm]=depthMap(dispMap,f,T)
    fun = @(d) (f*T)/d;
    dm = arrayfun(fun,dispMap);
    %Threshold out anything past 500m, to max Z < 500
    dm(dm>500) = max(dm(dm<500));
end
