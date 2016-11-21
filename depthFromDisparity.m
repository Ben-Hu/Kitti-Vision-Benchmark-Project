function [ depth ] = depthFromDisparity( disparity, P1, P2)
%DEPTHFROMDISPARITY returns depth of a point given disparity
%and camera calibrations for the pair of cameras
% Requires art.m
%   ex: depthFromDisparity(disparity, P1, P2

[K1, ~, ~] = KRt_from_P(P1);

% get distances from camera 0. note that all cameras are parallel, and some
% distances are negative to account for direction
% (KITTI stores the value -Fx * baseline in position 1,4
dFrom1 = P1(1,4) / P1(1,1) / -1;
dFrom2 = P2(1,4) / P2(1,1) / -1;

% then the baseline should be the difference in distances. Take abs to
% account for negative distance
baseline = abs(dFrom1 - dFrom2);

% The cameras used by KITTI are Flea2 models. In particular these:
% https://www.ptgrey.com/flea2-14-mp-mono-firewire-1394b-sony-icx267-camera
% get focal length in pixels

focalLength = K1(1,1);

% finally get depth for this point
depth = focalLength * baseline / disparity;

end

