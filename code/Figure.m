% A figure with labeled text boxes
classdef Figure
    properties
        textBoxes = [];
        image = [];
    end
    
    methods(Static)
        function f = fromFiles(imageFile, textBoxFile)
            textBoxes = loadjson(textBoxFile);
            f = Figure(imread(imageFile), textBoxes);
        end
        
        function f = fromName(name, conf)
            imageFile = fullfile(conf.figureImagePath, [name '.png']);
            textBoxFile = fullfile(conf.textPath, [name '.json']);
            f = Figure.fromFiles(imageFile, textBoxFile);
        end
    end
    
    methods
        function f = Figure(image, textBoxes)
            if nargin > 0
                f.image = image;
                f.textBoxes = textBoxes;
            end
        end
    end
end

