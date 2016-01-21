classdef BlurringNIfTId < mlfourd.NIfTIdecoratorProperties
	%% BLURRINGNIFTID is a NIfTIdecorator that composes an internal INIfTI object
    %  according to the decorator design pattern.  Blur must be provided as fwhh in mm.

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$  	 

    properties
        metric = 'fwhh';
    end
    
    properties (Dependent)
        mask
        blur
        blurCount
    end
    
    methods %% SET/GET
        function this = set.mask(this, m)
            if (islogical(m) || isa(m, 'mlfourd.INIfTI'))
                m = double(m); end
            assert(isnumeric(m));
            this.mask_ = m;
        end
        function m    = get.mask(this)
            m = this.mask_;
        end
        function this = set.blur(this, b)
            assert(isnumeric(b));
            if (length(b) > 3)
                this.blur_ = b(1:3);
            else
                this.blur_ = b;
            end
        end
        function b    = get.blur(this)
            b = this.blur_;
        end
        function bc   = get.blurCount(this)
            bc = this.blurCount_;
        end
    end
    
    methods (Static)
        function this  = load(varargin)
            import mlfourd.*;
            this = BlurringNIfTId(NIfTId.load(varargin{:}));
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
                    error('mlfourd:InputParamsErr', help('BlurringNIfTId.sigma2width'));
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
                    error('mlfourd:InputParamsErr', help('BlurringNIfTId.width2sigma'));
            end
            sigma = abs(sqrt((width/2).^2/(2*log(1/fheight))));
        end  
    end
    
	methods 
 		function this = BlurringNIfTId(cmp, varargin)
 			%% BlurringNIfTId 
 			%  Usage:  this = BlurringNIfTId(INIfTI_object[,parameterName, parameterValue]) 
            %  Parameters:  'blur', numeric value, default [], fwhh in mm
            %               'mask', numeric or INIfTI value, default this.ones

            this = this@mlfourd.NIfTIdecoratorProperties(cmp);
            this = this.append_descrip('decorated by BlurringNIfTId');
            
            p = inputParser;
            addParameter(p, 'blur', [], @isnumeric);
            addParameter(p, 'mask', 1,  @(x) isnumeric(x) || isa(x, 'mlfourd.INIfTI'));
            parse(p, varargin{:});
            
            this.mask = p.Results.mask;
            this.blur = p.Results.blur;
            if (~isempty(this.blur))
                this = this.blurred(this.blur, this.mask);
            end
        end   
        function obj  = clone(this)
            obj            = mlfourd.BlurringNIfTId(this.component_.clone);
            obj.metric     = this.metric;
            obj.mask_      = this.mask_;
            obj.blur_      = this.blur_;
            obj.blurCount_ = this.blurCount_;
        end          
        function this = blurred(this, blur, varargin)
            %% BLURRED masks, then blurs internal image with a 3D kernel and returns this with changed state. 
            %  Usage:  bn = BlurringNIfTId([NIfTId_object]);
            %          bn = bn.blurred([blur, mask])
            %          blur:  3-vector, fwhh in mm
            %          mask:  NIfTId, numeric mask applied after blurring
            %          bn:    BlurringNIfTId updated with blurred voxels
            
            import mlfourd.* mlpet.*;
            p = inputParser;
            addRequired(p, 'blur',    @(x) isnumeric(x) && length(x) <= min(this.rank, 3));
            addOptional(p, 'mask', 1, @(x) isnumeric(x) || isa(x, 'mlfourd.INIfTI'));
            parse(p, blur, varargin{:});
            
            this.blur = p.Results.blur;
            this.mask = p.Results.mask;
            if (isempty(this.blur)); return; end                
            if (sum(this.blur) < eps); return; end   
            mmppix_ = this.mmppix;
            if (sum(this.blur  < mmppix_(1:length(this.blur))) > 1)
                warning('mlfourd:discretizationErrors', ...
                        'BlurringNIfTI.blurred:  blur->%s, mmppix->%s', mat2str(this.blur), mat2str(mmppix_));
            end
            if (this.rank < 4)  
                this.img = this.blurredVolume(this.img, mmppix_);
            elseif (4 == this.rank)
                for t = 1:size(this,4)
                    this.img(:,:,:,t) = this.blurredVolume(this.img(:,:,:,t), mmppix_);
                end
            else
                error('mlfourd:paramOutOfBounds', 'BlurringNIfTI.blurred.rank->%i', this.rank);
            end            
            this.blurCount_ = this.blurCount_ + 1;
            this.fileprefix = this.blurredFileprefix;
            this = this.append_descrip(['blurred to ' mat2str(this.blur)]);
        end
        function fp   = blurredFileprefix(this)
            twoDigits = cell(1,3);
            for d = 1:length(this.blur)
                [x,x2] = strtok(num2str(this.blur(d)), '.');
                xfused = [x x2(2:end)]; % remove decimal point
                twoDigits{d} = xfused(1:min(2,end)); % retain only two digits
            end
            fp = [this.fileprefix '_' twoDigits{1} twoDigits{2} twoDigits{3} this.metric];
        end
        function tf = isequaln(this, bnii)
            tf = isa(bnii, class(this));
            if (tf)
                tf = isa(bnii, 'mlfourd.BlurringNIfTId');
                if (tf)
                    tf = isequaln(this.blurCount_, bnii.blurCount);
                    if (tf)
                        tf = isequaln(this.blur_, bnii.blur);
                        if (tf)
                            tf = isequaln(this.mask_, bnii.mask);
                            if (tf)
                                tf = isequaln@mlfourd.NIfTIdecorator2(this, bnii);
                            end
                        end
                    end
                end
            end
            
            if (~isequaln(this.mask_, bnii.mask))
                tf  = false;
                warning('mlfourd:notIsequaln', 'BlurringNIfTId.isequaln:  found mismatch at this.mask.');
                return
            end
            if (~isequaln(this.blur_, bnii.blur))
                tf  = false;
                warning('mlfourd:notIsequaln', 'BlurringNIfTId.isequaln:  found mismatch at this.blur.');
                return
            end
            if (~isequaln(this.blurCount_, bnii.blurCount))
                tf  = false;
                warning('mlfourd:notIsequaln', 'BlurringNIfTId.isequaln:  found mismatch at this.blurCount.');
                return
            end
        end
    end 
    
    %% PRIVATE    
    
    properties (Access = private)
        mask_
        blur_
        blurCount_ = 0;
    end
    
    methods (Static, Access = private)
        function img   = gaussFullwidth(img, width, metric, metppix, height)
            %% GAUSSFULLWIDTH applies multi-dimensional, anisotropic, Gaussian filtering to 
            %                 numeric objects.
            %  Usage: gimg = BlurringNIfTId.gaussFullwidth(img, width, metric, metppix, height)
            %         img:       numeric object
            %         width:     row vector of full widths
            %         metric:    units of full width blur
            %         metppix:   metric units per pixel; 1 and [1 1 1] are equivalent
            %         height:    height at which width is measured (fraction 0..1)
            %         gimg:      Gaussian-blurred image returned
            %  Examples:
            %         gimg = this.gaussFullwidth(img, [fwhh_x fwhh_y])
            %         gimg = this.gaussFullwidth(img, fwhh_vec3, 'mm', mlpet.PETBuilder.petPointSpread, 0.1)                                                                   %
            %  See also:  BlurringNIfTId.gaussSigma
            
            import mlfourd.*;
            switch (nargin)
                case 2
                    metric  = 'voxel';
                    metppix = 1;
                    height  = 0.5;
                case 4
                    height  = 0.5;
                case 5
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['BlurringNIfTId.gaussFullwidth.nargin->' num2str(nargin)]);
            end
            img = BlurringNIfTId.gaussSigma(img, BlurringNIfTId.width2sigma(width, height), metric, metppix);
        end 
        function img   = gaussSigma(img, sigma, metric, metppix)
            %% GAUSSSIGMA applies multi-dimensional, anisotropic, Gaussian filtering to 
            %             numeric objects.
            %  Usage: gimg = BlurringNIfTId.gaussSigma(img, width, metric, metppix)
            %         img:       numeric object
            %         sigma:     row vector of std. deviations
            %         metric:    units of sigma
            %         metppix:   metric units per pixel; 1 and [1 1 1] are equivalent
            %         gimg:      blurred double image returned
            %  Examples:
            %         gimg = this.gaussSigma(img, [fwhh_x fwhh_y])
            %         gimg = this.gaussSigma(img, fwhh_vec3, 'mm', mlpet.PETBuilder.petPointSpread)
            %  See also:  gaussFullwidth
            
            import mlfourd.*;
            KERNEL_MULTIPLE = 3;
            switch (nargin)
                case 2
                    metric  = 'voxel';
                    metppix = 1;
                case 4
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['BlurringNIfTId.gaussSigma.nargin->' num2str(nargin)]);
            end
            switch (lower(metric)) 
                case {'pixel', 'pixels', 'voxel', 'voxels'}
                    metppix = 1;
                case  'mm'
                case  'cm'
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['BlurringNIfTId.gaussFullwidth.metric->' metric ' was unrecognizable;\n' ...
                          'try pixel(s), voxel(s), mm, cm']);
            end
            img     = double(img);
            imgRank = length(size(img));
            if (length(sigma) < imgRank)
                sigma = BlurringNIfTId.embedVecInSitu(sigma, zeros(size(size(img))));
            end
            if (length(metppix) < length(sigma))
                metppix = BlurringNIfTId.stretchVec(metppix, length(sigma));
            elseif (length(metppix) > length(sigma))
                metppix = metppix(1:length(sigma));
            end
            sigma = sigma ./ metppix; % Convert metric units to pixels
            if (norm(sigma) < eps); return; end % Trivial case
            
            % Assemble filter kernel & call imfilter              
            krnlLens = KERNEL_MULTIPLE * ceil(sigma);
            for q = 1:length(krnlLens) %#ok<FORPF>
                if (krnlLens(q) < 1); krnlLens(q) = 1; end
            end             
            h0 = zeros(prod(krnlLens), imgRank); % filter kernel with peak centered in the kernel's span
            switch(imgRank)
                case 1
                    h0 = h1d(krnlLens, h0);
                case 2
                    h0 = h2d(krnlLens, h0);
                case 3
                    h0 = h3d(krnlLens, h0);
                case 4
                    h0 = h4d(krnlLens, h0);
                otherwise
                    error('mlfourd:ParameterOutOfBounds', ...
                         ['imgRank->' num2str(imgRank) ', but only imgRank <= 4 is supported']);
            end
            h1  = reshape(BlurringNIfTId.gaussian(h0, zeros(1,imgRank), sigma), krnlLens);
            img = imfilter(img, h1);
            
            %% Private utility subfunctions
            
            function h0 = h1d(krnlLens, h0)
                for i = 1:krnlLens(1) %#ok<FORFLG>
                    h0(i,:) = i-krnlLens(1)/2; 
                end
            end
            function h0 = h2d(krnlLens, h0)
                p     = 0;
                for j = 1:krnlLens(2) %#ok<FORFLG>
                    for i = 1:krnlLens(1) 
                        p = p + 1;
                        h0(p,:) = [i-krnlLens(1)/2    j-krnlLens(2)/2]; 
                    end
                end
            end 
            function h0 = h3d(krnlLens, h0)
                p     = 0;
                for k = 1:krnlLens(3) %#ok<FORFLG>
                    for j = 1:krnlLens(2) 
                        for i = 1:krnlLens(1)
                            p = p + 1;
                            h0(p,:) = [i-krnlLens(1)/2    j-krnlLens(2)/2 k-krnlLens(3)/2]; 
                        end
                    end
                end
            end 
            function h0 = h4d(krnlLens, h0)
                p     = 0;
                for m = 1:krnlLens(4) %#ok<FORFLG>
                    for k = 1:krnlLens(3) 
                        for j = 1:krnlLens(2)
                            for i = 1:krnlLens(1)
                                p = p + 1;
                                h0(p,:) = [i-krnlLens(1)/2    j-krnlLens(2)/2 k-krnlLens(3)/2 m-krnlLens(4)/2]; 
                            end
                        end
                    end
                end
            end 
        end 
        function sz    = embedVecInSitu(sz, fixedsz)
            %% EMBEDVECINSITU resizes sz to match rank of fixedsz
            %  e.g.  >> sz = BlurringNIfTId.embedVecInSitu([2 2 30], [18 18 31 100])
            %        sz = 
            %            2 2 30 100
            %        >> sz = NIfTId.embedVecInSitu([18 18 31 100], [2 2 30])
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
        function vout  = stretchVec(vin, newlen, repeat)
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
                         ['BlurringNIfTId.stretchVec.nargin->' num2str(nargin)]);
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
        function y     = gaussian(X, mu, sigma)
            %% GAUSSIAN
            %
            %  Usage:   y = gaussian(X, mu, sigma)
            %
            %           X     -> multiplet coord as row,
            %                    e.g., [3.1 4 6.2], (0:0.01:1)'
            %                    or matrix coord; each point has a multiplet-coord row
            %           mu    -> multiplet means as row,
            %                    e.g., [mean_x mean_y mean_z]
            %           sigma -> multiplet standard deviations as row
            %                    e.g., [std_x std_y std_z]
            %           y     -> col of same height as X
            
            USE_NORMPDF = 1; % optimized
            
            if [1 2]   ~= size(size(X)), error(help('gaussian')); end %#ok<*BDSCA>
            npts = size(X,1);
            dim  = size(X,2);
            if [1 dim] ~= size(mu),      error(help('gaussian')); end
            if [1 dim] ~= size(sigma),   error(help('gaussian')); end
            
            if (USE_NORMPDF)
                Ones = ones(npts, 1);
                y    = Ones;
                for d = 1:dim
                    if (sigma(d) > eps)
                        y = y .* normpdf(X(:,d), mu(d), sigma(d)); end
                end
            else
                % pedagogical & cross-checking code
                % row * row' -> inner product
                % col * row  -> outer product
                Arg2 = ones(npts,1); %#ok<*UNRCH>
                for i = 1:npts
                    Arg2(i) = ((X(i,:) - mu)./(sqrt(2)*sigma)) * ((X(i,:) - mu)./(sqrt(2)*sigma))';
                end
                prodSigmas = 1;
                for p = 1:dim
                    if (sigma(p) > eps)
                        prodSigmas = prodSigmas * sigma(p); end
                end
                y = exp(-Arg2)/(sqrt(2*pi)^dim*prodSigmas);
            end
            
            if [npts 1] ~= size(y), error('mlfourd:Oops', ['oops...  size(y) was ' num2str(size(y))]); end
            
        end
    end
    
    methods (Access = private)
        function img = blurredVolume(this, img, mmppix)
            assert(isnumeric(img));
			img = double(this.mask) .* ...
                  this.gaussFullwidth(squeeze(double(img)), this.blur, 'mm', mmppix);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

