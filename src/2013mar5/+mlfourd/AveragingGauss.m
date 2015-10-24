classdef AveragingGauss < mlfourd.AveragingType 
	%% AVERAGINGGAUSS is a place-holder for AveragingStrstegy for the case of no averaging
	%  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AveragingGauss.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: AveragingGauss.m 2318 2013-01-20 06:52:48Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
        blur = mlfsl.PETBuilder.petPointSpread;
    end 

    methods (Static) %% legacy
        function out   = makeBlurred(in, blr)
            
            %% MAKEBLURRED tries to preserve the class of in
            %
            import mlfourd.*;         
            iniib = NiiBrowser.load(imcast(in, 'char'));
            iniib = iniib.append_fileprefix(AveragingGauss.blurSuffix(blr));
            iniib = iniib.append_descrip( ['blurred by ' num2str(blr)]);
            iniib = iniib.blurredBrowser(blr);
            out   = imcast(iniib, class(in));
        end % static makeBlurred        
        function img   = gaussFullwidth(img, width, metric, metppix, height)
            
            %% GAUSSFULLWIDTH applies multi-dimensional, anisotropic, Gaussian filtering to 
            %                 numeric objects.
            %  Usage: gimg = NiiBrowser.gaussFullwidth(img, width, metric, metppix, height)
            %         img:       numeric object
            %         width:     row vector of full widths
            %         metric:    units of full width blur
            %         metppix:   metric units per pixel; 1 and [1 1 1] are equivalent
            %         height:    height at which width is measured (fraction 0..1)
            %         gimg:      Gaussian-blurred image returned
            %  Examples:
            %         gimg = this.gaussFullwidth(img, [fwhh_x fwhh_y])
            %         gimg = this.gaussFullwidth(img, fwhh_vec3, 'mm', PETBuilder.petPointSpread, 0.1)                                                                   %
            %  See also:  NiiBrowser.gaussSigma
            %
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
                         ['NiiBrowser.gaussFullwidth.nargin->' num2str(nargin)]);
            end
            img = NiiBrowser.gaussSigma(img, NiiBrowser.width2sigma(width, height), metric, metppix);
        end % static gaussFullwidth
        function img   = gaussSigma(img, sigma, metric, metppix)
            
            %% GAUSSSIGMA applies multi-dimensional, anisotropic, Gaussian filtering to 
            %             numeric objects.
            %  Usage: gimg = NiiBrowser.gaussSigma(img, width, metric, metppix)
            %         img:       numeric object
            %         sigma:     row vector of std. deviations
            %         metric:    units of sigma
            %         metppix:   metric units per pixel; 1 and [1 1 1] are equivalent
            %         gimg:      blurred double image returned
            %  Examples:
            %         gimg = this.gaussSigma(img, [fwhh_x fwhh_y])
            %         gimg = this.gaussSigma(img, fwhh_vec3, 'mm', PETBuilder.petPointSpread)
            %  See also:  NiiBrowser.gaussFullwidth
            %
            import mlfourd.*;
            KERNEL_MULTIPLE = 3;
            switch (nargin)
                case 2
                    metric  = 'voxel';
                    metppix = 1;
                case 4
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['NiiBrowser.gaussSigma.nargin->' num2str(nargin)]);
            end
            switch (lower(metric)) 
                case {'pixel', 'pixels', 'voxel', 'voxels'}
                    metppix = 1;
                case  'mm'
                case  'cm'
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['NiiBrowser.gaussFullwidth.metric->' metric ' was unrecognizable;\n' ...
                          'try pixel(s), voxel(s), mm, cm']);
            end
            img      = mlfourd.NIfTI.ensureDble(img);
            imgRank = length(size(img));
            if (length(sigma) < imgRank)
                sigma = NiiBrowser.embedVecInSitu(sigma, zeros(size(img)));
            end
            if (length(metppix) < length(sigma))
                metppix = NiiBrowser.stretchVec(metppix, length(sigma));
            else
                assert(length(metppix) == length(sigma));
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
            h1  = reshape(gaussian(h0, zeros(1,imgRank), sigma), krnlLens);
            img = imfilter(img, h1);
            
            % Private utility subfunctions              
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
        end % static gaussSigma
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
            %
            switch (nargin)
                case 1
                    fheight = 0.5;
                case 2
                otherwise
                    error('mlfourd:InputParamsErr', ['NiiBrowser.width2sigma.nargin->' num2str(nargin)]);
            end
            sigma = abs(sqrt((width/2).^2/(2*log(1/fheight))));
        end % static function width2sigma
        function width = sigma2width(sigma, fheight)
            
            %% SIGMA2WIDTH returns the width at fheight corresponding to sigma, metppix & metric units.
            %  Usage: width = sigma2width(sigma[, fheight])
            %         width:   vector for full-width at half-height, in metric units
            %         fheight: fractional height, 0.5 for fwhh is default, 0.1 for fwth
            %         sigma:   vector in units of metric
            %
            %  See also:   width2sigma
            %
            switch (nargin)
                case 1
                    fheight = 0.5;
                case 2 
                otherwise
                    error('mlfourd:InputParamsErr', ['NiiBrowser.sigma2width.nargin->' num2str(nargin)]);
            end
            width = 2*sqrt(2*log(1/fheight)*sigma.^2);
        end % static sigma2width    
        function suff  = blurSuffix(blur)
            if (norm(blur) > eps)
                b    = blur;
                suff = ['_' num2str(b(1),1) 'x' num2str(b(2),1) 'x' num2str(b(3),1) 'gauss'];
            else
                suff = '';
            end
        end % blurSuffix       
    end 
    
	methods % set/get
        function this  = set.blur(this, blr)
            %% SET.BLOCKSIZE adds singleton dimensions as needed to fill 3D
            
            assert(isnumeric(blr));
            switch (numel(blr))
                case 1
                    this.blur = [blr blr blr]; % isotropic
                case 2
                    this.blur = [blr(1) blr(2) 0]; % in-plane only
                case 3
                    this.blur = [blr(1) blr(2) blr(3)];
                otherwise
                    this.blur = [0 0 0];
            end
        end % set.blur 
    end
    
    methods
        function this  = AveragingGauss(blur) 
            if (exist('blur','var'))
                this.blur = blur;
            end
 		end %  ctor 
        function imobj = average(this, imobj, blur) 
            if (exist('blur', 'var'))
                this.blur = blur;
            end
            imobj = this.makeBlurred(imobj, this.blur);
        end         
        function tf    = blur2bool(this)
            assert(isnumeric(this.blur));
            tf = ~all([0 0 0] == this.blur);
        end    		
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end



