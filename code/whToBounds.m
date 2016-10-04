function bounds = whToBounds(box)
% Convert a box of the form [x1 y1 w h] to [x1 y1 x2 y2]
bounds = box + [0, 0, box(1)-1, box(2)-1];
end