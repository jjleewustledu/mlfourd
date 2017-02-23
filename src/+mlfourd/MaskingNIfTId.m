classdef MaskingNIfTId < mlfourd.NIfTIdecoratorProperties
	%% MASKINGNIFTID is a NIfTIdecorator that composes an internal INIfTI object
    %  according to the decorator design pattern.  
    %  Copyright 2017 John Joowon Lee.
        
    properties (Constant)
        MASKEDBY = '_maskedby'
    end
    
    methods (Static)
        function this = load(varargin)
            import mlfourd.*;            
            this = MaskingNIfTId(NIfTId.load(varargin{:}));
        end
        function tf   = isZeroToOne(obj)
            img = double(obj);
            mx  = dipmax(img);
            mn  = dipmin(img);
            tf  = true;
            if ( mn <  0 || 1 <  mx)
                tf = false;
            end 
        end
    end
    
    methods
        function this = MaskingNIfTId(cmp, varargin)
            %% MASKINGNIFTID 
            %  @param cmp is an mlfourd.NIfTIdecorator instance.
            %  @param [options, option-values] directly apply masking operations from the ctor.
            %  Options are evaluated in the order:  
            %  masked, thresh, threshp, threshPZ, uthreshp, uthreshPZ, binarize.
            %  Option-values are INIfTI, 5x numerical and logical, respectively.  
            %  @return mlfourd.MaskingNIfTId instance.
            %  @throw
            
            import mlfourd.*; 
            this = this@mlfourd.NIfTIdecoratorProperties(cmp);
            this = this.append_descrip('decorated by MaskingNIfTId');
            
            p = inputParser;
            addParameter(p, 'masked',    [],   @(x) isa(x, 'mlfourd.INIfTI'));
            addParameter(p, 'thresh',    [],   @isnumeric);
            addParameter(p, 'threshp',   [],   @isnumeric);
            addParameter(p, 'threshPZ',  [],   @isnumeric);
            addParameter(p, 'uthresh',   [],   @isnumeric);
            addParameter(p, 'uthreshp',  [],   @isnumeric);
            addParameter(p, 'uthreshPZ', [],   @isnumeric);
            addParameter(p, 'binarized', false, @islogical);
            parse(p, varargin{:});
            
            if (~isempty(p.Results.masked))
                this = this.masked(p.Results.masked);
            end
            if (~isempty(p.Results.thresh))
                this = this.thresh(p.Results.thresh);
            end
            if (~isempty(p.Results.threshp))
                this = this.threshp(p.Results.threshp);
            end
            if (~isempty(p.Results.threshPZ))
                this = this.threshPZ(p.Results.threshPZ);
            end
            if (~isempty(p.Results.uthresh))
                this = this.uthresh(p.Results.uthresh);
            end
            if (~isempty(p.Results.uthreshp))
                this = this.uthreshp(p.Results.uthreshp);
            end
            if (~isempty(p.Results.uthreshPZ))
                this = this.uthreshPZ(p.Results.uthreshPZ);
            end
            if (p.Results.binarized)
                this = this.binarized;
            end
        end
        
        function this = binarized(this)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            img  = double(this.img ~= 0);
            this = this.makeSimilar( ...
                   'img', img, ...
                   'fileprefix', sprintf('%s_binarized', this.fileprefix), ...
                   'descrip',    'MaskedNIfTI.binarized');            
            if (dipsum(img) == numel(img))
                warning('mlfourd:possibleMaskingError', ...
                    'MaskingNIfTId.binarized mask spans the image space');
            end
            this.assertVolumeFraction;
            this.addLog('MaskingNIfTId.binarized');
        end
        function N    = count(this)
            %% COUNT 
            %  @return N = nonzero elements in the internal INIfTI component
            
            N   = dipsum(this.img ~= 0);
        end
        function this = masked(this, msk)
            %% MASKED
            %  @param msk is an INIfTId mask with values [0 1]; it need not be binary.  It must have a volume size 
            %  equal to the volume of this.
            %  @return this internal image is masked in 3D or 4D with repeated masking as needed.
            %  @warning mflourd:possibleMaskingError
            
            assert(isa(msk, 'mlfourd.INIfTI'));
            msk = this.resizeMaskToFit(msk);
            assert(all(this.size == msk.size));
            if (~this.isZeroToOne(msk))
                 warning('mlfourd:possibleMaskingError', ...
                         'MaskingNIfTId.masked received a mask with values outside of [0 1]');
            end
            this = this.makeSimilar( ...
                   'img', double(this.img) .* double(msk.img), ...
                   'descrip',    sprintf('MaskedNIfTI.masked(%s)', msk.fileprefix), ...
                   'fileprefix', sprintf('%s%s_%s', this.fileprefix, this.MASKEDBY, msk.fileprefix));
            this.assertVolumeFraction;
            this.addLog('MaskingNIfTId.masked(%s)', char(msk));
        end
        function this = maskedByZ(this, rng)
            %% MASKEDBYZ
            %  @param rng = [low-z high-z], typically equivalent to [inferior superior];
            %  masks each frame of 4D images.
            %  @return internal image is cropped by rng.  
            %  @throws MATLAB:assertion:failed for rng out of bounds.
            
            assert(isnumeric(rng) && all(size(rng) == [1 2]));
            assert(0 < rng(1) && rng(1) < rng(2) && rng(2) < this.size(3));
            sz     = this.size;
            zimg   = ones( sz(1:3));
            zslice = zeros(sz(1:2));
            for z = 1:sz(3)
                if (z < rng(1) || rng(2) < z)
                    zimg(:,:,z) = zslice;
                end
            end
            warning('off', 'mlfourd:possibleMaskingError');
            this = this.masked( ...
                mlfourd.NIfTId(zimg, 'fileprefix', sprintf('maskz%i-%i', ceil(rng(1)), floor(rng(2)))));
            warning('on',  'mlfourd:possibleMaskingError');
            this.addLog('MaskingNIfTId.maskedByZ(%s)', mat2str(rng));
        end
        function this = thresh(this, t)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)

            assert(isscalar(t));
            bin  = this.img > t;
            this = this.makeSimilar( ...
                   'img', double(this.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_thr%s', this.fileprefix, this.decimal2str(t)), ...
                   'descrip',    sprintf('MaskedNIfTI.thresh(%g)', t));
            this.addLog('MaskingNIfTId.thresh(%g)', t);
        end
        function this = threshp(this, p)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            
            bin  = this.img > dipprctile(this.img, p);
            this = this.makeSimilar( ...
                   'img', double(this.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_thrp%s', this.fileprefix, this.prct2str(p)), ...
                   'descrip',    sprintf('MaskedNIfTId.threshp(%g)', p));
            this.addLog('MaskingNIfTId.threshp(%g)', p);
        end          
        function this = threshPZ(this, p)
            %% THRESHPZ
            %  @param p:  use percentage p (0-100) of ROBUST RANGE of non-zero voxels and threshold below
            
            bin0 = double(this.img ~= 0);
            img  = this.img .* bin0;
            bin  = img > dipprctile(img, p);
            this = this.makeSimilar( ...
                   'img', double(this.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_thrPZ%s', this.fileprefix, this.prct2str(p)), ...
                   'descrip',    sprintf('MaskedNIfTId.threshPZ(%g)', p));
            this.addLog('MaskingNIfTId.threshPZ(%g)', p);
        end
        function this = uthresh(this, t)
            %% UTHRESH
            %  @param t:  use t to upper-threshold current image (zero anything above the number)
            
            assert(isscalar(t));
            bin  = this.img < t;
            this = this.makeSimilar( ...
                   'img', double(this.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_uthr%s', this.fileprefix, this.decimal2str(t)), ...
                   'descrip',    sprintf('MaskedNIfTI.uthresh(%g)', t));
            this.addLog('MaskingNIfTId.uthresh(%g)', t);
        end
        function this = uthreshp(this, p)
            %% UTHRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to upper-threshold current image (zero anything above the number)
            
            bin  = this.img < dipprctile(this.img, p);
            this = this.makeSimilar( ...
                   'img', double(this.img) .* double(bin), ...
                   'fileprefix', sprintf('%s_uthrp%s', this.fileprefix, this.prct2str(p)), ...
                   'descrip',    sprintf('MaskedNIfTId.uthreshp(%g)', p));
            this.addLog('MaskingNIfTId.uthreshp(%g)', p);
        end          
        function this = uthreshPZ(this, p)
            %% UTHRESHPZ
            %  @param p:  use  percentage p (0-100) of ROBUST RANGE of non-zero voxels and threshold above
            
            bin0 = this.img ~= 0;
            bin  = this.img < dipprctile(this.img, p);
            this = this.makeSimilar( ...
                   'img', double(this.img) .* double(bin0) .* double(bin), ...
                   'fileprefix', sprintf('%s_uthrPZ%s', this.fileprefix, this.prct2str(p)), ...
                   'descrip',    sprintf('MaskedNIfTId.uthreshPZ(%g)', p));
            this.addLog('MaskingNIfTId.uthreshPZ(%g)', p);
        end
        function this = zoomed(this, zoom)
            %% ZOOMED
            %  @param zoom:  > 1 zooms out; < 1 zooms in.
            %  @returns this

            if (all(zoom == 1))
                return
            end
            
            img0 = this.img;
            size0 = size(img0);
            size1 = round(zoom .* size0);
            offset = round((size1 - size0)/2);
            img1 = zeros(size1);
            
            if (all(zoom >= 1))
               
                % zoom > 1, offset > 0, injective or 1-to-1
                for x3 = 1:size0(3)
                    for x2 = 1:size0(2)
                        for x1 = 1:size0(1)
                            img1(x1+offset(1), x2+offset(2), x3+offset(3)) = img0(x1, x2, x3);
                        end
                    end
                end

            elseif (all(zoom <= 1))

                % zoom < 1, offset < 0, surjective or onto
                for x3 = 1:size1(3)
                    for x2 = 1:size1(2)
                        for x1 = 1:size1(1)
                            img1(x1, x2, x3) = img0(x1-offset(1), x2-offset(2), x3-offset(3));
                        end
                    end
                end
            
            else
                error('mlfourdfp:unexpectedConditionalBranch', 'MaskingNIfTId.zoomed');
            end
            
            tag = strrep(mat2str(zoom), ' ', 'x');
            if (strcmp(tag(1), '[')); tag = tag(2:end-1); end
            this.img = img1;
            this.descrip = sprintf('MaskedNIfTI.zoomed(%s)', this.fileprefix);
            this.fileprefix = sprintf('%s_%s', this.fileprefix, tag);
            this.addLog('MaskingNIfTId.zoomed(%s)', char(this));
        end
        
        %% Convenience methods 
        
        function x    = maskedIqr(     this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = iqr(vec, varargin{:});
        end
        function x    = maskedMad(     this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = mad(vec, varargin{:});
        end
        function x    = maskedMax(     this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = max(vec, varargin{:});
        end
        function x    = maskedMean(    this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = mean(vec, varargin{:});
        end
        function x    = maskedMedian(  this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = median(vec, varargin{:});
        end
        function x    = maskedMin(     this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = min(vec, varargin{:});
        end
        function x    = maskedMode(    this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = mode(vec, varargin{:});
        end
        function x    = maskedPrctile( this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = prctile(vec, varargin{:});
        end
        function x    = maskedQuantile(this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = quantile(vec, varargin{:});
        end
        function x    = maskedStd(     this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = std(vec, varargin{:});
        end
        function x    = maskedSum (    this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = sum(vec, varargin{:});
        end
        function x    = maskedTrimmean(this, niidMask, varargin)
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            vec = this.img(niidMask.img == 1);
            x   = trimmean(vec, varargin{:});
        end
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function assertVolumeFraction(this)
            volFrac = this.count/numel(this.img);
            if (volFrac > 0.5)
                warning('mlfourd:possibleMaskingError', ...
                        'MaskingNIfTId encountered a masked image with a large volume-fraction:  %g', ...
                        volFrac);
            end
        end
        function msk = resizeMaskToFit(this, msk)
            thisRank = length(this.size);
            mskRank  = length(msk.size);
            if (thisRank == mskRank)
                return
            end
            if (thisRank < mskRank)
                assert(3 == this.rank);
                msk = msk(:,:,:,1);
                return
            end
            if (thisRank > mskRank)
                assert(3 == mskRank);
                msk = this.repmask(msk, this.size(4));
                return
            end
            error('mlfourd:unsupportedImageSize', 'size(MaskingNIfTId.resizeMaskToFit.msk)->%s', mat2str(size(msk)));
        end
    end
    
    methods (Static, Access = private)
        function s = decimal2str(d)
            s = strrep(num2str(d), '.', '_');
        end
        function s = prct2str(p)
            if (p < 1)
                p = 100*p;
            end
            s = num2str(round(p));
        end
        function msk = repmask(msk, ntimes)
            img = zeros([size(msk) ntimes]);
            for t = 1:ntimes
                img(:,:,:,t) = msk.img;
            end
            msk.img = img;
        end
    end
    
end