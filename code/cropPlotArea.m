% All plots have lines on their x and y axes on the bottom and left
% respectively, but may not have lines for their top and right bounds. For
% bottom and top bound:
% Start at the x-axis location (a coordinate containing all the x-axis
% text labels). Set a range of x coordinates from the right boundary of the
% leftmost x-axis label to the left boundary of the rightmost x-axis label.
% Scan upward until some threshold (95%) of the pixels are nonwhite.
% Continue scanning until this is no longer the case. The first y
% coordinate where this is no longer the case is the bottom boundary, the
% lowest y coordinate to be included in the cropped image.
% This gives us information about the right boundary. In the region above
% the threshold, start from the right and continue right until some
% threshold of pixels are nonwhite; this is the first candidate for
% rightBound. Use the y-coordinate range acquired in leftbound and scan
% left until under the 95% threshold (if we start under it, then don't need
% to move at all, there's no right boundary line.)

function [croppedImage, cropBox] = cropPlotArea(fig, xAxis, yAxis)
%try TODO: remove this try

nonWhitePixelThreshold = .95;

% First, find bottom and left bounds. These should always have axis lines.

xAxisTextBoxes = fig.textBoxes(xAxis.textBoxIndices);
rightTextBounds = cellfun(@(tb) tb.box(1)+tb.box(3)-1, xAxisTextBoxes);
leftTextBounds = cellfun(@(tb) tb.box(1), xAxisTextBoxes);
leftAxisBound = min(rightTextBounds);
rightAxisBound = max(leftTextBounds);

% Scan until we hit the axis line
botBound = xAxis.location;
nonWhitePixels = 0;
while nonWhitePixels/(rightAxisBound-leftAxisBound) < nonWhitePixelThreshold
    botBound = botBound - 1;
    currentPixelRow = fig.image(botBound, leftAxisBound:rightAxisBound, :);
    nonWhitePixels = sum((sum(currentPixelRow,3)~=3*255)); % Count the number of non-white pixels, where white is [255 255 255]
end

% Continue scanning until we're over the axis line
while nonWhitePixels/(rightAxisBound-leftAxisBound) >= nonWhitePixelThreshold
    botBound = botBound - 1;
    currentPixelRow = fig.image(botBound, leftAxisBound:rightAxisBound, :);
    nonWhitePixels = sum((sum(currentPixelRow,3)~=3*255)); % Count the number of non-white pixels, where white is [255 255 255]
end

yAxisTextBoxes = fig.textBoxes(yAxis.textBoxIndices);
topTextBound = cellfun(@(tb) tb.box(2), yAxisTextBoxes);
botTextBound = cellfun(@(tb) tb.box(2)+tb.box(4)-1, yAxisTextBoxes);
topAxisBound = min(botTextBound);
botAxisBound = max(topTextBound);

% Scan until we hit the axis line
leftBound = yAxis.location;
nonWhitePixels = 0;
while nonWhitePixels/(botAxisBound-topAxisBound) < nonWhitePixelThreshold
    leftBound = leftBound + 1;
    currentPixelColumn = fig.image(topAxisBound:botAxisBound, leftBound, :);
    nonWhitePixels = sum((sum(currentPixelColumn,3)~=3*255)); % Count the number of non-white pixels, where white is [255 255 255]
end

% Continue scanning until we're over the axis line
while nonWhitePixels/(botAxisBound-topAxisBound) >= nonWhitePixelThreshold
    leftBound = leftBound + 1;
    currentPixelColumn = fig.image(topAxisBound:botAxisBound, leftBound, :);
    nonWhitePixels = sum((sum(currentPixelColumn,3)~=3*255)); % Count the number of non-white pixels, where white is [255 255 255]
end

% Next, find top and right bounds. These may or may not have axis lines.

% Find top bound

% Scan up from the left axis line until we find a white pixel
topBound = topAxisBound;
while sum(fig.image(topBound, leftBound-1, :), 3) ~= 3*255
    topBound = topBound - 1;
end

% Scan back down until our row is not mostly nonwhite (in case of top axis
% line)
nonWhitePixels = rightAxisBound - leftAxisBound;
while nonWhitePixels/(rightAxisBound-leftAxisBound) >= nonWhitePixelThreshold
    topBound = topBound + 1;
    currentPixelRow = fig.image(topBound, leftAxisBound:rightAxisBound, :);
    nonWhitePixels = sum(sum(currentPixelRow,3)~=3*255); % Count the number of non-white pixels, where white is [255 255 255]
end

% Find right bound

% Scan right from the bot axis line until we find a white pixel
rightBound = rightAxisBound;
while sum(fig.image(botBound+1, rightBound, :), 3) ~= 3*255
    rightBound = rightBound + 1;
end

% Scan back left until our column is not mostly nonwhite (in case of right
% axis line)
nonWhitePixels = botAxisBound - topAxisBound;
while nonWhitePixels/(botAxisBound - topAxisBound) >= nonWhitePixelThreshold
    rightBound = rightBound - 1;
    currentPixelColumn = fig.image(topAxisBound:botAxisBound, rightBound, :);
    nonWhitePixels = sum(sum(currentPixelColumn,3)~=3*255); % Count the number of non-white pixels, where white is [255 255 255]
end
% TODO: figure out errors
% catch err
%     disp(err);
%     disp(err.stack(1));
%     rethrow(err);
%     %keyboard;
%     leftBound = 1;
%     topBound = 1;
%     rightBound = size(fig.image,2);
%     botBound = size(fig.image,1);
% end
cropBox = [leftBound, topBound, rightBound-leftBound, botBound-topBound];
croppedImage = imcrop(fig.image, cropBox);