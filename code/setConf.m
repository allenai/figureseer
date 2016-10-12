function conf = setConf()
currentPath = fileparts(mfilename('fullpath'));
figseerRoot = fullfile(currentPath,'..');

% Dependencies
conf.caffePath = '~/repos/caffe/matlab';
conf.pdffiguresPath = fullfile(figseerRoot, 'dependencies', 'pdffigures', 'pdffigures'); % Point to the executable
conf.exportFigPath = fullfile(figseerRoot, 'dependencies', 'export_fig');
conf.pdflatex = '/usr/texbin/pdflatex';

% Intermediate directories
dataPath = fullfile(figseerRoot, 'data');
interPath = fullfile(dataPath, 'intermediate');
conf.figureExtractionOutput = fullfile(interPath, 'figure-extraction-output');
conf.pageImagePath = fullfile(interPath, 'pages');
conf.figureImagePath = fullfile(interPath, 'figure-images');
conf.subfigureVisPath = fullfile(interPath, 'subfigure-vis');
conf.textPath = fullfile(interPath, 'figure-text');
conf.classPredictionPath = fullfile(interPath, 'class-predictions');
conf.resultImagePath = fullfile(interPath, 'result-images');
conf.resultTexPath = fullfile(interPath, 'tex');
[~,~] = mkdir(conf.figureExtractionOutput);
[~,~] = mkdir(conf.pageImagePath);
[~,~] = mkdir(conf.figureImagePath);
[~,~] = mkdir(conf.subfigureVisPath);
[~,~] = mkdir(conf.textPath);
[~,~] = mkdir(conf.classPredictionPath);
[~,~] = mkdir(conf.resultImagePath);
[~,~] = mkdir(conf.resultTexPath);

% Input and output
conf.pdfPath = fullfile(dataPath, 'pdfs');
outputPath = fullfile(dataPath, 'output');
conf.resultPdfPath = fullfile(outputPath, 'result-pdfs');
conf.resultJsonPath = fullfile(outputPath, 'result-jsons');
[~,~] = mkdir(conf.resultPdfPath);
[~,~] = mkdir(conf.resultJsonPath);

% Models
parsingModels = load(fullfile(dataPath, 'models', 'parsingModels'));
conf.legendClassifier = parsingModels.legendClassifier;
conf.tracingWeights = parsingModels.tracingWeights;

% Neural networks
nnPath = fullfile(dataPath, 'models', 'neural-networks');
conf.figureClassNet = fullfile(nnPath, 'figure_class_deploy.prototxt');
conf.figureClassWeights = fullfile(nnPath, 'figure_class_snapshot_iter_450000.caffemodel');
conf.figureClassMean = fullfile(nnPath, 'figure_class_mean.mat');

% Configuration
conf.usePatchCnn = false;
conf.useGPU = false;
conf.extractSubfigures = true;
conf.dpi = 200;

% Setup
addpath(conf.caffePath);
if conf.useGPU
    caffe.set_mode_gpu;
else
    caffe.set_mode_cpu;
end
addpath(conf.exportFigPath);
if exist(fullfile(currentPath,'findPath')) ~= 3
    mex findPath.c;
end