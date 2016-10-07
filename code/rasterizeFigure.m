function figureImage = rasterizeFigure(pdfPath, page, box, dpi, savepath)
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
    '-o' imfile ' '...
    pdfPath ' '...
    ];
    disp(cmd);
    ghostscript(cmd);
end
pageImage = imread(imfile);
figureImage = imcrop(pageImage, box);
end

