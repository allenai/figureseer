function results = parseChart(fig, conf)

% Check if we have text
if isempty(fig.textBoxes)
    results.error = 'No text detected';
    return;
end

% Find image axes and axis labels
try
    [xAxis, yAxis] = findAxes(fig);
catch
    results.error = 'Failed to find two numeric axes';
    return;
end

% Legend classification and symbol detection
[legendEntries, cleanedFigureImage] = findLegend(fig, xAxis.textBoxIndices, yAxis.textBoxIndices, conf.legendClassifier);
if isempty(legendEntries)
    results.error = 'Failed to find legend';
    return;
end
originalImage = fig.image;
fig.image = cleanedFigureImage;

% Crop plot area
[croppedImage, cropBounds] = cropPlotArea(fig, xAxis, yAxis);

% Generate featuremaps, compute weighted sum, solve dynamic program
traces = traceData(croppedImage, legendEntries, cropBounds(2), cropBounds(1), conf);
for n = 1:length(traces)
    traces(n).xs = xAxis.model.predict(traces(n).pixelXs);
    traces(n).ys = yAxis.model.predict(traces(n).pixelYs);
end

% Plot results
fontSize = 20;
f = figure(1);
clf;
set(f, 'Position', [1 1 1000 400]);
subplot(1,2,1);
imshow(originalImage);
title('Original')
set(gca, 'fontsize', fontSize);

subplot(1,2,2);
hold on;
xMinBound = xAxis.min;
xMaxBound = xAxis.max;
yMinBound = yAxis.min;
yMaxBound = yAxis.max;
% Use linear or logarithmic axes
xIsLog = strcmp(xAxis.modelType, 'log');
yIsLog = strcmp(yAxis.modelType, 'log');
if xIsLog && yIsLog
    plotWithAxes = @loglog;
elseif xIsLog
    plotWithAxes = @semilogx;
elseif yIsLog
    plotWithAxes = @semilogy;
else
    plotWithAxes = @plot;
end
for trace = traces
    xs = xAxis.model.predict(trace.pixelXs);
    ys = yAxis.model.predict(trace.pixelYs);
    plotWithAxes(xs, ys, 'LineWidth', 5);
    % Someones we miss the true min or max tick, so set bounds that don't cut off any points
    xMinBound = min([xMinBound; xs(:)]);
    xMaxBound = max([xMaxBound; xs(:)]);
    yMinBound = min([yMinBound; ys(:)]);
    yMaxBound = max([yMaxBound; ys(:)]);
end

axis([xMinBound xMaxBound yMinBound yMaxBound]);
xlabel(xAxis.title.text);
ylabel(yAxis.title.text);
legendLabels = arrayfun(@(l) l.label, legendEntries, 'UniformOutput', false);
legend(legendLabels);
title('Reproduced');
set(gca, 'fontsize', fontSize);

results.xAxis = xAxis;
results.yAxis = yAxis;
results.legendEntries = legendEntries;
results.traces = traces;