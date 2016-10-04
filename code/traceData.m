function traces = traceData(figureImage, legend, weights, topOffset, leftOffset)

vertexFeatures = {@pixelConvFeature, @connCompSizeFeature, @colorMatchFeature};
nFeatures = length(vertexFeatures);
nSymbols = length(legend);
score = zeros(size(figureImage,1),size(figureImage,2),nFeatures,nSymbols);
symbolColors = cell(1,nSymbols);
% For each symbol, find the most common color and binarize the symbol and
% image based on that color, then compute features.
for symbolNum = 1:length(legend)
    symbol = legend(symbolNum).symbol;
    colorvec = double(reshape(symbol, [], 3));
    [colors,~,indexedImage] = unique(colorvec,'rows');
    isWhite = ismember(colors,[255,255,255],'rows');
    assert(~all(isWhite), 'Error: empty symbol');
    colorCounts = accumarray(indexedImage,1);
    colorCounts(isWhite) = -1;
    [~,maxColorIndex] = max(colorCounts);

    binarySymbol = zeros(size(symbol,1),size(symbol,2));
    binarySymbol(indexedImage==maxColorIndex) = 1;

    binaryFigim = zeros(size(figureImage,1),size(figureImage,2));
    binaryFigim(ismember(reshape(figureImage,[],3),colors(maxColorIndex,:),'rows')) = 1; 
    
    symbolColors{symbolNum} = colors(maxColorIndex,:);

    for featNum = 1:length(vertexFeatures)
        currentScore = vertexFeatures{featNum}(binaryFigim, binarySymbol);
        score(:,:,featNum,symbolNum) = currentScore;
    end
end

% Dilate score maps and generate maps for other variables
filterRadius = round(.02*size(figureImage,1));
filterRadius = max(1,filterRadius);
dilationFilter = strel('line',filterRadius,90);

curFigScores = [];

for symbolNum = 1:nSymbols
    currentScore = [];

    otherSymbolNum = [1:symbolNum-1,symbolNum+1:nSymbols]; % Vector of indices of all other symbols

    currentScore.pixelConv = score(:,:,1,symbolNum);
    currentScore.pixelConv_Other = max(score(:,:,1,otherSymbolNum),[],4);

    pixelConvFilterHeightFactor = .01;
    pixelConvFilterHeight = round(pixelConvFilterHeightFactor*size(figureImage,1));
    pixelConvFilterHeight = max(1,pixelConvFilterHeight);
    pixelConvFilter = strel('disk',pixelConvFilterHeight);
    currentScore.pixelConvCircle = imdilate(currentScore.pixelConv,pixelConvFilter);
    currentScore.pixelConvCircle_Other = imdilate(currentScore.pixelConv_Other,pixelConvFilter);

    currentScore.ccSize = score(:,:,2,symbolNum);
    currentScore.ccSize_Other = max(score(:,:,2,otherSymbolNum),[],4);

    currentScore.colorMatch = score(:,:,3,symbolNum);

    if nSymbols == 1
      currentScore.pixelConv_Other = zeros(size(currentScore.pixelConv));
      currentScore.pixelConvCircle_Other = zeros(size(currentScore.pixelConv));
      currentScore.ccSize_Other = zeros(size(currentScore.pixelConv));
    end

    % Tensor dimensions:
    % 1: Height
    % 2: Width
    % 3: Feature
    % 4: Symbol
    curSymbolScores = cat(3, currentScore.pixelConv, currentScore.ccSize, currentScore.colorMatch);

    symbolScores = zeros(size(curSymbolScores));

    for featNum = 1:size(curSymbolScores,3)
      dilatedScore = imdilate(curSymbolScores(:,:,featNum),dilationFilter);
      symbolScores(:,:,featNum) = dilatedScore;
    end
    curFigScores = cat(4, curFigScores, symbolScores);
end

vertexScores = curFigScores;
traces(nSymbols) = Trace();
featureWeights = weights;
for symbolNum = 1:nSymbols

% Predict paths using features trained by apprenticeship learning
breathingCost = featureWeights(end-1);
slopeCost = featureWeights(end);

scoreMatrix = zeros(size(vertexScores,1),size(vertexScores,2));

featureMatrix = vertexScores(:,:,:,symbolNum);
for featNum=1:size(vertexScores,3)
    scoreMatrix = scoreMatrix + featureMatrix(:,:,featNum)*featureWeights(featNum);
end

[curXs,curYs] = findCurvePath(scoreMatrix,breathingCost,slopeCost);
pixelXs = curXs(:) + leftOffset - 1;
pixelYs = curYs(:) + topOffset - 1;
%xs = predict(xmdl.mdl,pixelXs);
%ys = predict(ymdl.mdl,pixelYs);
traces(symbolNum) = Trace(legend(symbolNum).label, [], [], pixelXs, pixelYs);

end
end

function score = colorMatchFeature(figureImage, symbol)
% All pixels matching the mode symbol color
%
% figureImage: NxM binary image
% symbol: binary image
% score: NxM real matrix
score = double(figureImage);
end

function score = pixelConvFeature(figureImage, symbol)
% Convolve the symbol with the figure at multiple angles
angleIncrement = 3;
meanValue = mean(figureImage(:));
figureImage = double(figureImage) - meanValue;
symbol = double(symbol) - meanValue;
score = zeros(size(figureImage));
for theta = -90:angleIncrement:90
    symbolRotated = imrotate(double(symbol),theta);
    score = max(score, conv2(figureImage,symbolRotated,'same'));
end
score = score + min(score(:));
assert(max(score(:))>0,'Error: all zero result');
score = score/max(score(:));
end

function score = connCompSizeFeature(figureImage, symbol)
% Find connected components on the figure close in size to those in the
% symbol
score = zeros(size(figureImage));
symbolCC = bwconncomp(symbol,8);
if symbolCC.NumObjects == 1
    return; % Solid line, return uniform score
end
symbolCCSize = cellfun(@numel,symbolCC.PixelIdxList);
symSize = median(symbolCCSize);
figureCC = bwconncomp(figureImage,8);
figureCCsize = cellfun(@numel, figureCC.PixelIdxList);
minSize = symSize*.66;
maxSize = symSize*1.5;
matchingPixels = vertcat(figureCC.PixelIdxList{figureCCsize>minSize & figureCCsize<=maxSize});
score(matchingPixels) = 1;
end