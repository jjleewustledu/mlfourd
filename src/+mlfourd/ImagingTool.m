classdef ImagingTool < handle & mlfourd.ImagingState2
	%% IMAGINGFORMATTOOL supports high-level states for imaging which must also maintain numerical data, non-trivial 
    %  meta-data, and semi-standardized storage formats such as DICOM, listmode, NIfTI, Cifti, Gifti, 4dfp, and EDF.   
    %  It provides concise support for data that are embedded in ImagingInfo objects.
    %
 	%  Created 10-Aug-2018 02:14:04 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%  Developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.

	methods         
                
        %% cast then return mutated imaging format object
        
        function this = selectFourdfpTool(this)
            this.imagingFormat_.selectFourdfpTool();
            this.addLog('mlfourd.ImagingTool.selectFourdfpTool()');
        end
        function this = selectMghTool(this)
            this.imagingFormat_.selectMghTool();
            this.addLog('mlfourd.ImagingTool.selectMghTool()');
        end
        function this = selectNiftiTool(this)
            this.imagingFormat_.selectNiftiTool();
            this.addLog('mlfourd.ImagingTool.selectNiftiTool()');
        end

        function ifc = fourdfp(this)
            %% FOURDFP first ensures this object's internal imaging format to be fourdfp, then returns the
            %  imaging format object.

            this.selectFourdfpTool();
            this.addLog('mlfourd.ImagingTool.fourdfp()');
            ifc = this.imagingFormat_;
        end
        function ifc = mgz(this)
            %% MGZ first ensures this object's internal imaging format to be mgz, then returns the
            %  imaging format object.

            this.selectMghTool();
            this.addLog('mlfourd.ImagingTool.mgz()');
            ifc = this.imagingFormat_;
        end
        function ifc = nifti(this)
            %% NIFTI first ensures this object's internal imaging format to be nifti, then returns the
            %  imaging format object.
            
            this.selectNiftiTool();
            this.addLog('mlfourd.ImagingTool.nifti()');
            ifc = this.imagingFormat_;
        end
        
        %%

        function h = histogram(this, varargin)
            h = this.imagingFormat_.histogram(varargin{:});
        end
        function [h,h1] = imagesc(this, varargin)
            figure
            this.imagingFormat_.img(logical(eye(size(this.imagingFormat_.img, 1)))) = nan;
            max_img = dipmax(this.imagingFormat_.img);
            h = imagesc(this.imagingFormat_.img, varargin{:});
            colormap('jet')
            h1 = colorbar('FontSize', 20);
            caxis([-max_img max_img])
            set(get(h1,'label'),'string', 'functional connectivity', 'FontSize', 28)
            axis('off')
            title(this.imagingFormat_.fileprefix, 'FontSize', 24, 'Interpreter', 'none')
        end
        function s = mat2str(this, varargin)
            s = mat2str(this.imagingFormat_.img, varargin{:});
        end
        function p = pointCloud(this, varargin)

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'addNormals', false, @islogical)
            addParameter(ip, 'useMmppix', false, @islogical)
            parse(ip, varargin{:})
            ipr = ip.Results;

            img = double(this.imagingFormat_.img);
            idx = find(img);
            [X,Y,Z] = ind2sub(size(img), idx);
            if ~ipr.useMmppix
                C(:,1) = X; % C are ints cast as double
                C(:,2) = Y;
                C(:,3) = Z;
            else
                mmppix = double(this.imagingFormat_.mmppix);
                if isempty(mmppix) && any(isnan(mmppix))
                    mmppix = [1 1 1];
                end
                C(:,1) = X .* mmppix(1); % C are ints cast as double
                C(:,2) = Y .* mmppix(2);
                C(:,3) = Z .* mmppix(3);
            end
            p = pointCloud(C, 'Intensity', img(idx));
            if ipr.addNormals
                n = pcnormals(p);
                p = pointCloud(C, 'Intensity', img(idx), 'Normal', n);
            end
        end
        function [s,r] = view(this, varargin)
            if isa(this, 'mlfourd.MatlabTool')
                this.selectNiftiTool();
            end
            [s,r] = this.imagingFormat_.view(varargin{:});
        end
        
        function this = ImagingTool(contexth, imagingFormat, varargin)
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
            ipr.imagingFormat.selectImagingFormatTool();
            this = this@mlfourd.ImagingState2(ipr.contexth, ipr.imagingFormat, varargin{:});
        end
    end

    %% DEPRECATED

    methods (Hidden)
        function addImgrec(this, varargin)
            this.imagingFormat_.getInnerImagingFormat.addImgrec(varargin{:}); % imgrec is a handle logger
        end
        function ensureComplex(this)
            this.imagingFormat_.ensureComplex;
        end
        function ensureDouble(this)
            this.imagingFormat_.ensureDouble;
        end
        function ensureSingle(this)
            this.imagingFormat_.ensureSingle;
        end
        function export(this, varargin)
            this.addLog('mlfourd.ImagingTool.export %s', this.fqfilename)
            this.imagingFormat_.export(varargin{:});            
        end
        function freeview(this, varargin)
            this.imagingFormat_.freeview(varargin{:});
        end
        function fsleyes(this, varargin)
            this.imagingFormat_.fsleyes(varargin{:});
        end
        function fslview(this, varargin)
            this.imagingFormat_.fslview(varargin{:});
        end
        function h = hist(this, varargin)
            h = this.imagingFormat_.hist(varargin{:});
        end        
        function l = length(~)
            l = 1;
        end
        function this = makeSimilar(this, varargin)
            %% MAKESIMILAR provides a legacy interface

            ip = inputParser;
            addParameter(ip, 'img',  this.imagingFormat_.img, @isnumeric);
            addParameter(ip, 'fileprefix', this.fileprefix, @ischar);
            addParameter(ip, 'descrip', [class(this) '.makeSimilar'], @ischar);
            parse(ip, varargin{:});
            ipr = ip.Results;

            hdr_ = this.imagingInfo.hdr;
            hdr_.hist.descrip = ipr.descrip;
            this.imagingFormat_.img = ipr.img;
            this.imagingFormat_.hdr = hdr_;            
            this.fileprefix = ipr.fileprefix;
            this.addLog(strcat('ImagingTool.makeSimilar(): ', ipr.descrip));
        end      
        function tf = sizeEq(this, varargin)
            inSize   = varargin{:}.nifti.size;
            thisSize = this.concreteObj_.size;
            tf = all(thisSize(1:3) == inSize(1:3));
        end
        function tf = sizeGt(this, varargin)
            inSize   = varargin{:}.nifti.size;
            thisSize = this.concreteObj_.size;
            tf = prod(thisSize(1:3)) > prod(inSize(1:3));
        end
        function tf = sizeLt(this, varargin)
            inSize   = varargin{:}.nifti.size;
            thisSize = this.concreteObj_.size;
            tf = prod(thisSize(1:3)) < prod(inSize(1:3));
        end
        function updateInnerImaging(this, u)
            assert(isa(u, 'mlfourd.ImagingFormatContext'));
            this.imagingFormat_ = u;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

