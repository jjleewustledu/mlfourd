classdef NIfTI_mask < mlfourd.NIfTI
    
    properties 
        pthreshold = 0.98;
        threshold  = 0;
        protect    = true;
    end
    
    methods
        
        function this = NIfTI_mask(in, varargin)
            
            %% NIFTI_MASK is a subclass of NIfTI with a variable cell-array of processing options
            %  Usage:  nii = NIfTI_mask([in , option-name, option-value, ...])
            %                           ^ ctor w/o args required by Matlab
            %                            ^ numeric arrays, NIfTI struct, NIfTI object
            %                                 ^ optional cell array containing 
            %
            %          processing options requiring argument:  'threshold', 'binary', 'blur', 'block', 'protect'
            %          processing options with no arguments:   'rescaletounity', 'oneminus'
            %          protect = true preserves the floating point precision & values of the object
            %          ctor does not call NIfTI_mask.ensureMask to avoid endless recursion
            import mlfourd.*; 
            this = this@mlfourd.NIfTI(in);
            if (~isa(in, 'mlfourd.NIfTI_mask'))
                this.threshold = sqrt(eps('single'));
            end
            switch (nargin)
                case 0
                case 1
                otherwise
                    for v = 1:length(varargin) %#ok<FORFLG>
                        if (ischar(varargin{v}))
                            switch (varargin{v})
                                
                                case 'pthreshold'
                                    this.pthreshold = varargin{v+1}; 
                                    this            = this.threshp(this.pthreshold);
                                case 'threshold'
                                    this.threshold  = varargin{v+1}; 
                                    this            = this.thresh(this.threshold);
                                case 'binary'
                                    this         = this.binarize;
                                case 'blur'
                                    this         = NiiBrowser.makeBlurred(this, varargin{v+1});
                                case 'block'
                                    this         = NiiBrowser.makeBlocked(this, varargin{v+1});
                                case 'protect'
                                    this.protect = varargin{v+1}; 
                                case 'rescaletounity'
                                    this         = this.rescaleToUnity;
                                case 'oneminus'
                                    this         = this.oneMinusMask;
                            end
                        end
                    end
            end
        end % ctor
        
        function this = thresh(this, thresh)
            
            %% THRESH returns a binary mask after thresholding
            %  Usage:  mn   = NIfTI_mask(...)
            %          bmsk = nm.thresh(167) % returns img > threshold, as binary image
            if (~exist('thresh', 'var'))
                thresh = this.threshold; 
            end
            mx       = this.dipmax;
            mn       = this.dipmin;
            if (thresh < mn || thresh > mx); thresh = mn; end
            this.img = this.img > thresh;
        end
        
        function this = pthresh(this, pthr)
            
            %% PTHR returns binary mask after applying a robust percent threshold
            %  Usage:  mn   = NIfTI_mask(...)
            %          bmsk = nm.pthr(67) % returns img > threshold, as binary image
            if (pthr >= 1); pthr = pthr/100; end
            this.img = this.img > norminv(pthr, this.dipmean, this.dipstd);
        end
        
        function this = binarize(this)
            
            %% BINARIZE
            this.img = this.img > sqrt(eps);
        end
        
        function this = asSliceMask(this)
            
            %% ASSLICEMASK returns a binary mask with all nonzero slice set to 1
            sz       = this.size;
            unitslab = ones(sz(1), sz(2));
            slmsk    = zeros(sz);
            for z = 1:sz(3) %#ok<FORFLG>
                if (dipsum(this.img(:,:,z)) > eps)
                    slmsk(:,:,z) = unitslab;
                end
            end
            this = this.makeSimilar(slmsk, 'as slice-mask', '_slicemsk');
         end
        
        function this = oneMinusMask(this)
            
            %% ASINVERSEMASK returns the NIfTI_mask with 1 - img/norm{img}
            rescaled = this.rescaleToUnity;
            this     = this.makeSimilar(1 - rescaled, '1 - mask', ['one_minus_' this.fileprefix]);
        end
        
        function mnii = applyMaskTo(this, nii)
            
            %% APPLYMASK returns the passed NIfTI multiplied by the mask in the NIfTI_mask
            %  Usage:   nm = NIfTI_mask(...)
            %           masked_nii = nm.applyMaskTo(arbitary_nii)
            mnii = this.makeSimilar(this .* nii, ['masked by ' nii.label], [nii.fileprefix '_maskedby_' this.fileprefix]);
        end

        function this = rescaleToUnity(this)
            this.img = this.img ./ this.dipmax;
            %this = this.makeSimilar(this.img ./ this.dipmax, '_rescaled to 1', [this.fileprefix '_rescaledTo1']);
        end
    end
    
    methods (Static)
        
        function nii         = load(fn, desc)
            
            %% LOAD is a factory that loads file fn as a NIfTI_mask
            %  See also:   load_nii
            import mlfourd.*;
            if (nargin < 2)
                desc = ['NIfTI_mask.load read ' fn ' at ' datestr(now)];
            end
            nii = NIfTI_mask(load@mlfourd.NIfTI(fn, desc));
        end % static load
        
        function N           = count(roi)
            
            %% COUNT does rapid count of nonzero elements in an ROI
            roi = roi.img > 0;
            N   = dipsum(roi);
        end % static count
        
        function [msk0,msk1] = matchMasks(msk0, msk1)
            
            %% MATCHMASKS adjusts the larger mask to have the same number
            %  of nonzero elements as the other mask
            import mlfourd.*;
            if (NIfTI_mask.count(msk1) == NIfTI_mask.count(msk0)); return; end
            if (NIfTI_mask.count(msk1) > NIfTI_mask.count(msk0))
                msk1 = NIfTI_mask.choose(NIfTI_mask.count(msk0), msk1);
            else
                msk0 = NIfTI_mask.choose(NIfTI_mask.count(msk1), msk0);
            end
        end % static matchMasks
        
        function msk         = choose(N, msk)
            
            %% CHOOSE choses N of the nonzero elements in the msk
            import mlfourd.*;
            nonzeros = msk.img > 0;
            if (dipsum(nonzeros) == N); return; end
            
            tic
            sampling = nonzeros .* rand(size(nonzeros));            % random field within msk
            sampling = sampling > (1 - N/dipsum(nonzeros)); % approx. N chosen elements within msk
            desc     = ['chose N->' num2str(N) 'nonzero elements'];
            filep    = ['_' num2str(N) 'nonzeros'];
            msk      = msk.makeSimilar(sampling .* msk.img, desc, filep);
            disp('NIfTI_mask.choose:  run-time:'); toc
        end % static choose
        
        function msk         = ensureMask(msk)
            
            %% ENSUREMASK ensures correct datatypes, normalization of mask
            import mlfourd.*;
            switch (class(msk))
                case 'char'
                    msk = NIfTI_mask(ensureNii(msk));
                case numeric_types
                    msk = NIfTI_mask(msk);
                case NIfTI.NIFTI_SUBCLASS
                otherwise
                    error('mlfourd:ParamTypeUnsupported', ...
                         ['NIfTI_mask.ensureMask could not recognize passed class ' class(msk)]);
            end
            assert(~isempty(msk));
            assert(msk.dipsum > 0);
            if (~isa(msk, 'mlfourd.NIfTI_mask'))
                msk = NIfTI_mask(msk);
            end
            msk = msk.rescaleToUnity;
        end % static ensureMask
    end % methods (Static)
end
