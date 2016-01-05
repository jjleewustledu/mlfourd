classdef DynamicNIfTId < mlfourd.NIfTIdecorator3
	%% DYNAMICNIFTID   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$  	 

	properties (Dependent)
 		 blur
         mask
    end 
    
    methods %% GET
        function b = get.blur(this)
            assert(~isempty(this.blur_));
            b = this.blur_;
        end
        function b = get.mask(this)
            assert(~isempty(this.mask_));
            b = this.mask_;
        end
    end

    methods (Static)        
        function this = load(varargin)
            %% LOAD 
            %  Usage:  this = DynamicNIfTId.load(filename[, description]); % args passed to NIfTId
            
            import mlfourd.*;            
            this = DynamicNIfTId(NIfTId.load(varargin{:}));
        end
    end
    
	methods 		  
 		function this = DynamicNIfTId(cmp, varargin)
            %% DYNAMICNIFTID 
            %  Usage:  this = DynamicNIfTId(NIfTIdecorator_object[, option-name, option-value, ...])
            %
            %          options:  'blur'            numeric 3-vector
            %                    'nifti_mask'      INIfTI
            %                    'freesurfer_mask' INIfTI, to be binarized internally
            
            this = this@mlfourd.NIfTIdecorator3(cmp);
            this = this.append_descrip('decorated by DynamicNIfTId');
            
            p = inputParser;
            addParameter(p, 'timeSum',   [], @islogical);
            addParameter(p, 'volumeSum', [], @islogical);
            addParameter(p, 'blur',      [], @isnumeric);
            addParameter(p, 'mcflirt',   [], @islogical);
            addParameter(p, 'mask',      [], @(x) isa(x, 'mlfourd.INIfTI'));
            parse(p, varargin{:});             
            
            if (~isempty(p.Results.timeSum) && p.Results.timeSum)
                this = this.timeSummed;
            end
            if (~isempty(p.Results.volumeSum) && p.Results.volumeSum)
                this = this.volumeSummed;
            end
            if (~isempty(p.Results.blur))
                this.blur_ = p.Results.blur;
                this = this.blurred;
            end
            if (~isempty(p.Results.mcflirt) && p.Results.mcflirt)
                this = this.mcflirted;
            end
            if (~isempty(p.Results.mask))
                this.mask_ = p.Results.mask;
                this = this.masked(this.mask);
            end
        end 
        function this = timeSummed(this)
            this.img = sum(this.img, 4);
            this = this.append_fileprefix('_sumt');
        end        
        function this = volumeSummed(this)
            this.img = sum(sum(sum(this.img, 1), 2), 3);
            this = this.append_fileprefix('_sumxyz');
        end
        function this = blurred(this, varargin)
            bnii = mlfourd.BlurringNIfTId(this.component_);
            bnii = bnii.blurred(varargin{:});
            this.component_ = bnii.component;
            this.blur_ = bnii.blur;
        end
        function this = mcflirted(this, varargin)
            ip = inputParser;
            addParameter('reffile', '', @ischar);
            parse(ip, varargin{:});
            
            mcffn = sprintf('%s_mcf%s', this.fqfileprefix, this.FILETYPE_EXT);
            if (isempty(ip.Results.reffile))
                system(sprintf('mcflirt -in %s -refvol %i  -meanvol -stats -mats -plots -report', this.fqfn, this.referenceVolume));
            else
                assert(lexist(ip.Results.reffile, 'file'));
                system(sprintf('mcflirt -in %s -reffile %i -meanvol -stats -mats -plots -report', this.fqfn, ip.Results.reffile));
            end
            this = this.load(mcffn);
        end
        function this = mcflirtedAfterBlur(this, varargin)
            ip = inputParser;
            addRequired( ip, 'blur',        @isnumeric);
            addParameter(ip, 'reffile', '', @ischar);
            parse(ip, varargin{:});
            
            working = this.clone;
            working = working.blurred(ip.Results.blur);
            working.save;
            
            mcffn = sprintf('%s_mcf%s', this.fqfileprefix, this.FILETYPE_EXT);
            matfn = sprintf('%s_mcf.mat', working.fqfileprefix); 
            if (lexist(matfn, 'dir'))
                rmdir(matfn, 's');
            end
            if (isempty(ip.Results.reffile))
                system(sprintf('mcflirt -in %s -refvol %i  -cost normcorr -meanvol -stats -mats -plots -report', working.fqfn, working.referenceVolume));
                system(sprintf('applyxfm4D %s %s %s %s -fourdigit', this.fqfn, this.fqfn, mcffn, matfn));
            else                
                assert(lexist(ip.Results.reffile, 'file'));
                system(sprintf('mcflirt -in %s -reffile %s -cost normcorr -meanvol -stats -mats -plots -report', working.fqfn, ip.Results.reffile));
                system(sprintf('applyxfm4D %s %s %s %s -fourdigit', this.fqfn, ip.Results.reffile, mcffn, matfn));
            end
            this = this.load(mcffn);
        end
        function this = revertFrames(this, origNiid, frames)
            %% REVERTFRAMES reverts time-frames of this DynamicNIfTId object using the time-indices of
            %  original_NIfTId_object as enumerated in frames_object.
            %  Usage:  this = this.revertFrames(original_NIfTId_object, frames_vector)
            
            assert(isa(origNiid, 'mlfourd.INIfTI'));
            assert(isnumeric(frames));
            revImg = this.img;
            origImg = origNiid.img;
            for t = 1:length(frames)
                revImg(:,:,:,frames(t)) = origImg(:,:,:,frames(t));
            end            
            this = this.makeSimilar( ...
                   'img', revImg, ...
                   'descrip', sprintf('DynamicNIfTI.revertFrames(%s)', mat2str(frames)), ...
                   'fileprefix', sprintf('_revf%ito%i', frames(1), frames(end)));
        end
        function this = masked(this, niidMask)
            %% MASKED returns this with the internal image multiplied by the passed INIfTI mask for each time sample;
            %  forked from MaskingNIfTId.masked to accomodate dynamic data.
            %  Usage:   dn = DynamicNIfTId(...)
            %           dn = dn.masked(INIfTI_mask)
            
            assert(isa(niidMask, 'mlfourd.INIfTI'));
            sz = this.size;
            assert(all(sz(1:3) == niidMask.size));
            import mlfourd.*;
            mx = MaskingNIfTId.maxall(niidMask);
            mn = MaskingNIfTId.minall(niidMask);
            if (mx > 1 || mn < 0)
                warning('mlfourd:possibleNumericalInconsistency', ...
                        'DynamicNIfTI.masked received a mask object with min->%g, max->%g', mn, mx); 
            end
            
            maskedImg = zeros(this.size);
            for t = 1:size(this, 4)
                maskedImg(:,:,:,t) = double(this.img(:,:,:,t)) .* double(niidMask.img);
            end
            this = this.makeSimilar( ...
                   'img', maskedImg, ...
                   'descrip', sprintf('DynamicNIfTI.masked(%s)', niidMask.fileprefix), ...
                   'fileprefix', '_masked');
        end
        function tidx = referenceVolume(this)
            tcurve = this.clone;
            tcurve = tcurve.volumeSummed;
            [~,tidx] = max(squeeze(tcurve.img));
        end
    end

    %% PRIVATE
    
    properties (Access = 'private')
        blur_
        mask_
    end
      
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end
