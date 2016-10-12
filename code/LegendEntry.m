classdef LegendEntry
    properties
        label = ''; % Name of the variable
        labelIndex = 0; % Index of the label text box
        symbol = zeros(0,0,3); % Image of the symbol
    end
    
    methods
        function l = LegendEntry(label, labelIndex, symbol)
            if nargin > 0
                l.label = label;
                l.labelIndex = labelIndex;
                l.symbol = symbol;
            end
        end
    end
end