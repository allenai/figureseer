classdef Axis
    properties
        location = 0; % Position of the axis (y coordinate for x axis and vice versa)
        min = 0; % Value of the smallest axis tick
        max = 0; % Value of the largest axis tick
        model = []; % A GLM model that predicts the data value of a given pixel coordinate
        modelType = ''; % Whether the axis is linear or logarithmic
        title = ''; % The title of the axis
        textBoxIndices = []; % Indices of the text boxes comprising the axis
    end
    
    methods
        function a = Axis(location, min, max, model, modelType, title, textBoxIndices)
            if nargin > 0
                a.location = location;
                a.min = min;
                a.max = max;
                a.model = model;
                a.modelType = modelType;
                a.title = title;
                a.textBoxIndices = textBoxIndices;
            end
        end
    end
end