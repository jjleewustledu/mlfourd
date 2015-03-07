classdef NiiBrowser < mlfourd.NIfTI
    %% NIIBROWSER is a subclass of NIfTI with data-mining functionality
    %  Usage:   obj = NiiBrowser(nii [, blr, blk, krnlMult])
    %                            ^ passed to NIfTI
    %                                   ^    ^ row vectors for blurring, blocksizes
    %
    % Created by John Lee on 2008-6-5.
    % Copyright (c) 2008 Washington University School of Medicine.  All rights reserved.
    % Report bugs to bug.jjlee.wustl.edu@gmail.com.
    
    properties 
        blur            = [];
        blurCount       = 0;
        block           = [];
        blockCount      = 0;
        scaling         = 'NONE';
        inclusion_frac  = 0.5; % min. fraction of voxels required to create a blocked voxel
        resamplerInterpolant = 'nearest'; % 'cubic', 'linear' or 'nearest' for tformresampler
    end
    
    methods
        
        function this  = NiiBrowser(nii, blr, blk)
            
            %% NIIBROWSER is a subclass of NIfTI with data-mining functionality
            %  Usage:   obj = NiiBrowser(nii [, blr, blk])
            %                            ^ passed to NIfTI
            %                                   ^    ^ row vectors for blurring, blocksizes
            this = this@mlfourd.NIfTI(nii);
            import mlfourd.*;
            switch (nargin)
                case 1
                    this.blur  = zeros(size(size(nii)));
                    this.block = ones( size(size(nii)));
                case 2
                    this.blur  = blr;
                    this.block = ones( size(size(nii)));
                case 3
                    this.blur  = blr;
                    this.block = blk;
                otherwise
                    error('mlfourd:WrongInputParams', ['NiiBrowser.ctor.nargin->' num2str(nargin)]);
            end
            assert(isnumeric(this.blur));
            assert(isnumeric(this.block));
        end % ctor   
        
        function this  = set.scaling(this, sc)
            switch (sc)
                case 'FRAC_MEAN'
                case 'FRAC_DIFF'
                case 'FRAC_MEAN_DIFF'
                case 'STD_MOMENT'
                case 'NONE'
                otherwise
                    error('mlfourd:UnsupportedParameterValue', ...
                          'NiiBrowser.set.scaling.sc -> %s is not supported', sc);
            end
        end % set.scaling
        
        function inv   = safe_inversion(this, fg)
            
            %% SAFE_INVERSION returns 1/img avoiding division by zero
            %  Usage:   niib     = NiiBrowser(...)
            %           inv_niib = niib.safe_inversion([fg])
            %                                       ^ double array, NIfTI
            if (nargin < 2); fg = double(abs(this.img) > eps); end
            if (isnumeric(fg)) 
                fg  = double(abs(fg) > eps);
                fg  = this.makeSimilar(fg, 'fg mask', 'fgmask');
            end % fg is now NIfTI
            assert(all(this.size == fg.size));
            bg      =   fg.makeSimilar(double(~fg.img), 'bg mask', 'bgmask'); % bg is NIfTI
            inv     = this.makeSimilar(      this.img,   ...
                      'inverse', ['inv_' this.fileprefix]); % inv is NIfTI
            inv.img = this.img + bg.img;
            inv     = inv.ones ./ inv;
            inv     = inv - fg;
            assert(all(reshape(isfinite(inv.img), [prod(inv.size) 1])));
            inv     = mlfourd.NiiBrowser(inv);
        end % safe_inversion
        
        function quo   = safe_quotient(this, den, fg, blur, scale)
        
            %% SAFE_QUOTIENT 
            %  Usage:  quo = obj.safe_quotient(den, fg, blur, scale)
            %          ^ NIfTI                 ^   ^ optional NIfTI
            %                                           ^ [10 10 11], e.g.
            %                                                 ^ scalar multiplies quotient
            import mlfourd.*;
            if (nargin < 2)
                quo = this; return;
            end
            if (isnumeric(den))
                den = double(den); 
                den = NiiBrowser(...
                    this.makeSimilar(den, 'double denominator', 'denominator'));
            end
            switch(nargin)
                case 5
                    fgb     = mlfourd.NiiBrowser(fg, blur);
                    fgb     = fgb.blurredBrowser;
                    fgb.img = fgb.img / fgb.dipmax; % normalize mask
                    inv     = this.safe_inversion(fg);
                    quo     = this .* inv;
                    quo.img = quo.img * scale;
                case 4
                    fgb     = mlfourd.NiiBrowser(fg, blur);
                    fgb     = fgb.blurredBrowser;
                    fgb.img = fgb.img / fgb.dipmax; % normalize mask
                    inv     = this.safe_inversion(fg);
                    quo     = this .* inv;
                case 3
                    inv = this.safe_inversion(fg);
                    quo = this .* inv;
                case 2
                    quo = this .* (den.safe_inversion);
                otherwise 
                    paramError(this, 'nargin', nargin);
            end     
        end % safe_quotient
                    
        function this  = rescaleImg(this, msknii)
                       
            %% RESCALEIMG rescales internal image intensities 
            %  Usage:  obj = NiiBrowser(...);
            %          obj = obj.rescaleImg(msknii)
            %                                    ^ NIfTI mask
            %  Set property scaling:  FRAC_MEAN, FRAC_DIFF, FRAC_MEAN_DIFF, STD_MOMENT
            %
            import mlfourd.*;     
            assert(NIfTI.isNIfTI(msknii));
            msknii    = NIfTI_mask(msknii);            
            assert(isfinite(dipsum(this.img)));
            assert(isfinite(dipsum(msknii.img)));
            niib      = NiiBrowser(this, mlfourd.NiiPublish.dbblur);
            vec       = niib.sampleVoxels(msknii.img);
            pipeline  = mlpipeline.PipelineRegistry.instance;
            if (pipeline.debugging)
                disp(['mean niib.sampleVoxels(msk) -> ' num2str(mean(vec))]);
                disp(['std                         -> ' num2str( std(vec))]);
                disp(['min                         -> ' num2str( min(vec))]);
                disp(['max                         -> ' num2str( max(vec))]);
            end
            meanimg = mean(vec);
            stdimg  = std(vec);
            switch (this.scaling)
                case 'FRAC_MEAN'
                    img =  this.img/meanimg;
                case 'FRAC_DIFF'
                    img =  this.img - meanimg*ones(size(this.img));
                case 'FRAC_MEAN_DIFF'
                    img =  this.img/meanimg - ones(size(this.img));
                case 'STD_MOMENT'
                    img = (this.img - meanimg*ones(size(this.img)))/stdimg;
                otherwise
            end
            this.img = img;
            this     = this.append_descrip(['rescaled to mean ' num2str(meanimg)]);
        end % rescaleImg
        
        function o     = ones(this)
            import mlfourd.*;
            o = ones@mlfourd.NIfTI(this);
            o = NiiBrowser(o);
        end
        
        function z     = zeros(this)
            import mlfourd.*;
            z = zeros@mlfourd.NIfTI(this);
            z = NiiBrowser(z);
        end
        
        function this  = mas(this, msk)
            
            %% MAS : use (following image>0) to mask current image
            this = this .* (mlfourd.NIfTI(msk) > 0);
            this.fileprefix = [this.fileprefix '_masgt0'];
        end
        
        function this  = thr(this, th)
            
            %% THR : use following number to threshold current image (zero anything below the number)
            this.img = this.img .* (this.img > th);            
            this.fileprefix = [this.fileprefix '_thr' num2str(th)];
        end
        
        function this  = thrp(this, p)
            
            %% THRP : use following percentage (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            if (p > 1); p = p/100; end
            this.img = this.img .* (this.img > norminv(p, this.dipmean, this.dipstd));
            this.fileprefix = [this.fileprefix '_thrp' num2str(p)];
        end
        
        function this  = thrP(this, p)
            
            %% THRP : use following percentage (0-100) of ROBUST RANGE of non-zero voxels and threshold below
            if (p > 1); p = p/100; end
            msk = this.img ~= 0;
            nonzero = this.sampleVoxels(msk);
            this.img = this.img .* (this.img > norminv(p, mean(nonzero), std(nonzero)));
            this.fileprefix = [this.fileprefix '_thrP' num2str(p)];
        end
        
        function this  = uthr(this, uth)
            
            %% UTHR : use following number to upper-threshold current image (zero anything above the number)
            this.img = this.img .* (this.img < uth);
            this.fileprefix = [this.fileprefix '_uthr' num2str(uth)];
        end
        
        function this  = uthrp(this, p)
            
            %% UTHRP : use following percentage (0-100) of ROBUST RANGE to upper-threshold current image 
            %          (zero anything above the number)
            if (p > 1); p = p/100; end
            this.img = this.img .* (this.img < norminv(p, this.dipmean, this.dipstd));
            this.fileprefix = [this.fileprefix '_uthrp' num2str(p)];
        end
        
        function this  = uthrP(this, p)
            
            %% UTHRP : use following percentage (0-100) of ROBUST RANGE of non-zero voxels and threshold above
            if (p > 1); p = p/100; end
            msk = this.img ~= 0;
            nonzero = this.sampleVoxels(msk);
            this.img = this.img .* (this.img < norminv(p, mean(nonzero), std(nonzero)));
            this.fileprefix = [this.fileprefix '_uthrP' num2str(p)];
        end
        
        function this  = nan(this)
            this.img = this.img .* (~isnan(this.img));
            this.fileprefix = [this.fileprefix '_nan'];
        end
        
        function this  = nanm(this)
            this.img = isnan(this.img);
        end
        
        function this  = makeStdMoment(this, upthresh, msk)
            
            %% MAKESTDMOMENT returns this with it's img expressed as the standardized moment
            %  Usage:   obj = obj.makeStdMoment([upthresh, msk])
            %                                    ^ # of std. dev. above mean(img)
            %                                              ^ NiiBrowser or numeric
            if (nargin < 2); upthresh = 3; end
            if (nargin < 3); msk      = this.img > eps; end
            assert(isnumeric(upthresh) && length(upthresh) == 1);
            
            msk   =  double(msk);
            img   =  this.img .* msk;
            upthresh =  dipmean(img) + upthresh * dipstd(img);
            img   =  img .* (img < upthresh);
            img   = (img - dipmean(img)) ./ dipstd(img);
            this.img =  double(img);
        end
        
        function this  = blockBrowser(this, blk, msk)
            
            %% BLOCKBROWSER downsamples voxels, returning the NiiBrowser with new state 
            %  Usage:  b = NiiBrowser(...);
            %          b = b.blockBrowser([block, mask])
            %          block:  row-vector size of block to down-sample, e.g., [3.59 3.59 5]
            %          mask:   NIfTI or numeric mask to apply after blocking 
            %
            import mlfourd.*;
            switch (nargin)
                case 1
                    [img, this] = this.blockedVoxels(this.block);
                case 2
                    [img, this] = this.blockedVoxels(blk);
                case 3
                    [img, this] = this.blockedVoxels(blk, msk);
            end
            this.img = img;
        end % blockBrowser
        
        function [imgOut, this] = blockedVoxels(this, blk, msk)
            
            %% BLOCKEDVOXELS averages blocks of voxels and returns a reduced-size image.
            %                Changes state of obj.
            %  Usage: obj          = mlfourd.NiiBrowser(...);
            %        [imgOut, obj] = obj.blockedVoxels([block, mask])
            %         block:  row-vector size of block to down-sample, e.g., [3.59 3.59 5]
            %         mask:   NIfTI or numeric mask to apply after blurring 
            %         imgOut: reduced-size image with voxel mmppix <- mmppix .* block
            %  e.g.: [imgOut, obj] = obj.blockedVoxels([3.59 3.59 5], 1)
            %
            import mlfourd.*;
            switch (nargin)
                case 1
                    blk = this.block;
                    msk = this.ones;
                case 2                                      
                    msk = this.ones;
                case 3 
                otherwise
                    error('mlfourd:WrongInputParams', ...
                         ['NiiBrowser.blockedVoxels.nargin -> ' num2str(nargin)]);
            end
            assert(all(blk > 0));
            % msk = NIfTI_mask(msk);
            assert(all(this.size == msk.size));
            this = this.append_descrip([     'blocked voxels by [' num2str(blk) ']']);
            disp(['NiiBrowser.blockedVoxels:  blocked voxels by '  num2str(blk)]);
            % embed this.img in 4D with singleton dims as necessary
            switch (this.rank)
                case 1
                    img0        = zeros(length(this.img), 1, 1);
                    img0(:,1,1) =              this.img .* msk.img;
                    blk         = [blk 1 1];
                case 2
                    img0        = zeros(size(this.img,1), size(this.img,2), 1);
                    img0(:,:,1) =            this.img .* msk.img;
                    blk         = [blk(1) blk(2) 1];
                case 3
                    img0        =  this.img .* msk.img;
                    blk         = [blk(1) blk(2) blk(3)];
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['this.rank had unsupported value->' num2str(this.rank)]);
            end
            this.img = img0;
            %natural  = all(abs(mod(this.size, blk)) < eps); % natural numbers
            %if (natural)
            %    [imgOut, this] = block_by_index(this, uint32(blk));
            %else
                [imgOut, this] = block_by_position(this, blk);
            %end
            this.img        = double(scrubNaNs(imgOut));
            this.blockCount = this.blockCount + 1;
        end % blockedVoxels
        
        function [imgOut, this] = block_by_index(this, blk)
            
            % BLOCK_BY_INDEX performs blocking by real valued blk (voxels)
            % using the Matlab indexing style
            %
            import mlfourd.*;
            mask0     = zeros(blk); 
            sizeOut   = uint32(this.size ./ blk);
            prodBlk   =  prod(blk);
            minVoxels = this.inclusion_frac * prodBlk;
            imgOut    = zeros(sizeOut);
            for iz = 1:sizeOut(3) %#ok<FORFLG>
                for iy = 1:sizeOut(2) 
                    for ix = 1:sizeOut(1)
                        iz0    = 1 + (iz - 1)*blk(3); 
                        iy0    = 1 + (iy - 1)*blk(2);
                        ix0    = 1 + (ix - 1)*blk(1);
                        patch0 = this.img(ix0:ix0 + blk(1) - 1, ...
                                          iy0:iy0 + blk(2) - 1, ...
                                          iz0:iz0 + blk(3) - 1); 
                        mask0sum         = sum(sum(sum(mask0)));
                        mask0            =    (mask0sum > minVoxels) .* mask0;
                        imgOut(ix,iy,iz) = sum(sum(sum(mask0 .* patch0)))/mask0sum; 
                    end
                end
            end
            this.pixdim = this.pixdim .* blk;
            this.img = imgOut;
        end % block_by_index
        
        function [img1, this]   = block_by_position(this, blk)
            
            % BLOCK_BY_POSITION performs blocking by real valued blk (voxels)
            % using the image center as the origin; uses spatial coordinate system
            %
            import mlfourd.*;
            blk    = NiiBrowsesr.embedVecInSitu(blk, this.size);
            xform  = [ 1/blk(1) 0 0 0; 0 1/blk(2) 0 0; 0 0 1/blk(3) 0; 0 0 0 1 ]; 
            T      = maketform('projective', xform);
            R      = makeresampler(this.resamplerInterpolant, 'fill');
            img1   = tformarray(this.img, T, R, [1 2 3], [1 2 3], ceil(this.size./blk), [], 0);
        end % block_by_position   

        function smp  = sampleVoxels(this, msk)
            
            %% SAMPLEVOXELS returns a vector of sampled image voxels chosen by masks.
            %  Usage: this = mlfourd.NiiBrowser(...);
            %         smp = this.sampleVoxels(msk)
            %         msk:  mask object, may be double, single, logical
            %         smp:  double column vector
            %
            import mlfourd.*;
            switch (nargin)
                case 2                    
                case 1
                    msk = ones(this.size);
                otherwise
                    error('mlfourd:NotImplementedErr', ['NiiBrowser.sampleVoxels.nargin->' num2str(nargin)]);
            end
            smp = NiiBrowser.makeSampleVoxels(this.img, msk);
        end % sampleVoxels
        
        function this = blurredBrowser(this, blr, msk)
            
            %% BLURREDBROWSER blurs voxels with 3D kernels and returns the NiiBrowser with  
            %              changed state. 
            %  Usage:  nb = mlfourd.NiiBrowser(...);
            %          nb = nb.blurredBrowser([blur, msk])
            %          blr:  3-vector, FWHH in mm
            %          msk:  NIfTI, numeric or logical mask applied after blurring
            %          nb:   NiiBrowser updated with blurred voxels
            
            if (4 == length(this.size))
                this = blurredBrowser4d(this, blr, msk);
                return
            end
            
            import mlfourd.*;
            switch (nargin)
                case 1
                    blr = mlpet.PETBuilder.petPointSpread;
                    msk = 1;
                case 2
                    assert(all(size(blr) == size(this.mmppix))); 
                    msk = 1;   
                case 3
                    assert(all(size(blr) == size(this.mmppix))); 
                    msk = NIfTI.ensureDble(NIfTI_mask(msk));        
                otherwise
                    error('mlfourd:NotImplemented', ...
                         ['NiiBrowser.blurredBrowser received ' num2str(nargin) ' args']);
            end
            this.blur      = blr;
            if (sum(blr) < eps); return; end            
            this           = this.forceDouble;
			this.img       = double(msk) .* this.gaussFullwidth(this.img, blr, 'mm', this.mmppix);
            this.blurCount = this.blurCount + 1;
            this.fileprefix = this.blurredFileprefix;
            this.append_descrip(['blurred to ' num2str(blr)]);
        end        
        function this = blurredBrowser4d(this, blr, msk)
            
            %% BLURREDBROWSER blurs voxels with 3D kernels and returns the NiiBrowser with  
            %              changed state. 
            %  Usage:  nb = mlfourd.NiiBrowser(...);
            %          nb = nb.blurredBrowser([blur, msk])
            %          blr:  3-vector, FWHH in mm
            %          msk:  NIfTI, numeric or logical mask applied after blurring
            %          nb:   NiiBrowser updated with blurred voxels
            
            import mlfourd.*;
            switch (nargin)
                case 1
                    blr = mlpet.PETBuilder.petPointSpread;
                    msk = 1;
                case 2
                    assert(all(size(blr) == size(this.mmppix(1:3)))); 
                    msk = 1;   
                case 3
                    assert(all(size(blr) == size(this.mmppix(1:3)))); 
                    msk = NIfTI.ensureDble(NIfTI_mask(msk));        
                otherwise
                    error('mlfourd:NotImplemented', ...
                         ['NiiBrowser.blurredBrowser received ' num2str(nargin) ' args']);
            end
            this.blur      = blr;
            if (sum(blr) < eps); return; end            
            this           = this.forceDouble;
            for t = 1:this.size(4)
                this.img(:,:,:,t) = double(msk) .* this.gaussFullwidth(this.img(:,:,:,t), blr, 'mm', this.mmppix(1:3));
            end
            this.blurCount = this.blurCount + 1;
            this.fileprefix = this.blurredFileprefix;
            this.append_descrip(['blurred to ' num2str(blr)]);
        end        
        function fp = blurredFileprefix(this)
            twoDigits = cell(1,3);
            for d = 1:length(twoDigits)
                [x,x2] = strtok(num2str(this.blur(d)), '.');
                xfused = [x x2(2:end)];
                twoDigits{d} = xfused(1:2);
            end
            fp = [this.fileprefix '_' twoDigits{1} twoDigits{2} twoDigits{3} 'fwhh'];
        end
    end % methods 
    
    methods (Static)
        
        function intdr = integral_img(dom, r1, r2, rori, mmppix, img)
                
            import mlfourd.*;
            inf_i1 = min(NiiBrowser.real_to_idx(r1, rori, mmppix),     size(img));
            sup_i2 = min(NiiBrowser.real_to_idx(r2, rori, mmppix) + 1, size(img));
            range  = img(inf_i1(1):sup_i2(1), inf_i1(2):sup_i2(2), inf_i1(3):sup_i2(3));
            domain = cell(1,3);
            domain{1} = dom{1}(inf_i1(1):sup_i2(1), 1, 1);
            domain{2} = dom{2}(1, inf_i1(2):sup_i2(2), 1);
            domain{3} = dom{3}(1, 1, inf_i1(3):sup_i2(3));
            for c = 1:3 %#ok<FORFLG>
                if (numel(range) > 1) 
                    range = trapz(squeeze(domain{c}), range, c);
                end
            end
            intdr = range*prod(mmppix);
        end % static integral_img

        function r          = idx_to_real(idx, rori, mmppix)
            r = idx .* mmppix - rori;
        end % static idx_to_real
        
        function [idx,frac] = real_to_idx(r, rori, mmppix)
            
            %% REAL_TO_IDX always rounds toward zero w/o reaching zero
            idx  = (r + rori) ./ mmppix;
            frac = mod(idx,1);
            idx  = round(idx);
            idx  = max(idx, ones(size(idx))); 
        end % static real_to_idx
        
        function niib  = load(fn, desc, blr, blk)
            
            %% LOAD is an NiiBrowser factory that loads filename fn
            %  See also:   NIfTI.load, Jimmy Shen's load_nii
            %
            import mlfourd.* mlfsl.*;
            switch (nargin)
                case 1
                    desc = ['NiiBrowser.load read ' fn ' on ' datestr(now)];
                    blr  = mlpet.PETBuilder.petPointSpread; blk = [1 1 1];
                case 2
                    blr  = mlpet.PETBuilder.petPointSpread; blk = [1 1 1];
                case 3
                                                       blk = [1 1 1];
                case 4
                otherwise
                    error('mlfourd:NotImplemented', 'load.nargin->%i', nargin);
            end
            nii  = load@mlfourd.NIfTI(fn, desc);
            niib = NiiBrowser(nii, blr, blk);
        end % static load        
        
        function sz    = embedVecInSitu(sz, fixedsz)
            
            %% EMBEDVECINSITU resizes sz to match rank of fixedsz
            %  e.g.  >> sz = NIfTI.embedVecInSitu([2 2 30], [18 18 31 100])
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
        end % static embedVecInSitu            
        
        function vout  = stretchVec(vin, newlen, repeat)
            
            %% STRETCHVEC stretches a vector to a new size, with repeated final element as necessary
            %  Usage: [vout] = stretchVec(vin, newlen, repeat)
            %         vin:     col or row vector
            %         vout:    col or row vector with new length newlen
            %         repeat:  value to repeat; default is 1, creating singleton dimensions
            %  Examples:
            %         [vout8] = stretchVec(vin3, 8)
            %  See also:   embedVecInSitu
            %
            switch (nargin)
                case 3
                case 2
                    repeat = 1;
                otherwise
                    error('mlfourd:InputParamsErr:InputParamsErr', ...
                         ['NIfTI.stretchVec.nargin->' num2str(nargin)]);
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
        end % static function stretchVec  
        
        function out   = makeBlurred(in, blr)
            
            %% MAKEBLURRED tries to preserve the class of in
            %
            import mlfourd.*;
            assert(all([1 3] == size(blr)));
            fsuffix   = ['_' num2str(blr(1)) 'x' num2str(blr(2)) 'x' num2str(blr(3)) 'blur'];
            descrip   = ['blurred by ' num2str(blr)];
            if (NIfTI.isNIfTI(in))                
                iniib = NiiBrowser(in);
                iniib = iniib.append_fileprefix(fsuffix);
                iniib = iniib.append_descrip(descrip);
            else
                iniib = NiiBrowser(NIfTI(in, [in.fileprefix fsuffix], descrip));
            end
            iniib     = iniib.blurredBrowser(blr);
            switch (class(in))
                case {'single', 'double', 'int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64'}
                    out = iniib.img;
                case 'struct'
                    out = iniib.struct;
                case 'mlfourd.NIfTIInterface'
                    out = NIfTI(iniib);
                case 'mlfourd.NIfTI_mask'
                    out = NIfTI_mask(iniib);
                case 'mlfourd.NiiBrowser'
                    out = iniib;
                otherwise
                    out = in;
            end
        end % static makeBlurred
        
        function out   = makeBlocked(in, blk)
            
            %% MAKEBLOCKED tries to preserve the class of in
            %
            import mlfourd.*;
            if (nargin < 2)
                blk = [1 1 1];
            end
            assert(all([1 3] == size(blk)));
            fsuffix   = ['_' num2str(blk(1)) 'x' num2str(blk(2)) 'x' num2str(blk(3)) 'blocks'];
            descrip   = ['blocked by ' num2str(blk)];
            if (NIfTI.isNIfTI(in))
                iniib = NiiBrowser(in);
                iniib = iniib.append_fileprefix(fsuffix);
                iniib = iniib.append_descrip(descrip);
            else
                iniib = NiiBrowser(NIfTI(in, [in.fileprefix fsuffix], descrip));
            end
            iniib     = iniib.blockBrowser(blk, iniib.ones);
            switch (class(in))
                case {'single', 'double', 'int8', 'int16', 'int32', 'int64', 'uint8', 'uint16', 'uint32', 'uint64'}
                    out = iniib.img;
                case 'struct'
                    out = iniib.struct;
                case 'mlfourd.NIfTIInterface'
                    out = NIfTI(iniib);
                case 'mlfourd.NIfTI_mask'
                    out = NIfTI_mask(iniib);
                case 'mlfourd.NiiBrowser'
                    out = iniib;
                otherwise
                    out = in;
            end
        end % static makeBlocked

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
            %         gimg = this.gaussFullwidth(img, fwhh_vec3, 'mm', mlpet.PETBuilder.petPointSpread, 0.1)                                                                   %
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
            %         gimg = this.gaussSigma(img, fwhh_vec3, 'mm', mlpet.PETBuilder.petPointSpread)
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
                sigma = NiiBrowser.embedVecInSitu(sigma, zeros(size(size(img))));
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
            h1  = reshape(NiiBrowser.gaussian(h0, zeros(1,imgRank), sigma), krnlLens);
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
        
        function [vec] = makeSampleVoxels(img, msk, thresh)
            
            %% MAKESAMPLEVOXELS returns a double column vector containing voxels selected by
            %  a mask.
            %  Usage: vec = makeSampleVoxels(img, msk, thresh)
            %         img, msk:  double multi-dim object
            %         thresh:    threshold for converting prob. mask to binary mask
            %         vec:       double column-vector
            %
            switch (nargin)
                case 1
                    msk    = ones(size(img));
                    thresh = 0.5;
                case 2
                    thresh = 0.5;
                case 3
                otherwise
                    error('mlfourd:NotImplementedErr', ...
                         ['NiiBrowser.makeSampleVoxels.nargin->' num2str(nargin)]);
            end
            import mlfourd.*;
            img = NIfTI.ensureDble(img);
            msk = NIfTI.ensureDble(msk); 
            assert(all(size(msk) == size(img)));
            msk = squeeze(double(msk > thresh)); % make binary 
            vec = img(msk ~= 0.0000);
        end % static makeSampleVoxels   
    end % methods (Static)
    
    %% PRIVATE
    
    methods (Static, Access = 'private')
        function y = gaussian(X, mu, sigma)
            %% GAUSSIAN
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
            
            if [1 2]   ~= size(size(X)), error(help('gaussian')); end %#ok<*BDSCA>
            npts = size(X,1);
            dim  = size(X,2);
            if [1 dim] ~= size(mu),      error(help('gaussian')); end
            if [1 dim] ~= size(sigma),   error(help('gaussian')); end
            
            y    = ones(npts, 1);
            for d = 1:dim
                if (sigma(d) > eps)
                    y = y .* normpdf(X(:,d), mu(d), sigma(d)); end
            end            
            if [npts 1] ~= size(y), error('mlfourd:arraySizeError', ['oops...  size(y) was ' num2str(size(y))]); end
            
        end
    end
end % classdef

