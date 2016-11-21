%N/W
function [K, R, t] = KRt_from_P(P)
  %f = K(1,1)
  %T = abs(T_right(1)-T_left(1))
[K,R,t]=art(P);
