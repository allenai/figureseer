function [leftTrim, topTrim, rightTrim, botTrim, croppedSymbol] = cropLegendSymbol(symbol)
% Crop whitespace from the symbol and return the modifications made
% to the bounding box

graysymbol = rgb2gray(symbol);
columnNonwhite = sum(graysymbol~=255,1);

% Crop off whitespace on the left side
leftBound = find(columnNonwhite~=0,1);
assert(~isempty(leftBound), 'Empty symbol')

currentGap = 0;
rightBound = leftBound;
maxGap = .5*size(symbol,1);
while (rightBound < numel(columnNonwhite) && currentGap < maxGap)
    currentGap = currentGap + 1;
    rightBound = rightBound + 1;
    if columnNonwhite(rightBound) ~= 0
        currentGap = 0;
    end
end
rightBound = rightBound - currentGap;

whiteRows = sum(graysymbol(:,leftBound:rightBound)~=255,2)==0;

% If legend symbol isn't perfectly on center, look for it so we don't crop
% out the whole thing
middleRow = round(length(whiteRows)/2);
offset = 0;
while whiteRows(middleRow+offset) && whiteRows(middleRow-offset)
    assert(middleRow+offset>1 && middleRow-offset<length(whiteRows), 'Error: cropped entire image');
    offset = offset + 1;
end

if ~whiteRows(middleRow+offset)
    middleRow = middleRow+offset;
else
    middleRow = middleRow-offset;
end


topBound = middleRow;
while topBound >= 1 && ~whiteRows(topBound)
    topBound = topBound - 1;
end
topBound = topBound + 1;
botBound = middleRow;
while botBound <= numel(whiteRows) && ~whiteRows(botBound)
    botBound = botBound + 1;
end
botBound = botBound - 1;

croppedSymbol = imcrop(symbol,[leftBound,topBound,rightBound-leftBound,botBound-topBound]);
leftTrim = leftBound - 1;
topTrim = topBound - 1;
botTrim = botBound + 1;
rightTrim = rightBound + 1;
return;