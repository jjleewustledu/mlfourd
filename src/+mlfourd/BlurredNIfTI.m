classdef BlurredNIfTI < mlfourd.NIfTIDecorator
	%% BLURREDNIFTI   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$  	 

    properties (Constant)
        KERNEL_MULTIPLE = 2
    end
    
    properties
        blur      = []
        blurCount = 0
    end
    
    methods (Static)
        function bn    = factory(varargin)
            %% FACTORY directs all arguments to NIfTI
            %  blurred_nifti = BlurredNIfTI.factory(args_for_NIfTI);
            
            bn = mlfourd.BlurredNIfTI( ...
                  mlfourd.NIfTI(varargin{:}));
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
                    error('mlfourd:InputParamsErr', ['BlurredNIfTI.sigma2width.nargin->' num2str(nargin)]);
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
                    error('mlfourd:InputParamsErr', ['BlurredNIfTI.width2sigma.nargin->' num2str(nargin)]);
            end
            sigma = abs(sqrt((width/2).^2/(2*log(1/fheight))));
        end 
    end
    
	methods         
 		function this = BlurredNIfTI(varargin) 
 			%% BLURREDNIFTI 
 			%  Usage:  this = BlurredNIfTI([aNIfTI_to_blur]) 

            this = this@mlfourd.NIfTIDecorator(varargin{:});
        end  
        function obj  = clone(this)
            obj = mlfourd.BlurredNIfTI(this);
        end               
        function this = blurred(this, blr, msk)
            %% BLURRED blurs voxels with 3D kernels and returns the BlurredNIfTI with changed state. 
            %  Usage:  bn = BlurredNIfTI([aNIfTI]);
            %          bn = bn.blurred([blur, mask])
            %          blur:  3-vector
            %          mask:  NIfTI, numeric or logical mask applied after blurring
            %          bn:    BlurredNIfTI updated with blurred voxels
            
            import mlfourd.*;
            switch (nargin)
                case 1
                    blr = mlpet.PETBuilder.petPointSpread;
                    msk = 1;
                case 2
                    msk = 1;   
                case 3
                    assert(all(size(blr) == size(this.mmppix))); 
                    msk = NIfTI.ensureDble(NIfTI_mask(msk));        
                otherwise
                    error('mlfourd:NotImplemented', ...
                         ['BlurredNIfTI.blurred received ' num2str(nargin) ' args']);
            end
            this.blur       = blr;
            if (sum(blr) < eps); return; end    
			this.img        = double(msk) .* this.gaussFullwidth(double(this.img), blr, 'mm', this.mmppix);
            this.blurCount  = this.blurCount + 1;
            this.fileprefix = this.blurredFileprefix;
            this.append_descrip(['blurred to ' num2str(blr)]);
        end
        function nii  = blurredNIfTI(this, varargin)
            this = this.blurred(varargin{:});
            nii  = this.component;
        end
        function fp   = blurredFileprefix(this)
            twoDigits = cell(1,3);
            for d = 1:length(twoDigits)
                [x,x2] = strtok(num2str(this.blur(d)), '.');
                xfused = [x x2(2:end)];
                twoDigits{d} = xfused(1:2);
            end
            fp = [this.fileprefix '_' twoDigits{1} twoDigits{2} twoDigits{3} 'fwhh'];
        end
    end 
    
    %% PRIVATE    
    
    methods (Static, Access = 'private')
        function img   = gaussFullwidth(img, width, metric, metppix, height)
            %% GAUSSFULLWIDTH applies multi-dimensional, anisotropic, Gaussian filtering to 
            %                 numeric objects.
            %  Usage: gimg = BlurredNIfTI.gaussFullwidth(img, width, metric, metppix, height)
            %         img:       numeric object
            %         width:     row vector of full widths
            %         metric:    units of full width blur
            %         metppix:   metric units per pixel; 1 and [1 1 1] are equivalent
            %         height:    height at which width is measured (fraction 0..1)
            %         gimg:      Gaussian-blurred image returned
            %  Examples:
            %         gimg = this.gaussFullwidth(img, [fwhh_x fwhh_y])
            %         gimg = this.gaussFullwidth(img, fwhh_vec3, 'mm', mlpet.PETBuilder.petPointSpread, 0.1)                                                                   %
            %  See also:  BlurredNIfTI.gaussSigma
            
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
                         ['BlurredNIfTI.gaussFullwidth.nargin->' num2str(nargin)]);
            end
            img = BlurredNIfTI.gaussSigma(img, BlurredNIfTI.width2sigma(width, height), metric, metppix);
        end 
        function img   = gaussSigma(img, sigma, metric, metppix)
            %% GAUSSSIGMA applies multi-dimensional, anisotropic, Gaussian filtering to 
            %             numeric objects.
            %  Usage: gimg = BlurredNIfTI.gaussSigma(img, width, metric, metppix)
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
            switch (nargin)
                case 2
                    metric  = 'voxel';
                    metppix = 1;
                case 4
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['BlurredNIfTI.gaussSigma.nargin->' num2str(nargin)]);
            end
            switch (lower(metric)) 
                case {'pixel', 'pixels', 'voxel', 'voxels'}
                    metppix = 1;
                case  'mm'
                case  'cm'
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['BlurredNIfTI.gaussFullwidth.metric->' metric ' was unrecognizable;\n' ...
                          'try pixel(s), voxel(s), mm, cm']);
            end
            img     = double(img);
            imgRank = length(size(img));
            if (length(sigma) < imgRank)
                sigma = BlurredNIfTI.embedVecInSitu(sigma, zeros(size(size(img))));
            end
            if (length(metppix) < length(sigma))
                metppix = BlurredNIfTI.stretchVec(metppix, length(sigma));
            else
                assert(length(metppix) == length(sigma));
            end
            sigma = sigma ./ metppix; % Convert metric units to pixels
            if (norm(sigma) < eps); return; end % Trivial case
            
            % Assemble filter kernel & call imfilter              
            krnlLens = mlfourd.BlurredNIfTI.KERNEL_MULTIPLE * ceil(sigma);
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
            h1  = reshape(BlurredNIfTI.gaussian(h0, zeros(1,imgRank), sigma), krnlLens);
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
            %  e.g.  >> sz = BlurredNIfTI.embedVecInSitu([2 2 30], [18 18 31 100])
            %        sz = 
            %            2 2 30 100
            %        >> sz = NIfTI.embedVecInSitu([18 18 31 100], [2 2 30])
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
                         ['BlurredNIfTI.stretchVec.nargin->' num2str(nargin)]);
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
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

