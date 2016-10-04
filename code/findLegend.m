function [legendEntries, cleanedImage] = find_legend(fig, xAxisTextIndices, yAxisTextIndices, legendClassifier)
% legendEntries is a list of the variables in the legend and their symbols
% cleanedImage is the figure image with legend symbols whited out

figWidth = size(fig.image,2);
figHeight = size(fig.image,1);
nTextBoxes = length(fig.textBoxes);
% Generate features for each text box
figTextFeats = [];
for n = 1:nTextBoxes
    % Position features
    feats = table();
    textBox = fig.textBoxes{n};
    xPosition = textBox.box(1)+textBox.box(3)/2;
    yPosition = textBox.box(2)+textBox.box(4)/2;
    feats.xPos = xPosition/figWidth;
    feats.yPos = yPosition/figHeight;
    
    % Text features
    feats.stringLength = length(textBox.text);
    feats.isNumeric = ~isnan(str2double(textBox.text));

    % Nearby textbox features
    sameColumn = cellfun(@(tb) tb.box(1) <= xPosition && tb.box(3) >= xPosition, fig.textBoxes);
    sameRow = cellfun(@(tb) tb.box(2) <= yPosition && tb.box(4) >= yPosition, fig.textBoxes);
    feats.numInCol = sum(sameColumn)-1;
    feats.numInRow = sum(sameRow)-1;

    figTextFeats = [figTextFeats; feats];
end

isLegend = predict(legendClassifier,table2array(figTextFeats));
isLegend = strcmp(isLegend,'1');
legendIdx = find(isLegend);

% Extract legend symbols
[symbols, symbolBbs] = getSymbols(fig, isLegend);
emptySymbolVec = cellfun(@isempty, symbolBbs);
allWhiteSymbolVec = cellfun(@(symbol) all(symbol(:)==255), symbols);
validSymbolIndices = ~emptySymbolVec & ~allWhiteSymbolVec;
legendIdx = legendIdx(validSymbolIndices);
cleanedImage = fig.image;
if isempty(legendIdx)
    legendEntries = [];
    return
end
symbols = symbols(validSymbolIndices);
symbolBbs = symbolBbs(validSymbolIndices);

legendEntries(length(symbols)) = LegendEntry();
for n = 1:length(symbols)
    index = legendIdx(n);
    label = fig.textBoxes{index}.text;
    legendEntries(n) = LegendEntry(label, index, symbols{n});
    cleanedImage = whiteOutBox(cleanedImage, symbolBbs{n});
end


function [finalSymbols, symbolBbs] = getSymbols(fig, isLegend)
% Given a figure and logical vector indicating legend labels, return
% symbols and their bounding boxes.
noTextImage = fig.image;
for textBox = fig.textBoxes
    noTextImage = whiteOutBox(noTextImage, textBox{1}.box);
end

legendIndices = find(isLegend == 1);
nSymbols = length(legendIndices);
legendSymbolsBb = cell(size(legendIndices));
for symbolNum = 1:nSymbols
    textBox = fig.textBoxes{legendIndices(symbolNum)};
    heightfactor = 5;
    width = textBox.box(4)*heightfactor;
    symbols.textBb = textBox.box;
    symbols.leftBb = textBox.box + [-width, 0, width-textBox.box(3), 0];
    symbols.rightBb = textBox.box + [textBox.box(3), 0, width-textBox.box(3), 0];
    legendSymbolsBb{symbolNum} = symbols;
end

% If any connected component of nonwhite pixels has the majority of its
% pixels outside of all symbol boxes, it's probably not part of a symbol.
nonwhite = ~im2bw(noTextImage,1-eps); % All nonwhite pixels are 1
nonwhiteCC = bwconncomp(nonwhite);
inBox = @(y,x,box) x>=box(1)&x<=box(1)+box(3)&y>=box(2)&y<=box(2)+box(4);
maxInSymbolBoxes = zeros(size(nonwhiteCC.PixelIdxList));
for symbolNum = 1:nSymbols
    [ys,xs] = cellfun(@(ind) ind2sub(size(nonwhite),ind), nonwhiteCC.PixelIdxList, 'UniformOutput', false);
    pctInRightBox = cellfun(@(y,x) mean(inBox(y,x,legendSymbolsBb{symbolNum}.rightBb)), ys, xs);
    pctInLeftBox = cellfun(@(y,x) mean(inBox(y,x,legendSymbolsBb{symbolNum}.leftBb)), ys, xs);
    maxInSymbolBoxes = max(maxInSymbolBoxes, max(pctInRightBox, pctInLeftBox));
end
outsidePixelIdxList = nonwhiteCC.PixelIdxList(maxInSymbolBoxes<.5);

for textBox = 1:length(outsidePixelIdxList)
    [ys,xs] = ind2sub(size(nonwhite), outsidePixelIdxList{textBox});
    r = sub2ind(size(fig.image),ys,xs,ones(size(ys)));
    g = sub2ind(size(fig.image),ys,xs,2*ones(size(ys)));
    b = sub2ind(size(fig.image),ys,xs,3*ones(size(ys)));
    noTextImage([r;g;b]) = 255;
end

for symbolNum = 1:nSymbols
    textBox = fig.textBoxes{legendIndices(symbolNum)};
    symbols = legendSymbolsBb{symbolNum};
    heightfactor = 7;
    width = textBox.box(4)*heightfactor;
    symbols.text = imcrop(noTextImage, textBox.box);
    symbols.left = imcrop(noTextImage, symbols.leftBb);
    symbols.right = imcrop(noTextImage, symbols.rightBb);
    legendSymbolsBb{symbolNum} = symbols;
end

leftPixelProduct = 1;
rightPixelProduct = 1;
for symbolNum=1:nSymbols
    cursym = legendSymbolsBb{symbolNum};
    
    leftPixelCount = countNonwhitePixels(cursym.left);
    rightPixelCount = countNonwhitePixels(cursym.right);
    
    if leftPixelCount ~= 0 || rightPixelCount ~= 0
        leftPixelProduct = leftPixelProduct * leftPixelCount;
        rightPixelProduct = rightPixelProduct * rightPixelCount;
    end
end

if leftPixelProduct >= rightPixelProduct
    direction = -1;
else
    direction = 1;
end

symbolBbs = cell(size(legendIndices));
croppedSymbols = cell(size(legendIndices));
for symbolNum=1:nSymbols
    if direction == 1
        symbol = legendSymbolsBb{symbolNum}.right;
        symbolBb = legendSymbolsBb{symbolNum}.rightBb;
    else
        symbol = legendSymbolsBb{symbolNum}.left;
        symbol = fliplr(symbol);
        symbolBb = legendSymbolsBb{symbolNum}.leftBb;
    end
    if(all(symbol(:)==255))
        continue; % Symbol is empty
    end
    [leftTrim,topTrim,rightTrim,botTrim,croppedSymbols{symbolNum}] = cropSymbol(symbol);
    if direction == 1
        symbolBbs{symbolNum} = symbolBb + [leftTrim, topTrim, -leftTrim-rightTrim, -topTrim-botTrim];
    else
        croppedSymbols{symbolNum} = fliplr(croppedSymbols{symbolNum});
        symbolBbs{symbolNum} = symbolBb + [rightTrim, topTrim, -rightTrim-leftTrim, -topTrim-botTrim]; %CHECK THIS
    end
end

finalSymbols = cell(size(legendIndices));
for symbolNum=1:nSymbols
    if ~isempty(symbolBbs{symbolNum})
        finalSymbols{symbolNum} = imcrop(fig.image, symbolBbs{symbolNum});
    end
end