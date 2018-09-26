classdef VoxelResampler < mlfourd.AbstractResampler
	%% VOXELRESAMPLER  

	%  $Revision$
 	%  was created 17-Jun-2018 15:26:32 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
        preferredBlur
    end
    
    properties (Dependent)
        dynamic
        filepath
        filename
        fileprefix
        filesuffix
        fqfilename
        fqfileprefix
        img
        mask
    end
    
    methods (Static)
        function this = constructSampledScanner(s, varargin)
            import mlfourd.*;
            sa = s.component;
            sa.img = s.specificActivity;
            this = VoxelResampler( ...
                'dynamic', ImagingContext(sa), ...
                'mask', ImagingContext(s.mask), ...
                varargin{:});
        end
    end

	methods 
    
        %% GET/SET
        
        function g = get.dynamic(this)
            g = this.dynamic_;
        end
        function g = get.filepath(this)
            g = this.dynamic_.filepath;
        end
        function this = set.filepath(this, s)
            this.dynamic_.filepath = s;
        end
        function g = get.filename(this)
            g = this.dynamic_.filename;
        end
        function this = set.filename(this, s)
            this.dynamic_.filename = s;
        end
        function g = get.fileprefix(this)
            g = this.dynamic_.fileprefix;
        end
        function this = set.fileprefix(this, s)
            this.dynamic_.fileprefix = s;
        end
        function g = get.filesuffix(this)
            g = this.dynamic_.filesuffix;
        end
        function this = set.filesuffix(this, s)
            this.dynamic_.filesuffix = s;
        end
        function g = get.fqfileprefix(this)
            g = this.dynamic_.fqfileprefix;
        end
        function this = set.fqfilename(this, s)
            this.dynamic_.fqfilename = s;
        end
        function g = get.img(this)
            g = this.dynamic.niftid.img;
        end
        function this = set.img(this, s)
            assert(isnumeric(s));
            d = this.dynamic;
            d = d.niftid;
            d.img = s;
            this.dynamic_ = mlfourd.ImagingContext(d);
        end
        function g = get.mask(this)
            g = this.mask_;
        end
        
        %%
        
        function this = downsample(this)
            this.reference_ = this.mask_;
            this.dynamic_   = this.downsampleIC(this.dynamic_);
            this.mask_      = this.downsampleIC(this.mask_);
        end  
        function r    = ndims(this)
            r = ndims(this.dynamic_.niftid);
        end
        function this = upsample(this)
            assert(~isempty(this.dynamic_));
            assert(~isempty(this.mask_));
            assert(~isempty(this.reference_));
            this.dynamic_ = this.upsampleIC(this.dynamic_, this.reference_);
            this.mask_    = this.upsampleIC(this.mask_,    this.reference_);
        end
		  
 		function this = VoxelResampler(varargin)
 			%% VOXELRESAMPLER
 			%  @param named dynamic is mlfourd.IC.
            %  @param named mask    is mlfourd.IC.
            %  @param named doEnlargeMask is logical.
            %  @param named blur is numeric; default is this.preferredBlur.

 			this = this@mlfourd.AbstractResampler(varargin{:});
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'dynamic', @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(ip, 'mask',    @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(ip, 'doEnlargeMask', @islogical)
            addParameter(ip, 'blur', 0, @isnumeric);
            addParameter(ip, 'fileprefix', tmpFileprefix, @ischar);
            parse(ip, varargin{:});
            this.dynamic_ = ip.Results.dynamic;
            if (~isempty(this.dynamic_))
                this.dynamic_.fileprefix = ip.Results.fileprefix;
            end
            this.mask_ = ip.Results.mask;
            this.preferredBlur = ip.Results.blur;
            if (this.preferredBlur > 0)
                this.dynamic_ = this.dynamic_.blurred(this.preferredBlur);
                this.mask_ = this.enlargeMask(this.mask_);
            end
 		end
    end 
    
    % PROTECTED
    
    properties (Access = protected)
        dynamic_
        mask_
        reference_
    end
    
    methods (Access = protected)        
        function ic   = downsampleIC(this, ic)
            %  @param ic    is an mlfourd.ImagingContext.
            
            ic = mlfourd.ImagingContext(this.downsampleNii(ic.niftid));
        end
        function nii  = downsampleNii(~, nii)
            assert(isa(nii, 'mlfourd.INIfTI'), ...
                'mlfourd:unsupportedTypeclass', 'class(VoxelResampler.downsampleNii.nii)->%s', class(nii));
            
            nii.filesuffix = '.nii.gz';
            nii.save;
            fqfnDown = [nii.fqfileprefix '_downsmpl.nii.gz'];
            mlbash(sprintf( ...
                'flirt -interp nearestneighbour -in %s -ref %s -out %s -nosearch -applyisoxfm 4', ...
                nii.fqfilename, nii.fqfilename, fqfnDown));
            nii = mlfourd.NIfTId.load(fqfnDown);           
        end
        function m    = enlargeMask(this, m, varargin)
            %% ENLARGEMASK blurs and binarizes.
            %  @param m is an mlfourd.ImagingContext.
            %  @param optional blur is numeric; default is this.preferredBlur.
            %  @return m is an mlfourd.ImagingContext.
            
            ip = inputParser;
            addRequired(ip, 'm', @(x) isa(x, 'mlfourd.ImagingContext'));
            addOptional(ip, 'blur', this.preferredBlur, @isnumeric);
            parse(ip, m, varargin{:});
            
            m = m.blurred(ip.Results.blur);
            m = m.binarized;
        end
        function ic   = upsampleIC(this, ic, icRef)
            %  @param ic    is an mlfourd.ImagingContext.
            %  @param icRef is an mlfourd.ImagingContext and provides the ref to flirt.
            
            assert(isa(ic,    'mlfourd.ImagingContext'));
            assert(isa(icRef, 'mlfourd.ImagingContext'));

            ic = mlfourd.ImagingContext(this.upsampleNii(ic.niftid, icRef.niftid));
        end
        function nii  = upsampleNii(~, nii, niiRef)
            assert(isa(nii, 'mlfourd.INIfTI'), ...
                'mlfourd:unsupportedTypeclass', 'class(VoxelResampler.upsampleNii.nii)->%s', class(nii));
            assert(isa(niiRef, 'mlfourd.INIfTI'), ...
                'mlfourd:unsupportedTypeclass', 'class(VoxelResampler.upsampleNii.niiRef)->%s', class(niiRef));
            
            nii.filesuffix = '.nii.gz';
            nii.save;
            fqfnNative = [nii.fqfileprefix '_native.nii.gz'];
            niiRef.filesuffix = '.nii.gz';
            niiRef.save;
            mlbash(sprintf( ...
                'flirt -interp trilinear -in %s -ref %s -out %s -nosearch -applyxfm', ...
                nii.fqfilename, niiRef.fqfilename, fqfnNative));
            nii = mlfourd.NIfTId.load(fqfnNative);          
        end  
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

