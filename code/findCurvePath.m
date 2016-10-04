function [xs, ys] = findCurvePath(score, breathingWeight, slopeWeight)

maxSearchDist = round(size(score,1)*.01);
[xs,ys] = findPath(score, breathingWeight, slopeWeight, maxSearchDist);
xs = xs+1;
ys = ys+1;