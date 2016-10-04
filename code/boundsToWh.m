function box = boundsToWh(bounds)
% Convert a box of the form [x1 y1 x2 y2] to [x1 y1 w h]
box = bounds + [0, 0, -bounds(1)+1, -bounds(2)+1];
end