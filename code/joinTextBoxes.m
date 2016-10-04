function textBoxes = joinTextBoxes(textBoxes)
% Concatenate adjacent textboxes with the same orientation.
% This implementation is inefficient, but the number of text boxes is
% typically small.
%
% imagetext is a cell array of structures, as in figdata.ImageText.

for n = 1:length(textBoxes)
    textBoxes{n}.box = whToBounds(textBoxes{n}.box);
end
% Join one text box per iteration, continue until no text boxes are joined.
wasJoined = true;
while wasJoined
    [textBoxes, wasJoined] = joinTextOnce(textBoxes);
end
for n = 1:length(textBoxes)
    textBoxes{n}.box = boundsToWh(textBoxes{n}.box);
end
end

function [textBoxes, wasJoined] = joinTextOnce(textBoxes)
% Look for an adjacent pair of text boxes to concatenate. If such a pair is
% found, set wasjoined to true.
wasJoined = false;

% Maximum difference between top and bottom of text boxes to join as a factor of text box height
MARGIN_FACTOR = .2;
% Maximum allowed space between text boxes to join as a factor of text box height
SPACE_FACTOR = .5;

% Check each pair of text boxes to see if they are adjacent
for n = 1:size(textBoxes,2)
    for m = [1:(n-1) (n+1):size(textBoxes,2)]
        aText = textBoxes{n};
        bText = textBoxes{m};
        % Determine text orientation
        if (aText.rotation == 0) && (bText.rotation == 0)
            % Both text boxes are horizontal
            topdim = 4;
            botdim = 2;
            leftdim = 1;
            rightdim = 3;
        elseif (aText.rotation == 3) && (bText.rotation == 3)
            % Both text boxes are vertical
            topdim = 3;
            botdim = 1;
            leftdim = 4;
            rightdim = 2;
        else
            % Different orientations
            continue
        end
        a.top = aText.box(topdim);
        a.bot = aText.box(botdim);
        a.left = aText.box(leftdim);
        a.right = aText.box(rightdim);
        b.top = bText.box(topdim);
        b.bot = bText.box(botdim);
        b.left = bText.box(leftdim);
        b.right = bText.box(rightdim);
        charHeight = max(a.top-a.bot, b.top-b.bot);
        
        % The maximum allowed difference between the tops of the boxes and
        % between the bottoms of the boxes
        margin = charHeight*MARGIN_FACTOR;
        
        % The maximum allowed space between the boxes
        space = charHeight*SPACE_FACTOR;
        
        % Check if the text boxes satisfy the adjacency condition
        if (abs(a.top - b.top) <= margin) && (abs(a.bot - b.bot) <= margin) && (abs(a.right - b.left) <= space)
            % Concatenate text
            textBoxes{n}.text = [aText.text ' ' bText.text];
            % New bounding box will encompass both boxes
            newBox = zeros(1,4);
            newBox(topdim) = max(a.top,b.top);
            newBox(botdim) = min(a.bot,b.bot);
            newBox(leftdim) = a.left;
            newBox(rightdim) = b.right;
            textBoxes{n}.box = newBox;
            textBoxes(m) = [];
            wasJoined = true;
            return;
        end
    end
end
end