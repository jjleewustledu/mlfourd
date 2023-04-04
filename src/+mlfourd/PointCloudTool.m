classdef PointCloudTool < handle & mlfourd.ImagingTool
    %% POINTCLOUDTOOL is a minimal concrete subclass of ImagingTool which supports pointCloud objects
    %  from Matlab's Computer Vision Toolbox.
    %  
    %  Created 03-Mar-2022 22:14:26 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1873467 (R2021b) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    methods
        function ax   = pcshow(this, varargin)
            %% passes all varargin to this.pointCloud(); uses visualizations matching methods of mlfourd.PatchTool.

            ax = [];
            try
                ax = pcshow(this.contexth_.pointCloud(varargin{:}), AxesVisibility=1, ColorSource="Intensity");
                view(-210, 15) % tuned for orientstd
                daspect([1 1 1]);
    
                xlabel('x (mm)', 'FontSize', 14)
                ylabel('y (mm)', 'FontSize', 14)
                zlabel('z (mm)', 'FontSize', 14)            
                set(gca, 'xcolor', [1 1 1])
                set(gca, 'ycolor', [1 1 1])
                set(gca, 'zcolor', [1 1 1])
                %colorbar
                %colormap("jet")
            catch ME
                handwarning(ME)
            end
        end
        function p = pointCloud(this, varargin)
            %% See also web(fullfile(docroot, 'vision/ug/3-d-point-cloud-registration-and-stitching.html'))
            %  and web(fullfile(docroot, 'vision/ref/pointcloud.html#mw_eb949323-5b82-4b6c-8239-a8886734b790'))
            %  Params:
            %      addNormals (logical): default false.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'addNormals', false, @islogical)
            parse(ip, varargin{:})
            ipr = ip.Results;
            p = [];

            try
                img = double(this.imagingFormat_.img);
                img = flip(img, 1); % internal radiologic orient -> pointCloud neurologic orient
                indices = find(img);
                [I,J,K] = ind2sub(size(img), indices);
    
                % store points in space of voxels
                this.ijkPoints_ = nan(length(I), 3);
                this.ijkPoints_(:,1) = I;
                this.ijkPoints_(:,2) = J;
                this.ijkPoints_(:,3) = K;
    
                mmppix = double(this.imagingFormat_.mmppix);
                if isempty(mmppix) || any(isnan(mmppix))
                    mmppix = [1 1 1];
                end
    
                % xyzpoints are ints cast as double
                xyzp(:,1) = I .* mmppix(1); 
                xyzp(:,2) = J .* mmppix(2);
                xyzp(:,3) = K .* mmppix(3);
    
                ii = double(img(indices));
                ii = ii/max(ii);
                p = pointCloud(xyzp, 'Intensity', ii);
                if ipr.addNormals
                    n = pcnormals(p);
                    p = pointCloud(xyzp, 'Intensity', ii, 'Normal', n);
                end
            catch ME
                handwarning(ME)
            end
        end
        function setPointCloud(this, varargin)
            %  Args:
            %      pc (pointCloud, required)
            %      filepath (folder)
            %      fileprefix (text):  Ignores common file extensions.
            %                          Default := strcat(this.fileprefix, '_setPointCloud').

            ip = inputParser;
            addRequired(ip, 'pc', @(x) isa(x, 'pointCloud'))
            addParameter(ip, 'filepath', this.filepath, @isfolder)
            addParameter(ip, 'fileprefix', strcat(this.fileprefix, '_setPointCloud'), @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;
            this.filepath = ipr.filepath;
            this.fileprefix = myfileprefix(ipr.fileprefix);

            try
                mmppix = double(this.imagingFormat_.mmppix);
                if isempty(mmppix) || any(isnan(mmppix))
                    mmppix = [1 1 1];
                end
                this.ijkPoints_(:,1) = round(ipr.pc.Location(:,1) ./ mmppix(1));
                this.ijkPoints_(:,2) = round(ipr.pc.Location(:,2) ./ mmppix(2));
                this.ijkPoints_(:,3) = round(ipr.pc.Location(:,3) ./ mmppix(3));
    
                this.ensureSubInFieldOfView();
                indices = sub2ind(size(this), this.ijkPoints_(:,1), this.ijkPoints_(:,2), this.ijkPoints_(:,3));
                img = zeros(size(this));
                if isempty(ipr.pc.Intensity)
                    intens = ones(size(ipr.pc.Location, 1), 1);
                else
                    intens = ipr.pc.Intensity;
                end
                img(indices) = intens;
                img = flip(img, 1); % pointCloud neurologic orient -> internal radiologic orient
                this.imagingFormat_.img = img;
            catch ME
                handwarning(ME)
            end
        end

        function this = PointCloudTool(contexth, imagingFormat, varargin)
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

    %% PRIVATE

    properties (Access = private)
        ijkPoints_
    end
    methods (Access = private)
        function ensureSubInFieldOfView(this)
            %% repositions any subscripts X, Y, and Z that lie outside of 
            %  the field of view of this.ijkPoints_.

            X = this.ijkPoints_(:,1);
            Y = this.ijkPoints_(:,2);
            Z = this.ijkPoints_(:,3);
            
            size_ = size(this);
            X(X < 1) = 1;
            X(size_(1) < X) = size_(1);
            Y(Y < 1) = 1;
            Y(size_(2) < Y) = size_(2);
            Z(Z < 1) = 1;
            Z(size_(3) < Z) = size_(3);
            
            this.ijkPoints_ = [X, Y, Z];
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
