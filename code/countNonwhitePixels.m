function pixelCount = countNonwhitePixels(input)
% input is a RGB image

% Find all unique colors
assert(size(input,3) == 3, 'Expected RGB image');
colorvec = double(reshape(input, [], 3));
[colors,~,uniquecolor_idx]=unique(colorvec,'rows');

% Find white
white = [255,255,255];
whitedist = bsxfun(@minus,colors,white);
[~,white_idx]=min(arrayfun(@(idx) norm(whitedist(idx,:)),1:size(colors,1)));

% Count white pixels
pixelCount = sum(uniquecolor_idx ~= white_idx);