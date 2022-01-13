classdef MaskingTool < handle & mlfourd.ImagingTool
	%% MASKINGTOOL
    %
    
    %% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2017 John Joowon Lee.
        
    properties (Constant)
        MASKEDBY = '_maskedby'
        MAX_VOLUME_FRACTION = 0.5
    end
    
    methods
        function this = binarized(this)
            %% BINARIZED
            %  @return inner image is numerical and binary: 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            this.imagingFormat_.img  = double(this.imagingFormat_.img ~= 0);
            this.imagingFormat_ = this.imagingFormat_.reset_scl;
            this.warnLargeVolumeFraction;
            this.fileprefix = strcat(this.fileprefix, '_binarized');  
            this.addLog('MaskingTool.binarized');
        end
        function n    = count(this)
            %% COUNT 
            %  @return N = nonzero elements in the inner imaging.
            
            n = dipsum(this.imagingFormat_.img ~= 0);
        end
        function this = imfill(this, varargin)
            %% IMFILL calls Matlab's imfill.

            this.imagingFormat_.img = imfill(logical(this.imagingFormat_.img), varargin{:});
            this.fileprefix = strcat(this.fileprefix, '_imfill');  
            this.addLog('MaskingTool.imfill');
        end
        function this = masked(this, M)
            %% MASKED
            %  @param M is understood by ImagingContext2.  It need not be binary; if max(M) > 1, M will be rescaled such that max(M) == 1.
            %  @return the inner image is masked by M.
            %  @warning mflourd:possibleMaskingError
            
            M = mlfourd.ImagingContext2(M);
            mimg = M.nifti.img;
            maxMimg = dipmax(mimg);
            if (maxMimg > 1)
                this.warnNonUnitMask(M);
                mimg = mimg / maxMimg;
            end
            switch (this.ndims)
                case 2
                    this = this.masked2d(mimg);
                case 3
                    this = this.masked3d(mimg);
                case 4
                    this = this.masked4d(mimg);
                otherwise
                    error('mlfourd:unsupportedSwitchcase', 'MaskingTool.masked.ndims->%i', this.ndims);
            end
            this.warnLargeVolumeFraction;
            this.fileprefix = sprintf('%s%s_%s', this.fileprefix, this.MASKEDBY, M.fileprefix);
            this.addLog('MaskingTool.masked by %s', M.fileprefix);
        end
        function this = maskedMaths(this, M, funch, varargin)
            %  @param M is understood by ImagingContext2 and masks the inner imaging.
            %  @param funch is a function handle.
            %  @return this with updated inner imaging.
            
            ip = inputParser;
            addRequired(ip, 'M');
            addRequired(ip, 'funch', @(x) isa(x, 'function_handle'));
            parse(ip, M, funch);
            M = mlfourd.ImagingContext2(M);
            
            v = this.imagingFormat_.img(M.nifti.img == 1);
            this.imagingFormat_.img = funch(v, varargin{:});
            this.fileprefix = sprintf('%s_maskedMaths_%s_%s', ...
                this.fileprefix, M.fileprefix, func2str(funch));
            this.addLog('MaskingTool.maskedMaths %s %s', M.fileprefix, func2str(funch));
        end
        function this = maskedByZ(this, rng)
            %% MASKEDBYZ
            %  @param rng := [low-z high-z].
            %  @return inner image is cropped along z by rng.  
            
            assert(isnumeric(rng));
            assert(1 <= rng(1) && rng(1) < rng(2) && rng(2) <= size(this, 3));            
            size_  = this.size;
            zimg   = ones( size_(1:3));
            zslice = zeros(size_(1:2));
            for z = 1:size_(3)
                if (z < rng(1) || rng(2) < z)
                    zimg(:,:,z) = zslice;
                end
            end
            
            warning('off', 'mlfourd:possibleMaskingError');
            fp = this.fileprefix;
            this = this.masked(zimg);
            this.fileprefix = fp;
            warning('on',  'mlfourd:possibleMaskingError');
            this.fileprefix = sprintf('%s_maskedbyz%i-%i', this.fileprefix, rng(1), rng(2));
            this.addLog('MaskingTool.maskedByZ range %s', mat2str(rng));
        end
        function this = roi(this, varargin)
            %% ROI emulates fslroi; see also zoomed.

            this = this.zoomed(varargin{:});
        end
        function this = thresh(this, t)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)

            assert(isscalar(t));
            bin  = this.imagingFormat_.img >= t;
            this.makeSimilar( ...
                   'img', double(this.imagingFormat_.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_thr%s', this.fileprefix, this.decimal2str(t)), ...
                   'descrip',    sprintf('MaskingTool.thresh(%g)', t));
            this.addLog('MaskingTool.thresh(%g)', t);
        end
        function this = threshp(this, p)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            
            if p > 1
                p = p/100;
            end
            img  = this.imagingFormat_.img;
            bin  = img >= p*dipiqr(img(img > 0.01*dipmax(img)));
            this.makeSimilar( ...
                   'img', double(this.imagingFormat_.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_thrp%s', this.fileprefix, this.prct2str(p)), ...
                   'descrip',    sprintf('MaskedNIfTId.threshp(%g)', p));
            this.addLog('MaskingTool.threshp(%g)', p);
        end 
        function this = uthresh(this, t)
            %% UTHRESH
            %  @param t:  use t to upper-threshold current image (zero anything above the number)
            
            assert(isscalar(t));
            bin  = this.imagingFormat_.img <= t;
            this.makeSimilar( ...
                   'img', double(this.imagingFormat_.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_uthr%s', this.fileprefix, this.decimal2str(t)), ...
                   'descrip',    sprintf('MaskingTool.uthresh(%g)', t));
            this.addLog('MaskingTool.uthresh(%g)', t);
        end
        function this = uthreshp(this, p)
            %% UTHRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to upper-threshold current image (zero anything above the number)
            
            if p > 1
                p = p/100;
            end
            img  = this.imagingFormat_.img;
            bin  = img <= p*dipiqr(img(img > 0.01*dipmax(img)));
            this.makeSimilar( ...
                   'img', double(this.imagingFormat_.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_uthrp%s', this.fileprefix, this.prct2str(p)), ...
                   'descrip',    sprintf('MaskedNIfTId.uthreshp(%g)', p));
            this.addLog('MaskingTool.uthreshp(%g)', p);
        end  
        function this = zoom(this, varargin)
            this = this.zoomed(varargin{:});
        end  
        function this = zoomed(this, varargin)
            %% ZOOMED parameters resembles fslroi, but indexing starts with 1 and passing -1 for a size will set it to 
            %  the full image extent for that dimension.
            %  @param xmin|fac is required.  Solitary fac symmetrically sets Euclidean (not time) size := fac*size and
            %                                symmetrically sets all min.
            %  @param xsize is optional.
            %  @param ymin  is optional.
            %  @param ysize is optional.
            %  @param zmin  is optional.
            %  @param zsize is optional.
            %  @param tmin  is optional.  Solitary tmin with tsize is supported.
            %  @param tsize is optional.            
            %  @returns this

            this.imagingFormat_ = this.imagingFormat_.zoomed(varargin{:});
        end
        
        function this = MaskingTool(varargin)
            this = this@mlfourd.ImagingTool(varargin{:});
        end
        
    end
    
    %% PRIVATE
    
    methods (Static, Access = private)
        function s = decimal2str(d)
            s = strrep(num2str(d), '.', 'p');
        end
        function tf = isZeroToOne(obj)
            img = double(obj);
            dmx = dipmax(img);
            dmn = dipmin(img);
            tf  = ~(dmn < 0 || 1 < dmx);
        end
        function s = prct2str(p)
            if (p < 1)
                p = 100*p;
            end
            s = num2str(round(p));
        end
        function mimg = reptimes(mimg, ntimes)
            assert(isnumeric(mimg));
            img = zeros([size(mimg) ntimes]);
            for t = 1:ntimes
                img(:,:,:,t) = mimg;
            end
            mimg = img;
        end
        function mimg = repz(mimg, nz)
            assert(isnumeric(mimg));
            img = zeros([size(mimg) nz]);
            for z = 1:nz
                img(:,:,z) = mimg;
            end
            mimg = img;
        end
        function warnNonUnitMask(M)
            mimg = M.nifti.img;
            assert(isempty(mimg(mimg < 0)));
            warning('mlfourd:possibleMaskingError', 'MaskingTool.warnNonUnitMask.M has max->%g', dipmax(mimg));
            histogram(mimg(mimg > 0), 100, 'Normalization', 'probability');
            xlabel('mask amplitude');
            ylabel('probability');
            title(sprintf('MaskingTool.warnNonUnitMask:  %s', M.fqfilename));
        end
    end
    
    methods (Access = private)
        function this = masked2d(this, mimg)
            this.imagingFormat_.img = this.imagingFormat_.img .* mimg;
        end
        function this = masked3d(this, mimg)
            if (ismatrix(mimg))
                mimg = this.repz(mimg, size(this,3));
            end            
            this.imagingFormat_.img = this.imagingFormat_.img .* mimg;
        end
        function this = masked4d(this, mimg)
            if (3 == ndims(mimg))
                mimg = this.reptimes(mimg, size(this, 4));
            end
            this.imagingFormat_.img = this.imagingFormat_.img .* mimg;
        end
        function warnLargeVolumeFraction(this)
            if (1 == this.MAX_VOLUME_FRACTION)
                return
            end
            volFrac = this.count/numel(this.imagingFormat_.img);
            if (volFrac > this.MAX_VOLUME_FRACTION)
                warning('mlfourd:possibleMaskingError', ...
                        'MaskingTool encountered a masked image with a large volume-fraction:  %g', ...
                        volFrac);
            end
        end
    end
    
    
end