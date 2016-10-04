function [xAxis, yAxis, inAxes] = find_axes(fig)
% Identify x and y axes by identifying axis ticks
% TODO: change
%on locations of text boxes containing
% numbers, returning axis locations, the text boxes they consist of, and
% models of scale to convert from pixel coordinates on the fig image to
% data coordinates.
%
% figim is the raster image of a figure.
% figdata is a structure containing figure data, as produced by
% loadfigdata.
%
% xmdl, ymdl are generalized linear models for mapping pixel coordinates
% to chart data values, as determined by axis scale labels.
% xaxisloc, yaxisloc are the row/column position of the x/y axes,
% respectively.

% Only look at text that can be parsed as a number
isNumeric = cellfun(@(tb) ~isnan(str2double(tb.text)), fig.textBoxes);
numericText = [fig.textBoxes{isNumeric}];

% Find the x and y axes by looking for the most numeric text boxes that
% line up horizontally and vertically, respectively.

% Find x axis
maxAlignedBoxes = -1;
inXAxis = zeros(size(numericText));
xAxisLocation = -1;
% Check each pixel row
for y = size(fig.image,1):-1:1
    % Count the number of numeric text boxes in that row
    inRow = arrayfun(@(tb) (tb.box(2)<y) & (tb.box(2)+tb.box(4)>y), numericText);
    if sum(inRow)>maxAlignedBoxes
        maxAlignedBoxes = sum(inRow);
        inXAxis = inRow;
        xAxisLocation = y;
    end
end

% Find y axis
maxAlignedBoxes = -1;
inYAxis = zeros(size(numericText));
yAxisLocation = -1;
% Check each pixel column
for x = 1:size(fig.image,2)
    % Count the number of numeric text boxes in that column
    inColumn = arrayfun(@(tb) (tb.box(1)<x) & (tb.box(1)+tb.box(3)>x), numericText);
    if sum(inColumn)>maxAlignedBoxes
        maxAlignedBoxes = sum(inColumn);
        inYAxis = inColumn;
        yAxisLocation = x;
    end
end

% If any boxes were found for both axes, we're not sure what axis they're
% from, so to be safe, don't use them to determine either scale.
intersection = inXAxis & inYAxis;
xAxisBoxes = numericText(inXAxis & ~intersection);
yAxisBoxes = numericText(inYAxis & ~intersection);
if numel(xAxisBoxes) <= 1
    error('FigureSeer:noAxis', 'No numeric x-axis found');
end
if numel(yAxisBoxes) <= 1
    error('FigureSeer:noAxis', 'No numeric y-axis found');
end

% Fit linear and logarithmic models on both axes to determine best fit.
xTickPositions = arrayfun(@(tb) tb.box(1)+tb.box(3)/2, xAxisBoxes);
xTickValues = arrayfun(@(tb) (str2double(tb.text)), xAxisBoxes);
[xTickPositions,xOrder] = sort(xTickPositions,'ascend');
xTickValues = xTickValues(xOrder);
if ~(all(diff(xTickValues)>0) || all(diff(xTickValues)<0))
    error('FigureSeer:axisNotMonotonic','X axis not monotonic');
end
[xModel, xType] = fitAxisModel(xTickPositions, xTickValues);

yTickPositions = arrayfun(@(tb) tb.box(2)+tb.box(4)/2, yAxisBoxes);
yTickValues = arrayfun(@(tb) (str2double(tb.text)), yAxisBoxes);
[yTickPositions, yOrder] = sort(yTickPositions,'ascend');
yTickValues = yTickValues(yOrder);
if ~(all(diff(yTickValues)>0) || all(diff(yTickValues)<0))
	error('FigureSeer:axisNotMonotonic','Y axis not monotonic');
end
[yModel, yType] = fitAxisModel(yTickPositions, yTickValues);

% Find Axis Titles

numericIndices = find(isNumeric);
inAxes = zeros(size(fig.textBoxes));
inAxes(numericIndices(inYAxis | inXAxis)) = 1;
nonAxisTextBoxes = [fig.textBoxes{~inAxes}];

% Find text boxes that lie entirely below the x axis
topBound = arrayfun(@(tb) (tb.box(2)), nonAxisTextBoxes);
belowAxis = find(topBound > xAxisLocation);
% If there are any, we use the highest one as the axis label
if isempty(belowAxis)
    xTitle = '';
else
    [~,highest] = min(topBound(belowAxis));
    idx = belowAxis(highest);
    xTitle = nonAxisTextBoxes(idx);
end

% Find text boxes completely to the left of the y axis
rightBound = arrayfun(@(tb) (tb.box(1)+tb.box(3)), nonAxisTextBoxes);
leftOfAxis = find(rightBound < yAxisLocation);
% If there are any, we use the rightmost one as axis label
if isempty(leftOfAxis)
    yTitle = '';
else
    [~,rightmost] = max(rightBound(leftOfAxis));
    idx = leftOfAxis(rightmost);
    yTitle = nonAxisTextBoxes(idx);
end

xAxis = Axis(xAxisLocation, min(xTickValues), max(xTickValues), xModel, xType, xTitle, numericIndices(inXAxis));
yAxis = Axis(yAxisLocation, min(yTickValues), max(yTickValues), yModel, yType, yTitle, numericIndices(inYAxis));

end

function [model, type] = fitAxisModel(coords, values)
% Fit a model mapping pixel coordinates to data coordinates based on axis
% scale.

% Fit linear and logarithmic models on both axes to determine best fit.
rmse = @(mdl) sqrt(mean((mdl.Residuals.Raw).^2));

% Linear model
models{1}.type = 'linear';
models{1}.model = GeneralizedLinearModel.fit(coords, values, 'Link', 'identity');
models{1}.rmse = rmse(models{1}.model);

% Logarithmic model
models{2}.type = 'log';
models{2}.model = GeneralizedLinearModel.fit(coords, values, 'Link', 'log');
models{2}.rmse = rmse(models{2}.model);

% Pick best model based on RMSE
errors = cellfun(@(c) c.rmse,models);
[~,best] = min(errors);
model = models{best}.model;
type = models{best}.type;
end