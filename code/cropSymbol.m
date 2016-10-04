% cropSymbol
function [leftBound, topBound, rightBound, botBound, cropsym] = cropSymbol(symbol)

graysymbol = rgb2gray(symbol);
columnNonwhite = sum(graysymbol~=255,1);

% Crop off whitespace on the left side
leftBound = find(columnNonwhite~=0,1);
assert(~isempty(leftBound), 'Empty symbol')

space = 0;
rightBound = leftBound;
spacefactor = .5;
    
while (rightBound < numel(columnNonwhite) && space < size(symbol,1) * spacefactor)
    space = space + 1;
    rightBound = rightBound + 1;
    if columnNonwhite(rightBound) ~= 0
        space = 0;
    end
end
rightBound = rightBound - space;

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

cropsym = imcrop(symbol,[leftBound,topBound,rightBound-leftBound,botBound-topBound]);