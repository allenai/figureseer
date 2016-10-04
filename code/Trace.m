classdef Trace
    properties
        label = ''
        xs = []
        ys = []
        pixelXs = []
        pixelYs = []
    end
    methods
        function t = Trace(label, xs, ys, pixelXs, pixelYs)
            if nargin > 0
                t.label = label;
                t.xs = xs;
                t.ys = ys;
                t.pixelXs = pixelXs;
                t.pixelYs = pixelYs;
            end
        end
    end
end