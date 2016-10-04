function figureImage = rasterize_figure(pdfPath, page, box, dpi, savepath)
% Render the given figure as a raster (pixel) image.
%
% pdfPath is the path to the pdf
% page is the page number the figure is located on
% box is the bounding box of the figure in the form [x1 y1 w h]
% dpi is the number of dots per inch to rasterize
% 

[~, paperName, ~] = fileparts(pdfPath);

page = num2str(page);
imagename = [paperName '-p' page '-d' num2str(dpi) '.png'];
imfile = fullfile(savepath, imagename);

if exist(imfile, 'file') ~= 2
    cmd = [...
    '-dSAFER ' ... % disable interactivity
    '-sDEVICE=png16m '...
    '-dFirstPage=' page ' -dLastPage=' page ' -r' num2str(dpi) ' '...
    ...%'-dTextAlphaBits=' num2str(aasubsamples) ' ' ... % text subsamples per pixel (antialiasing)
    ...%'-dGraphicsAlphaBits=' num2str(aasubsamples) ' ' ... % vector graphics subsamples per pixel (antialiasing)
    '-o' imfile ' '...
    pdfPath ' '...
    ];
    disp(cmd);
    ghostscript(cmd);
end
pageImage = imread(imfile);

% Rescale json data and crop the figure from the full rasterized page
%width = size(pageim,2);
%jsonBB = fig.ImageBB;
%scaleFactor = exconf.dpi/fig.DPI;
%imBB = [jsonBB(1), jsonBB(2), (jsonBB(3)-jsonBB(1)), (jsonBB(4)-jsonBB(2))]*scaleFactor;% * width;

figureImage = imcrop(pageImage, box);
end

