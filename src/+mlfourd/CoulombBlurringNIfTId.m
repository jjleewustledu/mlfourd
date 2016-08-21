classdef CoulombBlurringNIfTId < mlfourd.NIfTIdecoratorProperties
	%% COULOMBBLURRINGNIFTID  

	%  $Revision$
 	%  was created 08-Aug-2016 19:20:42
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.341360 (R2016a) for MACI64.
 	

    properties (Constant)        
        KRNL_MULTIPLE = 2;
    end
    
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
            this = CoulombBlurringNIfTId(NIfTId.load(varargin{:}));
        end        
    end
    
	methods
 		function this = CoulombBlurringNIfTId(cmp, varargin)
 			%% COULOMBBLURRINGNIFTID
 			%  Usage:  this = CoulombBlurringNIfTId(INIfTI_object[,parameterName, parameterValue]) 
            %  Parameters:  'blur', numeric value, default [], fwhh in mm
            %               'mask', numeric or INIfTI value, default this.ones

            this = this@mlfourd.NIfTIdecoratorProperties(cmp);
            this = this.append_descrip('decorated by CoulombBlurringNIfTId');
            
            ip = inputParser;
            addParameter(ip, 'blur', [], @isnumeric);
            addParameter(ip, 'mask', 1,  @(x) isnumeric(x) || isa(x, 'mlfourd.INIfTI'));
            parse(ip, varargin{:});
            
            this.mask = ip.Results.mask;
            this.blur = ip.Results.blur;
            this.img  = double(this.img);
            if (~isempty(this.blur))
                this = this.blurred(this.blur, this.mask);
            end
 		end
        function obj  = clone(this)
            obj            = mlfourd.CoulombBlurringNIfTId(this.component.clone);
            obj.metric     = this.metric;
            obj.mask_      = this.mask_;
            obj.blur_      = this.blur_;
            obj.blurCount_ = this.blurCount_;
        end          
        function this = blurred(this, varargin)
            %% BLURRED masks, then blurs internal image with a 3D kernel and returns this with changed state. 
            %  Usage:  bn = CoulombBlurringNIfTId([NIfTId_object]);
            %          bn = bn.blurred([blur, mask])
            %          blur:  3-vector, fwhh in mm
            %          mask:  NIfTId, numeric mask applied after blurring
            %          bn:    CoulombBlurringNIfTId updated with blurred voxels
            
            import mlfourd.* mlpet.*;
            ip = inputParser;
            addOptional(ip, 'blur', mlpet.PETRegistry.instance.petPointSpread, ...
                                       @(x) isnumeric(x) && length(x) <= min(this.rank, 3));
            addOptional(ip, 'mask', 1, @(x) isnumeric(x) || isa(x, 'mlfourd.INIfTI'));
            parse(ip, varargin{:});
            
            this.blur = ip.Results.blur;
            this.mask = ip.Results.mask;
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
            this = this.append_descrip('blurred to %s', mat2str(this.blur));
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
        function tf   = isequaln(this, bnii)
            tf = isa(bnii, class(this));
            if (tf)
                tf = isa(bnii, 'mlfourd.CoulombBlurringNIfTId');
                if (tf)
                    tf = isequaln(this.blurCount_, bnii.blurCount);
                    if (tf)
                        tf = isequaln(this.blur_, bnii.blur);
                        if (tf)
                            tf = isequaln(this.mask_, bnii.mask);
                            if (tf)
                                tf = isequaln@mlfourd.NIfTIdecoratorProperties(this, bnii);
                            end
                        end
                    end
                end
            end
            
            if (~isequaln(this.mask_, bnii.mask))
                tf  = false;
                warning('mlfourd:notIsequaln', 'CoulombBlurringNIfTId.isequaln:  found mismatch at this.mask.');
                return
            end
            if (~isequaln(this.blur_, bnii.blur))
                tf  = false;
                warning('mlfourd:notIsequaln', 'CoulombBlurringNIfTId.isequaln:  found mismatch at this.blur.');
                return
            end
            if (~isequaln(this.blurCount_, bnii.blurCount))
                tf  = false;
                warning('mlfourd:notIsequaln', 'CoulombBlurringNIfTId.isequaln:  found mismatch at this.blurCount.');
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
        function img   = chargesToScalarPotentials(img, width, varargin)
            %% CHARGESTOSCALARPOTENTIALS
            %  @param img:         charge density image
            %  @param width:       row vector of full widths for blurring
            %  @param metric:      units of full widths
            %  @param metricppix:  metric units per pixel; 1 and [1 1 1] are equivalent
            %  @returns img:       scalar-potential image returned
            %  Usage: 
            %      img = CoulombBlurringNIfTId.chargesToScalarPotentials(img, width, [, param_name, param_value]);
            %  Examples:
            %      img = this.chargesToScalarPotentials(img, [fwhh_x fwhh_y])
            %      img = this.chargesToScalarPotentials(img,  fwhh_vec3, ...
            %                                                'metric', 'mm', 'metricppix', mlpet.PETBuilder.petPointSpread)
            
            ip = inputParser;
            addRequired( ip, 'img', @isnumeric);
            addRequired( ip, 'width', @isnumeric);
            addParameter(ip, 'metric', 'voxel', @ischar);
            addParameter(ip, 'metricppix', 1, @isnumeric);
            parse(ip, img, width, varargin{:});
            
            switch (lower(ip.Results.metric)) 
                case {'pixel' 'pixels' 'voxel' 'voxels'}
                    metricppix = 1;
                case {'mm' 'cm'}
                    metricppix = ip.Results.metricppix;
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['CoulombBlurringNIfTId.chargesToScalarPotentials.metric->%s was unrecognizable;\n' ...
                          'try pixel(s), voxel(s), mm, cm'], ip.Results.metric);
            end
            
            import mlfourd.*;
            img     = double(img);
            imgRank = length(size(img));
            if (length(width) < imgRank)
                width = CoulombBlurringNIfTId.embedVecInSitu(width, zeros(size(size(img))));
            end
            if (length(metricppix) < length(width))
                metricppix = CoulombBlurringNIfTId.stretchVec(metricppix, length(width));
            elseif (length(metricppix) > length(width))
                metricppix = metricppix(1:length(width));
            end
            width = width ./ metricppix; % Convert metric units to pixels
            if (norm(width) < eps); return; end % Trivial case
            
            % Assemble filter kernel & call imfilter              
            krnlLens = CoulombBlurringNIfTId.KRNL_MULTIPLE * ceil(width);
            for q = 1:length(krnlLens) %#ok<FORPF>
                if (krnlLens(q) < 1); krnlLens(q) = 1; end
            end             
            h0  = zeros(prod(krnlLens), imgRank); % filter kernel with peak centered in the kernel's span
            h0  = CoulombBlurringNIfTId.h3d(krnlLens, h0);
            h1  = reshape(CoulombBlurringNIfTId.inverseDistance(h0, zeros(1,imgRank), width), krnlLens);
            img = imfilter(img, h1);            
        end
        function h0 = h3d(krnlLens, h0)
            p     = 0;
            for k = 1:krnlLens(3) %#ok<FORFLG>
                for j = 1:krnlLens(2) 
                    for i = 1:krnlLens(1)
                        p = p + 1;
                        h0(p,:) = [i-krnlLens(1)/2 j-krnlLens(2)/2 k-krnlLens(3)/2]; 
                    end
                end
            end
        end 
        function sz    = embedVecInSitu(sz, fixedsz)
            %% EMBEDVECINSITU resizes sz to match rank of fixedsz
            %  e.g.  >> sz = CoulombBlurringNIfTId.embedVecInSitu([2 2 30], [18 18 31 100])
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
                         ['CoulombBlurringNIfTId.stretchVec.nargin->' num2str(nargin)]);
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
        function y     = inverseDistance(X, x0, width)
            %% INVERSEDISTANCE
            %  Usage:   y = inverseDistance(X, x0, width)
            %  @param   X is multiplet coord as row, e.g., [3.1 4 6.2], (0:0.01:1)';
            %           or matrix coord; each point has a multiplet-coord row
            %  @param   x0 is multiplet coord origin as row, e.g., [x0_1 x0_2 x0_3]
            %  @param   width is multiplet fwhh as row, e.g., [std_1 std_2 std_3]
            %  @returns y is col of same height as X

            if [1 2]   ~= size(size(X)), error(help('inverseDistance')); end %#ok<*BDSCA>
                  dim   = size(X,2);
            if [1 dim] ~= size(x0),      error(help('inverseDistance')); end
            if [1 dim] ~= size(width),   error(help('inverseDistance')); end
            
            % using \frac{c}{r} s.t. \frac{c}{\frac{width}{2}} = \frac{1}{2} by def. of width \in \mathbb{R}^3,
            % y = \frac{c}{r}
            y           = 1 ./ mlfourd.CoulombBlurringNIfTId.metricDistance(X, x0, 4 ./ width);
            ymax        = max(max(y .* isfinite(y)));
            y(isinf(y)) = ymax;
            y           = y / sum(sum(y));
        end
        function d     = metricDistance(X, x0, g)
            %% METRICDISTANCE
            %  Usage:   d = metricDistance(X, x0)
            %  @param   X is multiplet coord as row, e.g., [3.1 4 6.2], (0:0.01:1)';
            %           or matrix coord; each point has a multiplet-coord row
            %  @param   x0 is multiplet coord origin as row, e.g., [x0_1 x0_2 x0_3]
            %  @param   g is multiplet diagonal metric as row, e.g., [g_11 g_22 g_33]
            %  @returns d is col of same height as X
            
            assert(all(size(x0) == size(X(1,:))));
            assert(all(size(x0) == size(g)));
            d  = ones(size(X,1),1);
            for n = 1:length(d)
                dX   = (X(n,:) - x0) .* g;
                d(n) = norm(dX, 2);
            end
        end
    end
    
    methods (Access = private)
        function img = blurredVolume(this, img, mmppix)
            assert(isnumeric(img));
			img = double(this.mask) .* ...
                  this.chargesToScalarPotentials(squeeze(double(img)), this.blur, 'metric', 'mm', 'metricppix', mmppix);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

