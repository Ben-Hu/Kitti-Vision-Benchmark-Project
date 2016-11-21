function [dm]=depthMap(dispMap,f,T)
    fun = @(d) (f*T)/d;
    dm = arrayfun(fun,dispMap)
end
