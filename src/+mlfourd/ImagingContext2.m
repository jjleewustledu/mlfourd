classdef ImagingContext2 < handle & mlfourd.IImaging
	%% IMAGINGCONTEXT2 provides the context for a state design pattern for research involving imaging.
    %
    %  INTENT.  States are behavioral objects.  Such an object alters its behaviors upon changes to its internal state.
    %  The objects will appear to change their class.  
    %
    %  MOTIVATION.  ImagingContext2 represents imaging which may be in one of various states.  Imaging may reside on a 
    %  filesystem.  It may be stored with information according to various standardized imaging formats.  It may have
    %  been loaded into random access memory and experienced operations involving blurring, manipulation of 
    %  spatiotemporal dynamics, masking or numerical transformations.  Upon receiving requests from other objects, an
    %  ImagingContext2 object responds variously depending on its current state.  For example, requests to show
    %  visualizations will differ depending on whether ImagingContext2 is in a filesystem-oriented state, a
    %  volume-oriented state, a surface-oriented state or a point-cloud-oriented state.  ImagingContext2 can exhibit
    %  differing behavior in each of its states.  Some states may be usefully conceptualized as implementing one of 
    %  various imaging manipulations tools, similarly to idioms used by apps such as Adobe Photoshop.  
    %
    %  ImagingState2 represents the state of imaging manipulation tools.  The ImagingState2 class declares an interface
    %  common to all classes that represent distinct operational states.  Subclasses of ImagingState2 implement state-
    %  specific behaviors.  For example, NiftiTool, CiftiTool, and DicomTool implement behaviors particular to 
    %  NIfTI, CIfTI, and DICOM-related states of ImagingContext2.  The class ImagingContext2 maintains a state object, 
    %  an instance of a subclass of ImagingState2, that represents the current state of ImagingContext2.  The class 
    %  ImagingContext2 delegates state-specific request to this state object. 
    %
    %  See also:  mlfourd.FilesystemTool, mlfourd.ImagingTool, mlfourd.LegacyTool, ...
    %             mlfourd.BidsTool, mlfourd.DynamicsTool, mlfourd.BlurringTool, mlfourd.MaskingTool, ...
    %             mlfourd.MatlabTool, mlfourd.PatchTool, mlfourd.PointCloudTool, mlfourd.RegistrationTool, ...
    %             mlfourd.TrivialTool.
    %
    %  See also:  Erich Gamma, et al. Design patterns : elements of reusable object-oriented software. Reading, Mass.: 
    %             Addison-Wesley, 1995.
    %
    %  N.B.:  numeq, numneq, numgt, numlt, ..., gt, lt, ..., all evaluate numerical imaging data of ImagingContext2.
    %         eq,== and neq,~= evaluate whether handles for ImagingContext2 are the same.
    %
	%  Created 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) by jjlee in repository 
    %  file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingContext2.m.
 	%  Developed on Matlab 8.1.0.604 (R2013a).  Copyright 2017 John J. Lee.

	properties (Dependent)
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        noclobber
        
        bytes
        compatibility
        json_metadata
        logger
        orient % external representation from fslorient:  RADIOLOGICAL | NEUROLOGICAL
        qfac % internal representation from this.hdr.dime.pixdim(1)
        stateTypeclass
        viewer  
    end

	methods % GET/SET
        function     set.filename(this, f)
            this.state_.filename = f;
        end
        function f = get.filename(this)
            f = this.state_.filename;
        end
        function     set.filepath(this, f)
            this.state_.filepath = f;
        end 
        function f = get.filepath(this)
            f = this.state_.filepath;
        end
        function     set.fileprefix(this, f)
            this.state_.fileprefix = f;
        end
        function f = get.fileprefix(this)
            f = this.state_.fileprefix;
        end
        function     set.filesuffix(this, f)
            this.state_.filesuffix = f;
        end
        function f = get.filesuffix(this)
            f = this.state_.filesuffix;
        end
        function     set.fqfilename(this, f)
            this.state_.fqfilename = f;
        end
        function f = get.fqfilename(this)
            f = this.state_.fqfilename;
        end
        function     set.fqfileprefix(this, f)
            this.state_.fqfileprefix = f;
        end
        function f = get.fqfileprefix(this)
            f = this.state_.fqfileprefix;
        end
        function     set.fqfn(this, f)
            this.state_.fqfn = f;
        end
        function f = get.fqfn(this)
            f = this.state_.fqfn;
        end
        function     set.fqfp(this, f)
            this.state_.fqfp = f;
        end
        function f = get.fqfp(this)
            f = this.state_.fqfp;
        end
        function     set.noclobber(this, f)
            this.state_.noclobber = f;
        end
        function f = get.noclobber(this)
            f = this.state_.noclobber;
        end

        function g = get.bytes(this)
            g = this.state_.bytes;
        end
        function g = get.compatibility(this)
            g = this.compatibility_;
        end
        function g = get.json_metadata(this)
            g = this.state_.json_metadata;
        end
        function g = get.logger(this)
            g = copy(this.state_.logger);
        end
        function g = get.orient(this)
            g = this.state_.orient;
        end
        function g = get.qfac(this)
            g = this.state_.qfac;
        end
        function g = get.stateTypeclass(this)
            g = class(this.state_);
        end
        function     set.viewer(this, s)
            assert(isa(s, 'mlfourd.IViewer'))
            this.state_.viewer = s;
        end
        function v = get.viewer(this)
            v = this.state_.viewer;
        end
    end

    methods

        %% select states

        function this = selectBidsTool(this)
            this.state_.selectBidsTool(this);
        end
        function this = selectBlurringTool(this)
            this.state_.selectBlurringTool(this);
        end
        function this = selectDynamicsTool(this)
            this.state_.selectDynamicsTool(this);
        end
        function this = selectFilesystemTool(this)
            %% saves imaging information to filesystem, then clears imaging information from memory, retaining only 
            %  filesystem information.

            % update filesystem with memory contents
            this.save;

            this.state_.selectFilesystemTool(this);
        end
        function this = selectFourdfpTool(this)
            %% mutate imaging-format state to be 4dfp

            this.selectImagingTool; % supports compatibility
            this.state_.selectFourdfpTool; % state_ returns a safe copy of fourdfp
        end
        function this = selectImagingTool(this)
            this.state_.selectImagingTool(this);
        end
        function this = selectMaskingTool(this)
            this.state_.selectMaskingTool(this);
        end
        function this = selectMatlabTool(this)
            this.state_.selectMatlabTool(this);
        end
        function this = selectMghTool(this)
            %% mutate imaging-format state to be mgz
            
            this.selectImagingTool; % supports compatibility
            this.state_.selectMghTool; % state_ returns a safe copy of nifti
        end
        function this = selectNiftiTool(this)
            %% mutate imaging-format state to be NIfTI
            
            this.selectImagingTool; % supports compatibility
            this.state_.selectNiftiTool; % state_ returns a safe copy of nifti
        end
        function this = selectPatchTool(this)
            %% supports Matlab's patch

            this.state_.selectPatchTool(this);
        end
        function this = selectPointCloudTool(this)
            %% supports Matlab's pointCloud

            this.state_.selectPointCloudTool(this);
        end
        function this = selectRegistrationTool(this)
            %% supports registration using FSL, 4dfp

            this.state_.selectRegistrationTool(this);
        end
        
        %% BidsTool

        function this = relocateToDerivativesFolder(this)
            try
                this.selectBidsTool();
                if contains(this.filepath, 'sourcedata')
                    this.filepath = strrep(this.filepath, 'sourcedata', 'derivatives');
                end
                if contains(this.filepath, 'rawdata')
                    this.filepath = strrep(this.filepath, 'rawdata', 'derivatives');
                end
            catch ME
                handwarning(ME)
            end
        end        
        function this = relocateToSourcedataFolder(this)
            try
                this.selectBidsTool();
                if contains(this.filepath, 'derivatives')
                    this.filepath = strrep(this.filepath, 'derivatives', 'sourcedata');
                end
                if contains(this.filepath, 'rawdata')
                    this.filepath = strrep(this.filepath, 'rawdata', 'sourcedata');
                end
            catch ME
                handwarning(ME)
            end
        end  

        %% FilesystemTool

        function tf   = isempty(~)
            tf = false; %%% isempty(this.state_);
        end
        function len  = length(this)
            len = length(this.state_);
        end
        function n    = ndims(this)
            n = this.state_.ndims;
        end
        function n    = numel(this)
            n = this.state_.numel;
        end 
        function s    = size(this, varargin)
            s = this.state_.size(varargin{:});
        end 

        %% MatlabTool
        
        function that = abs(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.abs;
        end
        function that = acos(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.acos(b);            
        end
        function that = acosh(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.acosh();            
        end
        function that = asin(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.asin(b);            
        end
        function that = asinh(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.asinh();            
        end
        function that = atan(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.atan(b);            
        end
        function that = atan2(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.atan2(b);            
        end
        function that = atanh(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.atanh();            
        end
        function that = bsxfun(this, pfun, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.bsxfun(pfun, b);
        end
        function that = cos(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.cos();            
        end
        function that = cosh(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.cosh();            
        end   
        function that = dice(this, b, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.dice(b, varargin{:});
        end
        function that = exp(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.exp();            
        end
        function that = expm(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.expm();            
        end
        function that = flip(this, adim)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.flip(adim);            
        end
        function that = rdivide(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.rdivide(b);
        end
        function that = ldivide(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.ldivide(b);
        end        
        function that = hypot(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.hypot(b);
        end              
        function that = jsdiv(this, b, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.jsdiv(b, varargin{:});
        end
        function that = kldiv(this, b, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.kldiv(b, varargin{:});
        end
        function [score,qualityMaps] = multissim3(this, b, varargin)
            %% Multiscale structral similarity index for image quality compared to reference this.
            %  See also: toolbox/images/images/multissim3.
            %  Usage:  [scores,qualityMaps] = this.multissim(b, 'NumScales', 8)
            %  Args:
            %      NumScales (pos int)
            %      ScaleWeights (pos vector)
            %      Sigma (pos scalar)
            %      DynamicRange (pos scalar)
            %  Returns:
            %      score: scalar value ~ 1 indicates better quality.
            %      qualityMaps: scores for every voxel, represented by cell array of ImagingContext2.

            this.selectMatlabTool;
            [score,qualityMaps] = this.state_.multissim3(b, varargin{:});
        end
        function that = log(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.log();            
        end
        function that = log10(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.log10();            
        end
        function that = logm(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.logm();            
        end
        function that = max(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.max(varargin{:});
        end
        function that = min(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.min(varargin{:});
        end
        function that = minus(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.minus(varargin{:});
        end
        function that = mod(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.mod(b);
        end
        function that = mpower(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.mpower(b);
        end
        function that = mldivide(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.mldivide(b); 
        end
        function that = mrdivide(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.mrdivide(b);         
        end
        function that = mtimes(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.mtimes(b); 
        end
        function that = plus(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.plus(b);
        end
        function that = power(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.power(b);
        end
        function that = rem(this, b)
            %% remainder after division
            
            this.selectMatlabTool;
            that = copy(this);
            that.state_.rem(b);
        end
        function that = sin(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.sin();            
        end
        function that = sinh(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.sinh();            
        end
        function that = sqrt(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.sqrt();            
        end
        function that = sqrtm(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.sqrtm();            
        end
        function that = sum(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.sum(varargin{:});            
        end
        function that = tan(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.tan();            
        end
        function that = tanh(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.tanh();            
        end
        function that = times(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.times(b);
        end
        function that = ctranspose(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.ctranspose;
        end
        function that = transpose(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.transpose;
        end        
        function that = uminus(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.uminus();
        end
        function that = usxfun(this, pfun)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.usxfun(pfun);
        end        
        
        function that = numeq(this, b)
            %% evaluates eq(this.imagingFormat.img, b).  eq(this, b) evaluates identities of handles.

            this.selectMatlabTool;
            that = copy(this);
            that.state_.numeq(b);
        end
        function that = numne(this, b)
            %% evaluates neq(this.imagingFormat.img, b).  not(eq(this, b)) evaluates identities of handles.

            this.selectMatlabTool;
            that = copy(this);
            that.state_.numne(b);
        end
        function that = numlt(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.numlt(b);
        end
        function that = numle(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.numle(b);
        end
        function that = numgt(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.numgt(b);
        end
        function that = numge(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.numge(b);
        end

        function that = lt(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.lt(b);
        end
        function that = le(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.le(b);
        end
        function that = gt(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.gt(b);
        end
        function that = ge(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.ge(b);
        end
        
        function that = and(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.and(b);
        end
        function that = isequal(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.isequal(b);
        end
        function that = isequaln(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.isequaln(b);
        end
        function tf = isfile(this)
            tf = isfile(this.fqfn);
        end
        function that = isfinite(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.isfinite;
        end
        function tf = isfolder(this)
            tf = isfolder(this.filepath);
        end
        function that = isinf(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.isinf;
        end
        function that = isnan(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.isnan;
        end
        function that = not(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.not;
        end
        function that = or(this, b)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.or(b);
        end
        function that = xor(this, b)
            that = copy(this);
            that.state_.xor(b);
        end
        
        function that = false(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.false(varargin{:});
        end
        function that = find(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.find(varargin{:});
        end
        function that = nan(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_ = this.state_.nan(varargin{:});
        end
        function that = ones(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.ones(varargin{:});
        end
        function that = reshape(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.reshape(varargin{:});
        end
        function that = scrubNanInf(this)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.scrubNanInf;
        end
        function that = true(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.true(varargin{:});
        end
        function that = zeros(this, varargin)
            this.selectMatlabTool;
            that = copy(this);
            that.state_.zeros(varargin{:});
        end
        
        function d = dipiqr(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipiqr;
        end
        function d = dipisfinite(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipisfinite;
        end
        function d = dipisinf(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipisinf;
        end
        function d = dipisnan(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipisnan;
        end
        function d = dipisreal(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipisreal;
        end
        function d = diplogprod(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.diplogprod;
        end
        function d = dipmad(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipmad;
        end        
        function d = dipmax(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipmax;
        end
        function d = dipmean(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipmean;
        end
        function d = dipmedian(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipmedian;
        end
        function d = dipmin(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipmin;
        end
        function d = dipmode(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipmode;
        end
        function d = dipprctile(this, b)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipprctile(b);
        end
        function d = dipprod(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipprod;
        end
        function d = dipquantile(this, b)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipquantile(b);
        end
        function d = dipstd(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipstd;
        end
        function d = dipsum(this)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.dipsum;
        end
        function d = diptrimmean(this, b)
            this.selectMatlabTool;
            that = copy(this);
            d = that.state_.diptrimmean(b);
        end
        
        %% BlurringTool
        
        function that = blurred(this, varargin)
            %% BLURRED
            %  @param fwhh specifies an isotropic Gaussian blurring in mm.
            %  @param [fwhh_x fwhh_y fwhh_z] \in \mathbb{R}^3 specifies an anisotropic Gaussian blurring in mm.
            %  @return the blurred image
            %  @return this if varargin{1} is empty || varargin{1} == 0.
            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            if (varargin{1} < eps);    that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.blurred(varargin{:});
        end 
        function that = bwskel(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.bwskel(varargin{:});
        end
        function that = bwperim(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.bwperim(varargin{:});
        end 
        function that = imbothat(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imbothat(varargin{:});
        end 
        function that = imclose(this, varargin)   
            %% e.g. >> mmppix = ic.imagingFormat.mmppix;
            %       >> ic = ic.imclose(strel("cuboid", 2./mmppix));

            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imclose(varargin{:});
        end 
        function that = imclose_bin(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imclose_bin(varargin{:});
        end 
        function that = imdilate(this, varargin)   
            %% e.g. >> mmppix = ic.imagingFormat.mmppix;
            %       >> ic = ic.imdilate(strel("cuboid", 2./mmppix));

            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imdilate(varargin{:});
        end 
        function that = imdilate_bin(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imdilate_bin(varargin{:});
        end 
        function that = imerode(this, varargin)
            %% e.g. ic = ic.imerode(strel("cuboid", 2)); % strel ~ 2 voxels wide

            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imerode(varargin{:});
        end 
        function that = imerode_bin(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imerode_bin(varargin{:});
        end 
        function that = imopen(this, varargin)     
            %% e.g. >> mmppix = ic.imagingFormat.mmppix;
            %       >> ic = ic.imopen(strel("cuboid", 2./mmppix));

            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imopen(varargin{:});
        end 
        function that = imopen_bin(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imopen_bin(varargin{:});
        end 
        function that = imtophat(this, varargin)            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.imtophat(varargin{:});
        end 
        
        %% DynamicsTool
        
        function that = corrcoef(this, varargin)
            %% CORRCOEF finds the corrcoef for time-series.
            %  @param mask is interpretable by the ctor and is 3D;
            %         default := fullfil(getenv(), 'gm3d.nii.gz').
            %  @param rsn_labels is interpretable by the ctor and is 3D; 
            %         default := fullfile(getenv('REFDIR'), 'Yeo2011_7Networks_333.nii.gz').
            %  See also imagesc.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.corrcoef(varargin{:});
        end
        function that = coeffvar(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.coeffvar(varargin{:});
        end
        function that = del2(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.del2(varargin{:});
        end
        function that = diff(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.diff(varargin{:});
        end
        function that = gradient(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.gradient(varargin{:});
        end
        function that = interp1(this, varargin)
            %% INTERP1
            %  Args:
            %      times0 double
            %      times1 double
            %      method {mustBeText} = "linear"
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.interp1(varargin{:});
        end
        function that = makima(this, varargin)
            %% MAKIMA
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.makima(varargin{:});
        end
        function that = mean(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.mean(varargin{:});
        end
        function that = median(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.median(varargin{:});
        end
        function that = mode(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.mode(varargin{:});
        end
        function that = pchip(this, varargin)
            %% PCHIP
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.pchip(varargin{:});
        end
        function that = Q(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.Q(varargin{:});
        end
        function that = std(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.std(varargin{:});
        end        
        function that = timeAveraged(this, varargin)
            %% Contracts imagingFormat.img in time, the trailing array index.
            %  Args:
            %      tindex (optional):  selects unique time indices\in \mathbb{N}^length(tindex); 
            %                                 e.g., [1 2 ... n] or [3 4 5   7 ... (n-1)].
            %      weights (numeric):  to multiply each time frame after selecting tindex.  Default is uniform weighting.
            %      taus (numeric):  sets weights = taus/sum(taus) after selecting tindex, replacing other requests for weights.
            %  Returns:
            %      this
            %  See also:  mlfourd.DynamicsTool.timeCensored(), mlfourd.DynamicsTool.timeContracted()
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.timeAveraged(varargin{:});
        end
        function that = timeCensored(this, varargin)
            %% Censors imagingFormat.img in time, the trailing array index.
            %  Args:
            %      tindex (optional scalar):  selects unique time indices\in \mathbb{N}^length(tindex); 
            %                                 e.g., [1 2 ... n] or [3 4 5   7 ... (n-1)].
            %  Returns:
            %      this: with censoring of times.

            this.selectDynamicsTool;
            that = copy(this);
            that.state_.timeCensored(varargin{:});
        end
        function that = timeContracted(this, varargin)     
            %% Contracts imagingFormat.img in time, the trailing array index.
            %  Args:
            %      tindex (optional scalar):  selects unique time indices\in \mathbb{N}^length(tindex); 
            %                                 e.g., [1 2 ... n] or [3 4 5   7 ... (n-1)].
            %  Returns:
            %      this: with contracted time-index.
            %  See also:  mlfourd.DynamicsTool.timeCensored()
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.timeContracted(varargin{:});
        end
        function that = timeInterleaved(this, varargin)
            %% For M-1 objects in varargin, obtain corresponding imagingFormat and img.
            %  For n in N time frames for each object:
            %      For m in M objects including this:
            %          img(:,:,:,5*(n-1) + m) = imgs{m}(:,:,:,n);

            this.selectDynamicsTool;
            that = copy(this);
            that = that.state_.timeInterleaved(varargin{:});
        end
        function that = timeShifted(this, times, Dt)
            %% Shifts imagingFormat.img forwards or backwards in time.
            %  Args:
            %      times (required numeric):  possibly nonuniform, e.g., [1 2 2.5 2.7 2.8 2.9].
            %      Dt (required scalar):  e.g., seconds.
            %  Returns: 
            %      this: shifted forwards (Dt > 0) or backwards (Dt < 0) in time.
            
            this.selectDynamicsTool;
            that = copy(this);
            that = that.state_.timeShifted(times, Dt);
        end
        function that = timeSelected(this, varargin)
            %% Selects imagingFormat.img in time, the trailing array index.  Synonym of timeCensored().
            %  Args:
            %      tindex (optional scalar):  selects unique time indices\in \mathbb{N}^length(tindex); 
            %                                 e.g., [1 2 ... n] or [3 4 5   7 ... (n-1)].
            %  Returns:
            %      this: with censoring of times.

            that = this.timeCensored(varargin{:});
        end
        function that = timeSummed(this, varargin)
            %% TIMESUMMED 
            %  @param optional closed interval T \in {\Bbb R}.
            %  @return ic := \int_T \text{this.state\_}(t).
            
            that = this.timeContracted(varargin{:});
        end
        function that = var(this, varargin)
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.var(varargin{:});
        end
        function that = volumeAveraged(this, varargin)
            %% VOLUMEAVERAGED
            %  @param optional mask specifies some closed \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t) / \int_{\Omega} \text{mask}, 
            %          mask forced to be logical.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.volumeAveraged(varargin{:});
        end
        function that = volumeContracted(this, varargin)
            %% VOLUMECONTRACTED
            %  @param optional mask specifies some closed real \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t), 
            %          mask forced to be logical.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.volumeContracted(varargin{:});
        end
        function that = volumeSummed(this, varargin)
            %% VOLUMESUMMED 
            %  @param optional mask specifies some closed real \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t).
            
            that = this.volumeContracted(varargin{:});
        end
        function that = volumeWeightedAveraged(this, varargin)
            %% VOLUMEWEIGHTEDAVERAGED
            %  @param optional weight specifies some closed real \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{weight}, t) / \int_{\Omega} \text{weight}.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.volumeWeightedAveraged(varargin{:});
        end
        function v = voxelVolume(this)
            %  Returns:
            %      v:  mm^3 ~ \muL
            
            try
                mmppix = this.imagingInfo.hdr.dime.pixdim(2:4);
                v = prod(mmppix);
            catch ME
                handwarning(ME)
                v = NaN;
            end
        end
        
        %% MaskingTool
        
        function that = binarized(this)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.binarized;
        end
        function that = binarizeBlended(this, varargin)
            %% BINARIZEBLENDED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.binarized;
            that.selectBlurringTool;
            that.state_.blurred(varargin{:});
        end
        function c    = count(this)
            this.selectMaskingTool;
            c = this.state_.count;
        end
        function that = imfill(this, varargin)
            %% IMFILL binarizes, then calls Matlab's imfill.

            this.selectMaskingTool;
            that = copy(this);
            that.state_.imfill(varargin{:});
        end
        function that = maskBlended(this, varargin)
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskBlended(varargin{:});
        end
        function that = masked(this, varargin)
            %% MASKED
            %  @param INIfTI of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.masked(varargin{:});
        end
        function that = maskedMaths(this, varargin)
            %% MASKEDMATHS
            %  @param INIfTI of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskedMaths(varargin{:});
        end
        function that = roi(this, varargin)
            that = this.zoomed(varargin{:});
        end
        function that = maskedByZ(this, varargin)
            %% MASKEDBYZ
            %  @param rng = [low-z high-z], typically equivalent to [inferior superior];
            %  @return internal image is cropped by rng.  
            %  @throws MATLAB:assertion:failed for rng out of bounds.
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskedByZ(varargin{:});
        end
        function that = thresh(this, varargin)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)
            %  @return that, the modified imaging context
            %  @return copy(this) if t == 0 or t is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.thresh(varargin{:});
        end
        function that = threshp(this, varargin)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            %  @returns that, the modified imaging context
            %  @return copy(this) if p == 0 or p is empty

            this.selectMaskingTool;
            that = copy(this);
            that.state_.threshp(varargin{:});
        end
        function that = uthresh(this, varargin)
            %% UTHRESH
            %  @param u:  use u to upper-threshold current image (zero anything above the number)
            %  @returns that, the modified imaging context
            %  @return copy(this) if u == 0 or u is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.uthresh(varargin{:});
        end
        function that = uthreshp(this, varargin)
            %% UTHRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything above the number)
            %  @returns that, the modified imaging context
            %  @return copy(this) if u == 0 or u is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.uthreshp(varargin{:});
        end        
        
        %% ImagingTool
        
        function this = addImgrec(this, varargin)
            this.selectImagingTool;
            this.state_.addImgrec(varargin{:});
        end
        function this = addJsonMetadata(this, varargin)
            %% ADDJSONMETADATA
            %  @param varargin are structs containing json metadata
            
            try
                this.state_.addJsonMetadata(varargin{:});
            catch ME
                handwarning(ME)
            end
        end
        function this = addLog(this, varargin)
            %% ADDLOG
            %  @param varargin are log entries for the imaging state
            
            try
                this.state_.addLog(varargin{:});
            catch ME
                handwarning(ME)
            end
        end
        function        ensureComplex(this)
            this.selectImagingTool;
            this.state_.ensureComplex;
        end
        function        ensureDouble(this)
            this.selectImagingTool;
            this.state_.ensureDouble;
        end
        function        ensureSaved(this)
            %% ENSURESAVED saves the imaging state as this.fqfilename on the filesystem if not already saved.
            
            if (~isfile(this.fqfilename))
                this.save;
            end
        end
        function        ensureSingle(this)
            this.selectImagingTool;
            this.state_.ensureSingle;
        end
        function ifc  = fourdfp(this)
            %% FOURDFP first ensures this object's internal imaging format to be fourdfp, then returns a safe copy of 
            %  the imaging format object.
            %  Returns:
            %      ifc (IImagingFormat): e.g., FourdfpTool.
            %      this: with state mutated to support 4dfp.

            this.selectImagingTool; % supports compatibility
            ifc = copy(this.state_.fourdfp);
        end
        function        freeview(this, varargin)
            %this.selectImagingTool;
            if ~contains(this.viewer.app, 'freeview')
                [~,r] = mlbash('which freeview');
                this.viewer = mlfourd.Viewer('app', strtrim(r));
            end
            this.view(varargin{:});
        end
        function        fsleyes(this, varargin)
            %this.selectImagingTool;
            if ~contains(this.viewer.app, 'fsleyes')
                [~,r] = mlbash('which fsleyes');
                this.viewer = mlfourd.Viewer('app', strtrim(r));
            end
            this.view(varargin{:});
        end
        function        fslview(this, varargin)
            this.fsleyes(varargin{:})
        end
        function h    = histogram(this, varargin)
            h = this.state_.histogram(varargin{:});
        end
        function h    = imagesc(this, varargin)
            this.selectImagingTool;
            h = this.state_.imagesc(varargin{:});
        end   
        function h    = imshow(this, varargin)
            this.selectImagingTool;
            h = this.state_.imshow(varargin{:});
        end
        function s    = mat2str(this, varargin)
            this.selectImagingTool;
            s = this.state_.mat2str(varargin{:});
        end 
        function ifc  = mgz(this)
            %% MGZ first ensures this object's internal imaging format to be mgz, then returns a safe copy of the
            %  imaging format object.
            %  Returns:
            %      ifc (IImagingFormat): e.g., MghTool.
            %      this: with state mutated to support mgz.

            this.selectImagingTool; % supports compatibility
            ifc = copy(this.state_.mgz);
        end
        function ifc  = nifti(this)
            %% NIFTI first ensures this object's internal imaging format to be nifti, then returns a safe copy of the
            %  imaging format object.
            %  Returns:
            %      ifc (IImagingFormat): e.g., NiftiTool.
            %      this: with state mutated to support nifti.

            this.selectImagingTool; % supports compatibility
            ifc = copy(this.state_.nifti);
        end   
        function p    = patch(this, varargin)
            %% See also web(fullfile(docroot, 'matlab/visualize/displaying-complex-three-dimensional-objects.html'))
            %  Params:
            %      thresh (scalar): per fslmaths.
            %      uthresh (scalar): per fslmaths.
            %      threshp (scalar): per fslmaths.
            %      uthreshp (scalar): per fslmaths.
            %      isovalue (scalar): specify volume data equal to isovalue.
            %      EdgeColor (color): default 'none'.
            %      FaceAlpha (scalar): transparency < 1.
            %      FaceColor (color): default [0.5 0.5 0.5].
            %      LightPosition (vector): default [-0.4, 0.2, 0.9].
            %      lighting (text): 'gouraud' (default), 'flat' or 'none'.
            %      LineStyle (text)
            %      material (text): 'shiny' (default), 'metal', 'dull' or 'default'.
            %      use_isonormals (logical): works best for smoooth data, default false.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'thresh', [], @isscalar)
            addParameter(ip, 'uthresh', [], @isscalar)
            addParameter(ip, 'threshp', [], @isscalar)
            addParameter(ip, 'uthreshp', [], @isscalar)
            parse(ip, varargin{:})
            ipr = ip.Results;            
            if ~isempty(ipr.thresh)
                this = this.thresh(ipr.thresh);
            end
            if ~isempty(ipr.uthresh)
                this = this.uthresh(ipr.uthresh);
            end
            if ~isempty(ipr.threshp)
                this = this.threshp(ipr.threshp);
            end
            if ~isempty(ipr.uthreshp)
                this = this.uthreshp(ipr.uthreshp);
            end
            
            this.selectPatchTool;
            p = this.state_.patch(varargin{:});
        end
        function p    = pcshow(this, varargin)
            %% passes all varargin to this.pointCloud()

            this.selectPointCloudTool;
            try
                p = this.state_.pcshow(varargin{:});
            catch ME
                handwarning(ME)
                this.view();
            end
        end
        function p    = pointCloud(this, varargin)
            %% See also web(fullfile(docroot, 'vision/ug/3-d-point-cloud-registration-and-stitching.html'))
            %  and web(fullfile(docroot, 'vision/ref/pointcloud.html#mw_eb949323-5b82-4b6c-8239-a8886734b790'))
            %  Params:
            %      thresh (scalar): per fslmaths.
            %      uthresh (scalar): per fslmaths.
            %      threshp (scalar): per fslmaths.
            %      uthreshp (scalar): per fslmaths.
            %      addNormals (logical): default false.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'thresh', [], @isscalar)
            addParameter(ip, 'uthresh', [], @isscalar)
            addParameter(ip, 'threshp', [], @isscalar)
            addParameter(ip, 'uthreshp', [], @isscalar)
            parse(ip, varargin{:})
            ipr = ip.Results;            
            if ~isempty(ipr.thresh)
                this = this.thresh(ipr.thresh);
            end
            if ~isempty(ipr.uthresh)
                this = this.uthresh(ipr.uthresh);
            end
            if ~isempty(ipr.threshp)
                this = this.threshp(ipr.threshp);
            end
            if ~isempty(ipr.uthreshp)
                this = this.uthreshp(ipr.uthreshp);
            end
            
            this.selectPointCloudTool;
            p = this.state_.pointCloud(varargin{:});
        end
        function r    = rank(this)
            r = ndims(this);
        end
        function        save(this, varargin)
            %% SAVE saves the imaging state as this.fqfilename on the filesystem.
            
            this.selectImagingTool;
            save(this.state_, varargin{:});
        end
        function this = saveas(this, varargin)
            %% SAVEAS saves the imaging state as this.fqfilename on the filesystem.
            %  Args:
            %      filename (text): is compatible with requirements of the filesystem;
            %  Returns:
            %      this for compatibility with non-handle interfaces,
            %      replacing internal filename & filesystem information.

            this.selectImagingTool;
            this.state_ = this.state_.saveas(varargin{:});
        end  
        function [s,r] = save_qc(this, varargin)
            %% SAVE_QC saves additional imaging with alpha < 1 and non-gray colormap overlaid on this anatomy.
            %  Preview saved qc with view_qc().
            %  Args:
            %      varargin (any): are additional filenames and additional mlio.IOInterface objects to pass to the 
            %                      viewer.  Viewing options may precede/follow filenames/objects.  
            %                      Viewers will access tempfiles of what is active in memory.
            %  Returns:
            %      s: system status.
            %      r: system result.            

            this.selectImagingTool;
            [s,r] = this.state_.save_qc(varargin{:});
        end              
        function        setPointCloud(this, varargin)
            %  Args:
            %      pc (pointCloud)
            %      filepath (folder)
            %      fileprefix (text):  Ignores common file extensions.
            %                          Default := strcat(this.fileprefix, '_setPointCloud').

            this.selectPointCloudTool;
            this.state_.setPointCloud(varargin{:});
        end
        function tf   = sizeEq(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for equal size

            this.selectImagingTool;
            tf = this.state_.sizeEq(ic);
        end
        function tf   = sizeGt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for > size

            this.selectImagingTool;
            tf = this.state_.sizeGt(ic);
        end
        function tf   = sizeLt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for < size

            this.selectImagingTool;
            tf = this.state_.sizeLt(ic);
        end
        function [s,r] = view(this, varargin)
            %% VIEW views this imaging.
            %  Args:
            %      varargin (any): are additional filenames and additional mlio.IOInterface objects to pass to the 
            %                      viewer.  Viewers will access tempfiles of what is active in memory.
            %  Returns:
            %      s: system status.
            %      r: system result.
            
            [s,r] = this.state_.view(varargin{:});
        end
        function [s,r] = view_qc(this, varargin)
            %% VIEW_QC views additional imaging with alpha < 1 and non-gray colormap overlaid on this anatomy.
            %  Args:
            %      varargin (any): are additional filenames and additional mlio.IOInterface objects to pass to the 
            %                      viewer.  Viewing options may precede/follow filenames/objects.  
            %                      Viewers will access tempfiles of what is active in memory.
            %  Returns:
            %      s: system status.
            %      r: system result.            

            try
                this.selectImagingTool;
                [s,r] = this.state_.view_qc(varargin{:});
            catch ME
                handwarning(ME)
                [s,r] = this.view(varargin{:});
            end
        end

        %% RegistrationTool
        
        function this = afni_3dresample(this)
            this.selectRegistrationTool();
            this.state_.afni_3dresample();
        end
        function this = forceneurological(this)
            this.selectRegistrationTool();
            this.state_.forceneurological();
        end
        function this = forceradiological(this)
            this.selectRegistrationTool();
            this.state_.forceradiological();
        end
        function that = zoomed(this, varargin)
            %% ZOOMED is an adapter to FSL executables.
            %  N.B.: indexing (in both time and space) starts with 0 not 1! 
            %  N.B.: Inputting -1 for a size will set it to the full image extent for that dimension.
            %
            %  @param xmin|fac is required.  Solitary fac symmetrically sets Euclidean spatial size := fac*size
            %                  and symmetrically sets all min.
            %  @param xsize is optional.
            %  @param ymin  is optional.
            %  @param ysize is optional.
            %  @param zmin  is optional.
            %  @param zsize is optional.
            %  @param tmin  is optional.  Solitary tmin with tsize is supported.
            %  @param tsize is optional

            that = copy(this);
            that.selectNiftiTool();
            save(that);
            that.selectRegistrationTool();
            that.state_.fslroi(varargin{:});
            that.selectNiftiTool();
        end
        function this = reorient2std(this)
            this.selectRegistrationTool();
            this.state_.reorient2std();
        end
        function this = swaporient(this)
            this.selectRegistrationTool();
            this.state_.swaporient();
        end

        %%
        
        function c = char(this, varargin)
            c = char(this.state_, varargin{:});
        end
        function d = complex(this)
            this.selectImagingTool();
            d = complex(this.state_);
        end  
        function d = double(this)
            this.selectImagingTool();
            d = double(this.state_);
        end        
        function tf = haveDistinctStates(this, that)
            %  Args:
            %      that (ImagingContext2): with distinct state.

            tf = this.state_ ~= that.state_;
        end
        function tf = haveDistinctContextHandles(this, that)
            %  Args:
            %      that (ImagingContext2): with distinct context handle, used by state to access its context

            tf = haveDistinctContextHandles(this.state_, that.state_);
        end
        function imgi = imagingInfo(this)
            this.selectImagingTool(); 
            imgi = copy(this.state_.imagingInfo());
        end
        function imgf = imagingFormat(this)
            imgf = copy(this.state_.imagingFormat());
        end
        function d = int8(this)
            this.selectImagingTool();
            d = int8(this.state_);
        end
        function d = int16(this)
            this.selectImagingTool();
            d = int16(this.state_);
        end
        function d = int32(this)
            this.selectImagingTool();
            d = int32(this.state_);
        end
        function d = int64(this)
            this.selectImagingTool();
            d = int64(this.state_);
        end
        function l = logical(this)
            this.selectImagingTool();
            l = logical(this.state_);
        end        
        function s = single(this)
            this.selectImagingTool();
            s = single(this.state_);
        end
        function s = string(this, varargin)
            s = string(this.state_, varargin{:});
        end
        function d = uint8(this)
            this.selectImagingTool();
            d = uint8(this.state_);
        end
        function d = uint16(this)
            this.selectImagingTool();
            d = uint16(this.state_);
        end
        function d = uint32(this)
            d = uint32(this.state_);
        end
        function d = uint64(this)
            this.selectImagingTool();
            d = uint64(this.state_);
        end

        function this = ImagingContext2(imgobj, varargin)
            %  Args:
            %      imgobj (any): contains any imaging, such as [], numeric objects, filenames, another ImagingContext2
            %                    for copy-construction or any object supported by stateful ImagingTool ~ ImagingState2.
            
            import mlfourd.*;

            if 0 == nargin || isempty(imgobj)
                % must support empty ctor
                this.state_ = TrivialTool(this);
                return
            end

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'imgobj')
            addParameter(ip, 'compatibility', false, @islogical)
            parse(ip, imgobj, varargin{:})
            ipr = ip.Results;
            this.compatibility_ = ipr.compatibility; % KLUDGE, for refactoring

            if isa(ipr.imgobj, 'mlfourd.ImagingContext2')
                % copy ctor
                this = copy(ipr.imgobj);
                return
            end
            if isa(ipr.imgobj, 'mlfourd.ImagingFormatContext') || ...
               isa(ipr.imgobj, 'mlfourd.ImagingContext')
                % legacy
                this = LegacyTool.create(this, ipr.imgobj, varargin{:});
                return
            end
            if isnumeric(ipr.imgobj) || islogical(ipr.imgobj)
                this.state_ = MatlabTool(this, ipr.imgobj, varargin{:});
                return
            end
            if istext(ipr.imgobj)
                this.state_ = FilesystemTool(this, ipr.imgobj, varargin{:});
                return
            end
            this.state_ = ImagingTool(this, ipr.imgobj, varargin{:});
        end
    end  
    
    %% PROTECTED
    
    properties (Access = protected)
        compatibility_ % KLUDGE, for refactoring
        state_
    end 
    
    methods (Access = protected)
        function that = copyElement(this)
            that = copyElement@matlab.mixin.Copyable(this);
            that.state_ = copy(this.state_);
            that.state_.contexth_ = that;
        end
    end
        
    %% HIDDEN   

	methods (Hidden)
        function changeState(this, s)
            %  Args:
            %      s (ImagingState2): state which is requesting state transition.
            
            %assert(isa(s, 'mlfourd.ImagingState2'))
            this.state_ = s;
        end
    end
    
    %% DEPRECATED
    
    properties (Hidden)
        verbosity = 0;
    end
    
    methods (Hidden)
        function that = clone(this)
            %% @deprecated

            that = copy(this);
        end
        function ifc = niftid(this)
            %% @deprecated

            this.selectImagingTool;
            ifc = this.nifti;
        end
        function ifc = numericalNiftid(this)
            %% @deprecated

            this.selectMatlabTool;
            ifc = this.nifti;
        end
    end  
        
    methods (Hidden, Static)
        function im = imagingType(typ, obj)
            im = imagingType(typ, obj);
        end
        function loc = locationType(typ, loc0)
            loc = locationType(typ, loc0);
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

