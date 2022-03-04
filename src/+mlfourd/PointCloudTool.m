classdef PointCloudTool < handle & mlfourd.ImagingTool
    %% POINTCLOUDTOOL is a minimal concrete subclass of ImagingTool which supports pointCloud objects
    %  from Matlab's Computer Vision Toolbox.
    %  
    %  Created 03-Mar-2022 22:14:26 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1873467 (R2021b) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    methods
        function p = pointCloud(this, varargin)
            %  Params:
            %      addNormals (logical)
            %      useMmppix (logical)

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'addNormals', false, @islogical)
            addParameter(ip, 'useMmppix', true, @islogical)
            parse(ip, varargin{:})
            ipr = ip.Results;

            img = double(this.imagingFormat_.img);
            idx = find(img);
            [I,J,K] = ind2sub(size(img), idx);
            if ~ipr.useMmppix
                xyzp(:,1) = I; % xyzpoints are ints cast as double
                xyzp(:,2) = J;
                xyzp(:,3) = K;
            else
                mmppix = double(this.imagingFormat_.mmppix);
                if isempty(mmppix) || any(isnan(mmppix))
                    mmppix = [1 1 1];
                end
                xyzp(:,1) = I .* mmppix(1); % xyzpoints are ints cast as double
                xyzp(:,2) = J .* mmppix(2);
                xyzp(:,3) = K .* mmppix(3);
            end
            p = pointCloud(xyzp, 'Intensity', img(idx));
            if ipr.addNormals
                n = pcnormals(p);
                p = pointCloud(xyzp, 'Intensity', img(idx), 'Normal', n);
            end

            % store points in space of voxels
            this.ijkPoints_(:,1) = I;
            this.ijkPoints_(:,2) = J;
            this.ijkPoints_(:,3) = K;
        end
        function setPointCloud(this, varargin)
            %  Args:
            %      pc (pointCloud, required)
            %      useMmppix (logical)
            %      filepath (folder)
            %      fileprefix (text):  Ignores common file extensions.
            %                          Default := strcat(this.fileprefix, '_setPointCloud').

            ip = inputParser;
            addRequired(ip, 'pc', @(x) isa(x, 'pointCloud'))
            addParameter(ip, 'useMmppix', true, @islogical)
            addParameter(ip, 'filepath', this.filepath, @isfolder)
            addParameter(ip, 'fileprefix', strcat(this.fileprefix, '_setPointCloud'), @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;
            this.filepath = ipr.filepath;
            this.fileprefix = myfileprefix(ipr.fileprefix);

            if ~ipr.useMmppix
                this.ijkPoints_(:,1) = round(ipr.pc.Location(:,1));
                this.ijkPoints_(:,2) = round(ipr.pc.Location(:,2));
                this.ijkPoints_(:,3) = round(ipr.pc.Location(:,3));
            else
                mmppix = double(this.imagingFormat_.mmppix);
                if isempty(mmppix) || any(isnan(mmppix))
                    mmppix = [1 1 1];
                end
                this.ijkPoints_(:,1) = round(ipr.pc.Location(:,1) ./ mmppix(1));
                this.ijkPoints_(:,2) = round(ipr.pc.Location(:,2) ./ mmppix(2));
                this.ijkPoints_(:,3) = round(ipr.pc.Location(:,3) ./ mmppix(3));
            end
            this.ensureSubInFieldOfView();
            idx = sub2ind(size(this), this.ijkPoints_(:,1), this.ijkPoints_(:,2), this.ijkPoints_(:,3));
            img = zeros(size(this));
            img(idx) = ipr.pc.Intensity;
            this.imagingFormat_.img = img;
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
            %% removes any subscripts X, Y, and Z, which are equally sized, that lie outside of 
            %  the field of view of this.anatomy.

            X = this.ijkPoints_(:,1);
            Y = this.ijkPoints_(:,2);
            Z = this.ijkPoints_(:,3);

            size_ = size(this);
            toss_ =          X < 1 | size_(1) < X;
            toss_ = toss_ | (Y < 1 | size_(2) < Y);
            toss_ = toss_ | (Z < 1 | size_(3) < Z);

            this.ijkPoints_(:,1) = X(~toss_);
            this.ijkPoints_(:,2) = Y(~toss_);
            this.ijkPoints_(:,3) = Z(~toss_);
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
