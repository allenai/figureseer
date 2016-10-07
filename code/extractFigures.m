function figureNames = extractFigures(pdfs, conf)

% Extract figures
figureNames = {};
for p = pdfs
    pdf = fullfile(conf.pdfPath, p{1});
    [~, paperName, ~] = fileparts(pdf);
    jsonPath = fullfile(conf.figureExtractionOutput, paperName);
    if exist([jsonPath '.json'], 'file') ~= 2
        cmd = [conf.pdffiguresPath...
               ' -j ' jsonPath...
               ' ' pdf];
        cmd = ['env DYLD_LIBRARY_PATH="" LD_LIBRARY_PATH="" ' cmd]; % Matlab uses an older version of libtiff incompatible with pdffigures, run with clear environment to link libpoppler correctly
        system(cmd);
    end
    
    figureExtractions = loadjson([jsonPath '.json']);
    for n = 1:length(figureExtractions)
        extraction = figureExtractions{n};
        figureName = sprintf('%s-fig%.02d', paperName, extraction.Number);
        figureNames = [figureNames {figureName}];
        scaleFactor = conf.dpi/extraction.DPI;
        imageBox = scaleBox(convertBox(extraction.ImageBB), scaleFactor);
        figureImage = rasterizeFigure(pdf, extraction.Page, imageBox, conf.dpi, conf.pageImagePath);
        imwrite(figureImage, fullfile(conf.figureImagePath, [figureName '.png']));
        textBoxes = cellfun(@(x) convertTextBox(x, scaleFactor, imageBox) ,extraction.ImageText);
        % Filter text boxes containing only whitespace
        textBoxes = textBoxes(arrayfun(@(x) ~all(isstrprop(x.text, 'wspace')), textBoxes));
        textBoxes = joinTextBoxes(num2cell(textBoxes));
        savejson('', textBoxes, fullfile(conf.textPath, [figureName '.json']));
    end
end
end

% Convert from pdffigures format to our format
function textBox = convertTextBox(pdffiguresText, scaleFactor, imageBox)
textBox.box = translateBox(scaleBox(convertBox(pdffiguresText.TextBB), scaleFactor), imageBox);
textBox.text = pdffiguresText.Text;
textBox.rotation = pdffiguresText.Rotation;
end

% convert from [x1 y1 x2 y2] (used by pdffigures) to [x1 y1 w h] (used by Matlab)
function box = convertBox(box)
box = box - [0 0 box(1) box(2)];
end

function box = scaleBox(box, scaleFactor)
box = round(scaleFactor*box);
end

% Translate from full-page coordinates to figure coordinates
function box = translateBox(box, imageBox)
box = box - [imageBox(1)-1 imageBox(2)-1 0 0];
end



