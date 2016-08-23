classdef CoulombPotentialNIfTId < mlfourd.NIfTIdecoratorProperties
	%% COULOMBPOTENTIALNIFTID  
            
	%  $Revision$
 	%  was created 08-Aug-2016 19:20:42
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.341360 (R2016a) for MACI64.
 	

    properties
        blur % mm $\in \mathbb{R} or \in \mathbb{R}^3$
    end
    
    properties (Dependent)
        mask
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
        function bc   = get.blurCount(this)
            bc = this.blurCount_;
        end
    end

    methods (Static)
        function this  = load(varargin)
            %% LOAD instantiates CoulombPotentialNIfTId with all varargin passed to NIfTId.load
            
            import mlfourd.*;
            this = CoulombPotentialNIfTId(NIfTId.load(varargin{:}));
        end        
    end
    
	methods
 		function this = CoulombPotentialNIfTId(cmp, varargin)
 			%% CoulombPotentialNIfTId
 			%  Usage:  this = CoulombPotentialNIfTId(INIfTI_object[,parameterName, parameterValue]) 
            %  @param 'mask' is numeric or INIfTI value, default this.ones.
            %  @param 'blur' is numeric in mm.

            this = this@mlfourd.NIfTIdecoratorProperties(cmp);
            
            ip = inputParser;
            addParameter(ip, 'mask', 1,  @(x) isnumeric(x) || isa(x, 'mlfourd.INIfTI'));
            addParameter(ip, 'blur', 8, @isnumeric);
            parse(ip, varargin{:});
            
            this.mask = double(ip.Results.mask);
            this.blur = ip.Results.blur;
            this.img  = double(this.img);
            this      = this.transform;
 		end
        function obj  = clone(this)
            obj            = mlfourd.CoulombPotentialNIfTId(this.component.clone);
            obj.mask_      = this.mask_;
            obj.blurCount_ = this.blurCount_;
        end    
        function tf   = isequaln(this, bnii)
            tf = isa(bnii, class(this));
            if (tf)
                tf = isa(bnii, 'mlfourd.CoulombPotentialNIfTId');
                if (tf)
                    tf = isequaln(this.blurCount_, bnii.blurCount);
                    if (tf)
                        tf = isequaln(this.mask_, bnii.mask);
                        if (tf)
                            tf = isequaln@mlfourd.NIfTIdecoratorProperties(this, bnii);
                        end
                    end
                end
            end
            
            if (~isequaln(this.mask_, bnii.mask))
                tf  = false;
                warning('mlfourd:notIsequaln', 'CoulombPotentialNIfTId.isequaln:  found mismatch at this.mask.');
                return
            end
            if (~isequaln(this.blurCount_, bnii.blurCount))
                tf  = false;
                warning('mlfourd:notIsequaln', 'CoulombPotentialNIfTId.isequaln:  found mismatch at this.blurCount.');
                return
            end
        end
 	end 
    
    %% PROTECTED
    
    properties (Access = protected)
        mask_
        blurCount_ = 0;
    end
    
    methods (Static, Access = protected)
        function h0   = h3d(krnlLens, imgRank)
            h0    = zeros(prod(krnlLens), imgRank); % filter kernel with peak centered in the kernel's span
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
        function d    = metricDistance(X, x0, gmm)
            %% METRICDISTANCE
            %  Usage:   d = metricDistance(X, x0)
            %  @param   X is multiplet coord as row, e.g., [3.1 4 6.2], (0:0.01:1)';
            %           or matrix coord; each point has a multiplet-coord row
            %  @param   x0 is multiplet coord origin as row, e.g., [x0_1 x0_2 x0_3]
            %  @param   gmm is multiplet diagonal metric as row, e.g., [g_11 g_22 g_33]
            %  @returns d is col of same height as X
            
            assert(all(size(x0) == size(X(1,:))));
            assert(all(size(x0) == size(gmm)));
            d  = ones(size(X,1),1);
            for n = 1:length(d)
                dX   = (X(n,:) - x0) .* gmm;
                d(n) = norm(dX, 2);
            end
        end
    end
    
    methods (Access = protected)   
        function phi  = chargesToScalarPotentials(this, img, varargin)
            %% CHARGESTOSCALARPOTENTIALS returns $\phi \sim \int \frac{d^3r \rho(\vec{r})}{4 \pi \epsilon_0 \|\vec{r}\|}$
            %  Usage:  img = CoulombPotentialNIfTId.chargesToScalarPotentials(img, mask);
            %  @param img is the charge density image, numeric.
            %  @param mask is the mask applied to the charge density before further calculations, numeric.
            %  @returns img is the scalar-potential image.
            
            ip = inputParser;
            addRequired( ip, 'img',     @isnumeric);
            addOptional( ip, 'mask', 1, @isnumeric);
            parse(ip, img, varargin{:});
            img = img .* ip.Results.mask;
            
            import mlfourd.*;
            imgRank = length(size(img));
            
            % Assemble filter kernel & call imfilter    
            krnlLens = ceil(this.blur ./ this.mmppix);
            h0  = CoulombPotentialNIfTId.h3d(krnlLens, imgRank);
            h1  = reshape(this.GreenFunc(h0, zeros(1,imgRank)), krnlLens);
            phi = imfilter(img, h1);            
        end
        function G    = GreenFunc(this, X, x0)
            %% GREENFUNC returns $G(\vec{r}):  \phi(\vec{r}_0) \equiv \int d^3r \, \rho(\vec{r}) G(\vec{r} - \vec{r}_0)$ satisfying
            %  $\int d^3r \, G(\vec{r} - \vec{r}_0) = \int \frac{d^3r}{4 \pi \epsilon_0 \|\vec{r} - \vec{r}_0\|} = \int \frac{d^3r G_0}{\|\vec{r} - \vec{r}_0\|} = 1$ and
            %  $\frac{G_0}{\|\text{width}\|/2} = \frac{\max G(\vec{r})}{2}.$
            %  
            %  Usage:   G = GreenFunc(X, x0, width)
            %  @param   X is coord as row, e.g., [X_{i,1} X_{i,2} X_{i,3}];
            %           or matrix coord s.t. each point has a multiplet-coord row; $X \in \mathbb{R}^2$.
            %  @param   x0 is coord origin as row, e.g., [x0_1 x0_2 x0_3]; $x0 \in \mathbb{R}$.
            %  @returns G is col of same height as X

            if [1 2]         ~= size(size(X)), error(help('GreenFunc')); end %#ok<*BDSCA>
            if [1 size(X,2)] ~= size(x0),      error(help('GreenFunc')); end
            
            G           = 1 ./ mlfourd.CoulombPotentialNIfTId.metricDistance(X, x0, this.mmppix);
            Gmax        = max(max(G .* isfinite(G)));
            G(isinf(G)) = Gmax;
            G           = G / sum(sum(G));
        end   
        function this = transform(this)
            import mlfourd.* mlpet.*;
            assert(this.blurCount_ == 0);
            if (this.rank < 4)  
                this.img = this.chargesToScalarPotentials(this.img, this.mask);
            elseif (4 == this.rank)
                for t = 1:size(this,4)
                    this.img(:,:,:,t) = this.chargesToScalarPotentials(squeeze(this.img(:,:,:,t)), this.mask);
                end
            else
                error('mlfourd:paramOutOfBounds', 'CoulombPotentialNIfTId.transform.rank->%i', this.rank);
            end            
            this.blurCount_ = this.blurCount_ + 1;
            this.fileprefix = this.transformedFileprefix;
            this = this.append_descrip('transformed to CoulombPotential');
        end
        function fp   = transformedFileprefix(this)
            twoDigits = cell(1,3);
            for d = 1:length(this.blur)
                [x,x2] = strtok(num2str(this.blur(d)), '.');
                xfused = [x x2(2:end)]; % remove decimal point
                twoDigits{d} = xfused(1:min(2,end)); % retain only two digits
            end
            fp = [this.fileprefix '_CoulombRegion' twoDigits{1} twoDigits{2} twoDigits{3} 'mm'];
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

