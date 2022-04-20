classdef PatchTool < handle & mlfourd.ImagingTool
    %% POINTCLOUDTOOL is a minimal concrete subclass of ImagingTool which supports patch objects.
    %  
    %  Created 26-Mar-2022 15:14:30 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.12.0.1884302 (R2022a) for MACI64.  Copyright 2022 John J. Lee.
    
    methods
        function p = patch(this, varargin)
            %% See also web(fullfile(docroot, 'matlab/visualize/displaying-complex-three-dimensional-objects.html'))
            %  Params:
            %      isovalue (scalar): specify volume data equal to isovalue.
            %      EdgeColor (color): default 'none'.
            %      FaceAlpha (scalar): transparency < 1.
            %      FaceColor (color): default [0.5 0.618 0.98].
            %      LightPosition (vector): default [-0.4, 0.2, 0.9].
            %      lighting (text): 'gouraud' (default), 'flat' or 'none'.
            %      LineStyle (text)
            %      material (text): 'shiny' (default), 'metal', 'dull' or 'default'.
            %      use_isonormals (logical): works best for smoooth data, default false.

            ip = inputParser;
            ip.KeepUnmatched = true;
            ip.PartialMatching = false;
            addParameter(ip, 'isovalue', [], @isnumeric);
            addParameter(ip, 'EdgeColor', 'none', @(x) isnumeric(x) || istext(x));
            addParameter(ip, 'FaceAlpha', '', @(x) isnumeric(x) || istext(x));
            addParameter(ip, 'FaceColor', [0.5 0.618033988749895 0.98], @(x) isnumeric(x) || istext(x));
            addParameter(ip, 'LightPosition', [-0.4, 0.2, 0.9], @isvector);
            addParameter(ip, 'lighting', 'gouraud', @istext);
            addParameter(ip, 'LineStyle', '', @istext);
            addParameter(ip, 'material', 'metal', @istext);
            addParameter(ip, 'use_isonormals', false, @islogical);
            parse(ip, varargin{:})
            ipr = ip.Results;

            img = double(this.imagingFormat_.img);
            img = flip(img, 1); % internal representations have radiologic orientation

            mmppix = this.imagingFormat_.mmppix;
            if isempty(mmppix) || any(isnan(mmppix))
                mmppix = [1 1 1];
            end
            N = (size(img) - 1) .* mmppix;
            [X_,Y_,Z_] = meshgrid(0:mmppix(1):N(1), 0:mmppix(2):N(2), 0:mmppix(3):N(3));
            X = permute(X_, [2 1 3]);
            Y = permute(Y_, [2 1 3]);
            Z = permute(Z_, [2 1 3]);

            if isempty(ipr.isovalue)
                p = patch(isosurface(X, Y, Z, img));
            else
                p = patch(isosurface(X, Y, Z, img, ipr.isovalue));
            end
            p.FaceLighting = 'gouraud';
            if ~isempty(ipr.EdgeColor)
                p.EdgeColor = ipr.EdgeColor;
            end
            if ~isempty(ipr.FaceAlpha)
                p.FaceAlpha = ipr.FaceAlpha;
            end
            if ~isempty(ipr.FaceColor)
                p.FaceColor = ipr.FaceColor;
            end
            if ~isempty(ipr.LineStyle)
                p.LineStyle = ipr.LineStyle;
            end
            if ipr.use_isonormals
                isonormals(X_,Y_,Z_,img, p, 'negate');
            end
            view(3);
            daspect([1 1 1]);
            axis tight;

            light('Position', ipr.LightPosition, 'Style', 'infinite')
            lighting(ipr.lighting);
            material(ipr.material);
            set(gcf, 'Color', [0 0 0])
            set(gca, 'Color', [0 0 0])
            set(gca, 'xcolor', [1 1 1])
            set(gca, 'ycolor', [1 1 1])
            set(gca, 'zcolor', [1 1 1])
            set(gca, 'FontSize', 14)
            
            xlabel('x (mm)')
            ylabel('y (mm)')
            zlabel('z (mm)')
        end

        function this = PatchTool(contexth, imagingFormat, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): provides numerical imaging data.  
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.  
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingContext2'))
            addRequired(ip, 'imagingFormat',  @(x) isa(x, 'mlfourd.IImagingFormat'))
            parse(ip, contexth, imagingFormat, varargin{:})
            ipr = ip.Results;
            if isnumeric(ipr.imagingFormat)
                ipr.imagingFormat = mlfourd.ImagingFormatContext2(ipr.imagingFormat, varargin{:});
            end
            ipr.imagingFormat.selectMatlabFormatTool();
            this = this@mlfourd.ImagingTool(ipr.contexth, ipr.imagingFormat, varargin{:})
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
