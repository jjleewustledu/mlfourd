classdef BlurringTool < handle & mlfourd.ImagingFormatTool
	%% BLURRINGTOOL is a concrete ImagingTool.  The blur must be provided as fwhh in mm.

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%% $Id$  	 
    
    properties
        metric = 'fwhh';
    end
    
    properties (Dependent)
        blur
        blurCount
        kernelMultiple
        mask
    end
    
    methods (Static) 
        function img   = gaussFullwidth(img, varargin)
            %% GAUSSFULLWIDTH
            %  @param img (req.):      numeric object 
            %  @param width (req.):    row vector of full widths
            %  @param named metric:    units of full width blur
            %  @param named metppix:   metric units per pixel; 1 and [1 1 1] are equivalent
            %  @param named krnlMult:  integer multiplier for filter size such that
            %                          filter size := floor(krnlMult)*ceil(2*sigma) + 1
            %  @param named height:    height at which width is measured (fraction 0..1)
            %  See also mlfourd.BlurringTool.gaussSigma
            
            import mlfourd.*;
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired( ip, 'img', @isnumeric);
            addRequired( ip, 'width', @isnumeric);
            addParameter(ip, 'height', 0.5, @isnumeric);
            addParameter(ip, 'metric', 'mm', @ischar);
            addParameter(ip, 'metppix', ones(size(img)), @isnumeric);
            addParameter(ip, 'krnlMult', 2, @isnumeric);
            parse(ip, img, varargin{:});
            
            img = BlurringTool.gaussSigma( ...
                ip.Results.img, ...
                BlurringTool.width2sigma(ip.Results.width, ip.Results.height), ...
                'metric',   ip.Results.metric, ...
                'metppix',  ip.Results.metppix, ...
                'krnlMult', ip.Results.krnlMult);
        end 
        function img   = gaussSigma(varargin)
            %% GAUSSSIGMA 
            %  @param img (req.):      numeric object
            %  @param sigma (req.):    row vector of std. deviations
            %  @param named metric:    units of sigma \in {'voxel' 'pixel' 'mm' 'cm'}
            %  @param named metppix:   metric units per pixel; 1 and [1 1 1] are equivalent
            %  @param named krnlMult:  integer multiplier for filter size such that
            %                          filter size := 2*floor(krnlMult)*ceil(sigma) + 1
            %  See also mlfourd.BlurringTool.gaussFullwidth, imgaussfilt, imgaussfilt3
            
            import mlfourd.*; 
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired( ip, 'img', @isnumeric);
            addRequired( ip, 'sigma', @isnumeric);
            addParameter(ip, 'metric', 'voxel', @ischar);
            addParameter(ip, 'metppix', 1, @isnumeric);
            addParameter(ip, 'krnlMult', 2, @isnumeric);
            parse(ip, varargin{:});            
            img   = ip.Results.img;
            sigma = ip.Results.sigma;
            
            if (norm(sigma) < eps); return; end
            if (lstrfind(ip.Results.metric, {'voxel' 'pixel'}))
                metppix = 1;
            else
                metppix = ip.Results.metppix;
            end
            metppix = BlurringTool.checkedMetppix(metppix, sigma);
            sigma   = sigma ./ metppix; % convert metric units to pixels            
            img     = double(squeeze(img));
            ndims_  = ndims(img);
            
            % assemble filter kernel & call imfilter      
            % see also imgaussfilt, imgaussfilt3; this is their default
            krnlLens = 2*floor(ip.Results.krnlMult)*ceil(sigma)+1;
            krnlLens(krnlLens < 1) = 1;
            switch(ndims_)
                case 2
                    img = imgaussfilt( img, sigma, 'FilterSize', krnlLens);
                case 3
                    img = imgaussfilt3(img, sigma, 'FilterSize', krnlLens);
                otherwise
                    error('mlfourd:parameterOutOfBounds', ...
                         ['BlurringTool.gaussSigma.ndims_->' num2str(ndims_) ', but only ndims_ \in [2 3] are supported']);
            end
        end       
        function width = sigma2width(sigma, fheight)
            %% SIGMA2WIDTH returns the width at fheight corresponding to sigma, metppix & metric units.
            %  Usage: width = sigma2width(sigma[, fheight])
            %         width:   vector for full-width at half-height, in metric units
            %         fheight: fractional height, 0.5 for fwhh is default, 0.1 for fwth
            %         sigma:   vector in units of metric
            %
            %  See also:   width2sigma
            
            switch (nargin)
                case 1
                    fheight = 0.5;
                case 2 
                otherwise
                    error('mlfourd:InputParamsErr', help('BlurringTool.sigma2width'));
            end
            width = 2*sqrt(2*log(1/fheight)*sigma.^2);
        end 
        function sigma = width2sigma(width, fheight)
            %% WIDTH2SIGMA returns the Gaussian sigma corresponding to width at fheight, metppix & metric units.
            %  Usage: sigma = width2sigma(width[, fheight])
            %         width:   vector for full-width at fheight, in metric units
            %         fheight: fractional height, 0.5 for fwhh is default, 0.1 for fwth
            %         sigma:   vector in units of metric
            %
            %  Rationale:              fheight*a1 = a1*exp(-((x-b1)/c1)^2);
            %                        log(fheight) = -((x - b1)/c1)^2
            %                                c1^2 = 2*sigma^2;
            %             2*sigma^2*log(fheight)  = -(x - b1)^2
            %      sqrt(2*sigma^2*log(1/fheight)) =   x - b1
            %                                     =   width/2
            %  See also:  sigma2width
            
            switch (nargin)
                case 1
                    fheight = 0.5;
                case 2
                otherwise
                    error('mlfourd:InputParamsErr', help('BlurringTool.width2sigma'));
            end
            sigma = abs(sqrt((width/2).^2/(2*log(1/fheight))));
        end  
    end    
    
    methods 
        
        %% GET
        
        function b  = get.blur(this)
            b = this.blur_;
        end
        function bc = get.blurCount(this)
            bc = this.blurCount_;
        end
        function m  = get.kernelMultiple(this)
            m = this.kernelMultiple_;
        end
        function m  = get.mask(this)
            m = this.mask_;
        end
        
        %%
        
        function blurred(this, varargin)
            %% BLURRED
            %  @param required blur is numeric, fwhh in mm.
            %  @param optional mask is numeric, applied prior to blurring.
            %  @param named krnlMult is integer.
            %  @return this modified with blurred voxels and blurCount.
                  
            import mlfourd.* mlpet.*;            
            ip = inputParser;
            addRequired( ip, 'blur', @isnumeric);
            addOptional( ip, 'mask', 1);
            addParameter(ip, 'krnlMult', 2, @isnumeric);
            parse(ip, varargin{:});            
            this.blur_           = this.checkedBlur(ip.Results.blur, this.ndimsEuclid); % double \in \mathbb{R}^3
            this.mask_           = this.checkedMask(ip.Results.mask, this.sizeEuclid); % double \in \mathbb{R}^3
            this.kernelMultiple_ = ip.Results.krnlMult;
            
            if (isempty(this.blur_) || sum(this.blur_) < eps)
                return
            end
            if (4 == this.ndims)
                for t = 1:size(this,4)
                    this.imagingFormat_.img(:,:,:,t) = ...
                        this.blurredImg(this.imagingFormat_.img(:,:,:,t));
                end
            else
                this.imagingFormat_.img = this.blurredImg(this.imagingFormat_.img);
            end            
            this.fileprefix = this.blurredFileprefix;
            this.addLog(sprintf('BlurringTool:  blur->%s', mat2str(this.blur)));
            this.blurCount_ = this.blurCount_ + 1;
        end
        function imbothat(this, varargin)
            this.morphologic(@imbothat, varargin{:})
        end
        function bwskel(this, varargin)
            this.morphologic(@bwskel, varargin{:})
        end
        function bwperim(this, varargin)
            this.morphologic(@bwperim, varargin{:})
        end
        function imclose(this, varargin)
            this.morphologic(@imclose, varargin{:})
        end
        function imdilate(this, varargin)
            this.morphologic(@imdilate, varargin{:})
        end
        function imerode(this, varargin)
            this.morphologic(@imerode, varargin{:})
        end
        function imopen(this, varargin)
            this.morphologic(@imopen, varargin{:})
        end
        function imtophat(this, varargin)
            this.morphologic(@imtophat, varargin{:})
        end
        function r = ndimsEuclid(this)
            r = min(this.ndims, 3);
        end
        function s = sizeEuclid(this)
            s = this.imagingFormat_.size;
            s = s(1:this.ndimsEuclid);
        end
        
 		function this = BlurringTool(h, varargin)
            this = this@mlfourd.ImagingFormatTool(h, varargin{:});
        end   
    end 
    
    %% PROTECTED 
    
    properties (Access = protected)
        blur_
        blurCount_ = 0;
        height_ = 0.5;
        kernelMultiple_
        mask_
    end
    
    methods (Static, Access = protected)
        function b       = checkedBlur(b, ndims_)
            assert(isnumeric(b));
            if (length(b) < ndims_)
                b = mean(b)*ones(1, ndims_);
            end   
            if (length(b) > 3)
                b = b(1:3);
            end
        end
        function m       = checkedMask(m, sz)
            if (~isa(m, 'double'))
                m = double(m); 
            end
            if (isscalar(m))
                return
            end
            assert(all(size(m) == sz));
        end
        function metppix = checkedMetppix(metppix, sigma)
            if (length(metppix) < length(sigma))
                metppix = mlfourd.BlurringTool.stretchVec(metppix, length(sigma));
            end
            if (length(metppix) > length(sigma))
                metppix = metppix(1:length(sigma));
            end
        end
        function sz      = embedVecInSitu(sz, fixedsz)
            %% EMBEDVECINSITU resizes sz to match ndims of fixedsz
            %  e.g.  >> sz = BlurringTool.embedVecInSitu([2 2 30], [18 18 31 100])
            %        sz = 
            %            2 2 30 100
            %        >> sz = BlurringTool.embedVecInSitu([18 18 31 100], [2 2 30])
            %        sz = 
            %            18 18 31
            
            if (length(sz) > length(fixedsz))
                sz = sz(1:length(fixedsz));
            else
                tmp = fixedsz;
                tmp(1:length(sz)) = sz;
                sz  = tmp;
            end
        end
        function vout    = stretchVec(vin, newlen, repeat)
            %% STRETCHVEC stretches a vector to a new size, with repeated final element as necessary
            %  Usage: [vout] = stretchVec(vin, newlen, repeat)
            %         vin:     col or row vector
            %         vout:    col or row vector with new length newlen
            %         repeat:  value to repeat; default is 1, creating singleton dimensions
            %  Examples:
            %         [vout8] = stretchVec(vin3, 8)
            %  See also:   embedVecInSitu
            
            switch (nargin)
                case 3
                case 2
                    repeat = 1;
                otherwise
                    error('mlfourd:InputParamsErr:InputParamsErr', ...
                         ['BlurringTool.stretchVec.nargin->' num2str(nargin)]);
            end
            assert(isnumeric(vin));
            assert(isnumeric(newlen));
            assert(isnumeric(repeat));
            vout = zeros(1, newlen);
            for d = 1:newlen %#ok<FORPF>
                if (d <= size(vin,2))
                    vout(d) = vin(d);
                else
                    vout(d) = vin(size(vin,2));
                end
            end
        end
    end
    
    methods (Access = protected)
        function fp  = blurredFileprefix(this)
            if this.blur_ < 1
                fp = sprintf('%s_b0%g', this.fileprefix, round(10*max(this.blur_)));                
                return
            end
            fp = sprintf('%s_b%g', this.fileprefix, round(10*max(this.blur_)));
        end
        function img = blurredImg(this, img)
            assert(isnumeric(img));
            
			img = this.gaussFullwidth( ...
                img .* this.mask_, ...
                this.blur_, ...
                'height', this.height_, ...
                'metppix', this.imagingFormat_.mmppix, ...
                'krnlMult', this.kernelMultiple_);
        end
        function morphologic(this, fhandle, varargin)
            if (4 == this.ndims)
                for t = 1:size(this,4)
                    this.imagingFormat_.img(:,:,:,t) = ...
                        fhandle(this.imagingFormat_.img(:,:,:,t));
                end
            else
                this.imagingFormat_.img = fhandle(this.imagingFormat_.img, varargin{:});
            end            
            this.fileprefix = sprintf('%s_%s', this.fileprefix, func2str(fhandle));
            this.addLog(sprintf('BlurringTool:  %s', func2str(fhandle)));
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

