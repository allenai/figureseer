conf = setConf();

% Extract figures from PDFs
pdfs = arrayfun(@(f) f.name, dir(fullfile(conf.pdfPath, '*.pdf')), 'UniformOutput', false);

figureNames = extractFigures(pdfs, conf);

% Extract subfigures
if conf.extractSubfigures
    subfigureNames = {};
    for n = 1:length(figureNames)
        figureName = figureNames{n};
        fig = Figure.fromName(figureName, conf);
        subfigures = findSubfigures(fig);
        set(gcf, 'Position', [1 1 500 500]);
        export_fig(fullfile(conf.subfigureVisPath, figureName), '-native');
        for m = 1:length(subfigures)
            subfigureName = sprintf('%s-subfig%.02d', figureName, m);
            imwrite(subfigures(m).image, fullfile(conf.figureImagePath, [subfigureName '.png']));
            savejson('', subfigures(m).textBoxes, fullfile(conf.textPath, [subfigureName '.json']));
            subfigureNames = [subfigureNames subfigureName];
        end
    end
    figureNames = subfigureNames;
end

% Classify figures
net = caffe.Net(conf.figureClassNet, conf.figureClassWeights, 'test');
for n = 1:length(figureNames)
    figureName = figureNames{n};
    fprintf('Classifying %s\n', figureName);
    fig = Figure.fromName(figureName, conf);
    tenCropImage = prepareImage(fig.image, conf.figureClassMean);
    cropPredictions = net.forward({tenCropImage});
    classPredictions = mean(cropPredictions{1}, 2);
    savejson('',classPredictions,fullfile(conf.classPredictionPath,[figureName '.json']));
end
caffe.reset_all();

% Parse figures
for n = 1:length(figureNames)
    figureName = figureNames{n};
    fprintf('Parsing %s\n', figureName);
    fig = Figure.fromName(figureName, conf);
    result = parseChart(fig, conf);
    if isfield(result, 'error')
        disp(result.error);
        continue;
    end
    result.xAxis = rmfield(struct(result.xAxis), 'model'); % Can't save matlab GLM type to Json
    result.yAxis = rmfield(struct(result.yAxis), 'model');
    savejson('', result, fullfile(conf.resultJsonPath, [figureName '.json']));
    export_fig(fullfile(conf.resultImagePath, [figureName '-result.png']),'-native');
end

% Output results PDFs
for n = 1:length(pdfs)
    paperName = pdfs{n}(1:end-4);
    outputResultsPdf(paperName, conf);
end