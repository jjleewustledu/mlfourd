classdef ImagingContext2 < handle & matlab.mixin.Copyable & mlfourd.HandleNIfTIIO
	%% ImagingContext2 is the context and AbstractImagingTool is the state forming a state design pattern for imaging
    %  tools.  It's intent is to improve the expressivity of tools for imaging objects, much as state-dependent tools
    %  for editing graphical objects improve expressivity of grpahics workflows.  See also AbstactImagingTool.
    
	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingContext2.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a).  Copyright 2017 John Joowon Lee.
 	%  $Id: ImagingContext2.m 2627 2013-09-16 06:18:10Z jjlee $ 
    
    properties (Constant)
        IMAGING_TYPES  = { ...
            'ext' ...
            'fileprefix' 'filename' 'fqfileprefix' 'fqfilename' 'fp' 'fn' 'fqfp' 'fqfn' ...
            'ImagingContext2' 'mlfourd.ImagingContext2' ...
            'mgh' 'mgz' ...
            'nii' 'nii.gz' ...
            'v' 'v.hdr' 'v.mhdr' 'mhdr' ...
            '4dfp.hdr' '4dfp.ifh' '4dfp.img' '4dfp.img.rec' ...
            '.4dfp.hdr' '.4dfp.ifh' '.4dfp.img' '.4dfp.img.rec' ...
            'mrImagingContext' 'mlmr.MRImagingContext' 'petImagingContext' 'mlpet.PETImagingContext' ...
            'folder' 'path'}
    end
    
    properties 
        verbosity = 0;
    end
    
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
        
        imagingInfo
        imgrec
        innerTypeclass
        logger
        viewer
        
        stateTypeclass
    end
    
    methods (Static)
        
        %% Typeclass utilities
        
        function im   = imagingType(typ, obj)
            %% IMAGINGTYPE returns imaging data cast as a requested representative type detailed below.
            %  @param typ is the requested representation:  'filename', 'fn', fqfilename', 'fqfn', 'fileprefix', 'fp',
            %  'fqfileprefix', 'fqfp', 'folder', 'path', 'ext', 'ImagingContext2', 
            %  '4dfp.hdr', '4dfp.ifh', '4dfp.img', '4dfp.img.rec', 'v', 'v.hdr', 'v.mhdr'. 
            %  @param obj is the representation of imaging data provided by the client.  
            %  @returns im is the imaging data obj cast as the requested representation.
            %  See also mlfourd.ImagingContext2
            
            import mlfourd.*;
            if (ischar(obj) && isdir(obj))
                im = ImagingContext2.locationType(typ, obj);
                return
            end
            
            obj = ImagingContext2(obj);
            switch (typ)
                case {'4dfp.hdr' '.4dfp.hdr'}
                    im = [obj.fqfileprefix '.4dfp.hdr'];
                case {'4dfp.ifh' '.4dfp.ifh'}
                    im = [obj.fqfileprefix '.4dfp.ifh'];
                case {'4dfp.img' '.4dfp.img'}
                    im = [obj.fqfileprefix '.4dfp.img'];
                case {'4dfp.img.rec' '.4dfp.img.rec'}
                    im = [obj.fqfileprefix '.4dfp.img.rec'];
                case  'ext'
                    [~,~,im] = myfileparts(obj.filename);
                case  'folder'
                    [~,im] = fileparts(obj.filepath);
                case {'filepath' 'path'}
                    im = obj.filepath;
                case {'fileprefix' 'fp'}
                    im = obj.fileprefix;
                case {'filename' 'fn'}
                    im = obj.filename;
                case {'fn.4dfp.hdr'}
                    im = [obj.fileprefix '.4dfp.hdr'];
                case {'fn.4dfp.ifh'}
                    im = [obj.fileprefix '.4dfp.ifh'];
                case {'fn.4dfp.img'}
                    im = [obj.fileprefix '.4dfp.img'];
                case {'fn.4dfp.img.rec'}
                    im = [obj.fileprefix '.4dfp.img.rec'];
                case {'fn.mgz'}
                    im = [obj.fileprefix '.mgz'];
                case {'fn.mhdr'}
                    im = [obj.fileprefix '.mhdr'];
                case {'fn.nii'}
                    im = [obj.fileprefix '.nii'];
                case {'fn.nii.gz'}
                    im = [obj.fileprefix '.nii.gz'];
                case {'fn.v'}
                    im = [obj.fileprefix '.v'];
                case {'fn.v.hdr'}
                    im = [obj.fileprefix '.v.hdr'];
                case {'fn.v.mhdr'}
                    im = [obj.fileprefix '.v.mhdr'];
                case {'fourdfp' 'Fourdfp' 'mlfourdfp.Fourdfp'}
                    im = obj.fourdfp;
                case {'fqfilename' 'fqfn'}
                    im = obj.fqfilename;
                case {'fqfileprefix' 'fqfp' 'fdfp' '4dfp'}
                    im = obj.fqfileprefix;
                case {'ImagingContext' 'mlfourd.ImagingContext'}
                    im = mlfourd.ImagingContext(obj);
                case {'ImagingContext2' 'mlfourd.ImagingContext2'}
                    im = mlfourd.ImagingContext2(obj);
                case {'mgz' '.mgz'}
                    im = [obj.fqfileprefix '.mgz'];
                case {'mhdr' '.mhdr'}
                    im = [obj.fqfileprefix '.mhdr'];                  
                case {'nii' '.nii'}
                    im = [obj.fqfileprefix '.nii'];
                case {'nii.gz' '.nii.gz'}
                    im = [obj.fqfileprefix '.nii.gz'];
                case {'mgh' 'MGH' 'mlsurfer.MGH'}
                    im = obj.mgh;
                case {'nifti' 'NIfTI'}
                    im = obj.nifti;
                case {'niftid' 'NIfTId' 'mlfourd.NIfTId'}
                    im = obj.niftid;
                case {'numericalNiftid' 'NumericalNIfTId' 'mlfourd.NumericalNIfTId'}
                    im = obj.numericalNiftid;
                case {'v' '.v'}
                    im = [obj.fqfileprefix '.v'];
                case {'v.hdr' '.v.hdr'}
                    im = [obj.fqfileprefix '.v.hdr'];
                case {'v.mhdr' '.v.mhdr'}
                    im = [obj.fqfileprefix '.v.mhdr'];
                otherwise
                    error('mlfourd:insufficientSwitchCases', ...
                          'ImagingContext2.imagingType.obj->%s not recognized', obj);
            end
        end
        function tf   = isImagingType(t)
            tf = lstrcmp(t, mlfourd.ImagingContext2.IMAGING_TYPES);
        end
        function tf   = isLocationType(t)
            tf = lstrcmp(t, {'folder' 'path'});
        end
        function loc  = locationType(typ, loc0)
            %% LOCATIONTYPE returns location data cast as a requested representative type detailed below.
            %  @param typ is the requested representation:  'folder', 'path'.
            %  @param loc0 is the representation of location data provided by the client.  
            %  @returns loc is the location data loc0 cast as the requested representation.
            
            assert(ischar(loc0));
            switch (typ)
                case 'folder'
                    [~,loc] = fileparts(loc0);
                case 'path'
                    loc = loc0;
                otherwise
                    error('mlfourd:insufficientSwitchCases', ...
                          'ImagingContext2.locationType.loc0->%s not recognized', loc0);
            end
        end
    end
    
	methods
        
        %% GET/SET
        
        function f = get.filename(this)
            f = this.state_.filename;
        end
        function f = get.filepath(this)
            f = this.state_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.state_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.state_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.state_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.state_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.state_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.state_.fqfp;
        end
        function g = get.imagingInfo(this)
            g = this.state_.imagingInfo;
        end
        function f = get.imgrec(this)
            f = this.state_.imgrec;
        end
        function g = get.innerTypeclass(this)
            g = this.state_.innerTypeclass;
        end 
        function f = get.logger(this)
            f = this.state_.logger;
        end
        function f = get.noclobber(this)
            f = this.state_.noclobber;
        end
        function c = get.stateTypeclass(this)
            c = class(this.state_);
        end
        function v = get.viewer(this)
            v = this.state_.viewer;
        end
        
        function set.filename(this, f)
            this.state_.filename = f;
        end
        function set.filepath(this, f)
            this.state_.filepath = f;
        end        
        function set.fileprefix(this, f)
            this.state_.fileprefix = f;
        end        
        function set.filesuffix(this, f)
            this.state_.filesuffix = f;
        end        
        function set.fqfilename(this, f)
            this.state_.fqfilename = f;
        end        
        function set.fqfileprefix(this, f)
            this.state_.fqfileprefix = f;
        end        
        function set.fqfn(this, f)
            this.state_.fqfn = f;
        end        
        function set.fqfp(this, f)
            this.state_.fqfp = f;
        end
        function set.noclobber(this, f)
            this.state_.noclobber = f;
        end        
        function set.viewer(this, v)
            assert(ischar(v));
            this.state_.viewer = v;
        end
        
        %% various casting of mlfourd.ImagingFormatContext
        
        function ifc = fourdfp(this)
            this.selectImagingFormatTool;
            ifc = this.state_.fourdfp;
        end
        function ifc = mgh(this)
            this.selectImagingFormatTool;
            ifc = this.mgz;
        end
        function ifc = mgz(this)
            this.selectImagingFormatTool;
            ifc = this.state_.mgz;
        end
        function ifc = nifti(this)
            this.selectImagingFormatTool;
            ifc = this.state_.nifti;
        end
        
        %% select states
        
        function this = selectBlurringTool(this)
            this.state_.selectBlurringTool(this);
        end
        function this = selectDynamicsTool(this)
            this.state_.selectDynamicsTool(this);
        end
        function this = selectFilesystemTool(this)
            this.state_.selectFilesystemTool(this);
        end
        function this = selectIsNumericTool(this)
            this.state_.selectIsNumericTool(this);
        end
        function this = selectImagingFormatTool(this)
            this.state_.selectImagingFormatTool(this);
        end
        function this = selectMaskingTool(this)
            this.state_.selectMaskingTool(this);
        end
        function this = selectNumericalTool(this)
            this.state_.selectNumericalTool(this);
        end
        function this = selectRegistrationTool(this)
            this.state_.selectRegistrationTool(this);
        end    
        
        %% mlpatterns.HandleNumerical
        
        function that = abs(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.abs;
        end
        function that = atan2(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.atan2(b);            
        end
        function that = bsxfun(this, pfun, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.bsxfun(pfun, b);
        end
        function that = flip(this, adim)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.flip(adim);            
        end
        function that = rdivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.rdivide(b);
        end
        function that = ldivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ldivide(b);
        end
        function that = hypot(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.hypot(b);
        end
        function that = max(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.max(b);
        end
        function that = min(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.min(b);
        end
        function that = minus(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.minus(b);
        end
        function that = mod(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mod(b);
        end
        function that = mpower(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mpower(b);
        end
        function that = mldivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mldivide(b); 
        end
        function that = mrdivide(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mrdivide(b);         
        end
        function that = mtimes(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.mtimes(b); 
        end
        function that = plus(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.plus(b);
        end
        function that = power(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.power(b);
        end
        function that = rem(this, b)
            %% remainder after division
            
            this.selectNumericalTool;
            that = copy(this);
            that.state_.rem(b);
        end
        function that = times(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.times(b);
        end
        function that = ctranspose(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ctranspose;
        end
        function that = transpose(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.transpose;
        end
        function that = usxfun(this, pfun)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.usxfun(pfun);
        end        
        
        function that = eq(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.eq(b);
        end
        function that = ne(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ne(b);
        end
        function that = lt(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.lt(b);
        end
        function that = le(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.le(b);
        end
        function that = gt(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.gt(b);
        end
        function that = ge(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ge(b);
        end
        function that = and(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.and(b);
        end
        function that = or(this, b)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.or(b);
        end
        function that = xor(this, b)
            that = copy(this);
            that.state_.xor(b);
        end
        function that = not(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.not;
        end
        
        function that = false(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.false(varargin{:});
        end
        function that = nan(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_ = this.state_.nan(varargin{:});
        end
        function that = ones(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.ones(varargin{:});
        end
        function that = scrubNanInf(this)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.scrubNanInf;
        end
        function that = true(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.true(varargin{:});
        end
        function that = zeros(this, varargin)
            this.selectNumericalTool;
            that = copy(this);
            that.state_.zeros(varargin{:});
        end
        
        %% mlpatterns.HandleDipNumerical
         
        function d = dipiqr(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipiqr;
        end
        function d = dipisfinite(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisfinite;
        end
        function d = dipisinf(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisinf;
        end
        function d = dipisnan(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisnan;
        end
        function d = dipisreal(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipisreal;
        end
        function d = diplogprod(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.diplogprod;
        end
        function d = dipmad(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmad;
        end        
        function d = dipmax(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmax;
        end
        function d = dipmean(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmean;
        end
        function d = dipmedian(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmedian;
        end
        function d = dipmin(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmin;
        end
        function d = dipmode(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipmode;
        end
        function d = dipprctile(this, b)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipprctile(b);
        end
        function d = dipprod(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipprod;
        end
        function d = dipquantile(this, b)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipquantile(b);
        end
        function d = dipstd(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipstd;
        end
        function d = dipsum(this)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.dipsum;
        end
        function d = diptrimmean(this, b)
            this.selectNumericalTool;
            that = copy(this);
            d = that.state_.diptrimmean(b);
        end
        
        %% BlurringTool
        
        function that = blurred(this, varargin)
            %% BLURRED
            %  @param fwhh specifies an isotropic Gaussian blurring.
            %  @param [fwhh_x fwhh_y fwhh_z] \in \mathbb{R}^3 specifies an anisotropic Gaussian blurring.
            %  @return the blurred image
            %  @return this if varargin{1} is empty || varargin{1} == 0.
            
            if (isempty(varargin));    that = this; return; end
            if (isempty(varargin{1})); that = this; return; end
            if (varargin{1} < eps);    that = this; return; end
            this.selectBlurringTool;
            that = copy(this);
            that.state_.blurred(varargin{:});
        end 
        
        %% DynamicsTool
        
        function that = volumeAveraged(this, varargin)
            %% VOLUMEAVERAGED
            %  @param optional mask specifies some closed \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t) / \int_{\Omega} \text{mask}.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.volumeAveraged(varargin{:});
        end
        function that = volumeContracted(this, varargin)
            %% VOLUMECONTRACTED
            %  @param optional mask specifies some closed \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t).
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.volumeContracted(varargin{:});
        end
        function that = volumeSummed(this, varargin)
            %% VOLUMESUMMED 
            %  @param optional mask specifies some closed \Omega \in {\Bbb R}^3.
            %  @return that := \int_{\Omega} \text{this.state\_} (\text{mask}, t).
            
            that = this.volumeContracted(varargin{:});
        end
        function that = timeAveraged(this, varargin)
            %% TIMEAVERAGED
            %  @param optional closed interval T \in {\Bbb R}.
            %  @return ic := \int_T \text{this.state\_}(t) / \int_T.
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.timeAveraged(varargin{:});
        end
        function that = timeContracted(this, varargin)
            %% TIMECONTRACTED
            %  @param optional closed interval T \in {\Bbb R}.
            %  @return ic := \int_T this.state_(t).
            
            this.selectDynamicsTool;
            that = copy(this);
            that.state_.timeContracted(varargin{:});
        end
        function that = timeSummed(this, varargin)
            %% TIMESUMMED 
            %  @param optional closed interval T \in {\Bbb R}.
            %  @return ic := \int_T \text{this.state\_}(t).
            
            that = this.timeContracted(varargin{:});
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
        function that = maskBlended(this, varargin)
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskBlended(varargin{:});
        end
        function that = masked(this, varargin)
            %% MASKED
            %  @param INIfTId of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.masked(varargin{:});
        end
        function that = maskedMaths(this, varargin)
            %% MASKEDMATHS
            %  @param INIfTId of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.maskedMaths(varargin{:});
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
        function that = msktgen(this, varargin)
            this.selectMaskingTool;
            that = copy(this);
            that.state_.msktgen(varargin{:});
        end
        function that = roi(this, varargin)
            that = this.zoomed(varargin{:});
        end
        function that = thresh(this, varargin)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)
            %  @return t, the modified imaging context
            %  @return copy(this) if t == 0 or t is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.thresh(varargin{:});
        end
        function that = threshp(this, varargin)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            %  @returns p, the modified imaging context
            %  @return copy(this) if p == 0 or p is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.threshp(varargin{:});
        end
        function that = uthresh(this, varargin)
            %% UTHRESH
            %  @param u:  use t to upper-threshold current image (zero anything above the number)
            %  @returns u, the modified imaging context
            %  @return copy(this) if u == 0 or u is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.uthresh(varargin{:});
        end
        function that = uthreshp(this, varargin)
            %% UTHRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything above the number)
            %  @returns p, the modified imaging context
            %  @return copy(this) if u == 0 or u is empty
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.uthreshp(varargin{:});
        end        
        function that = zoomed(this, varargin)
            %% ZOOMED parameters resembles fslroi, but indexing starts with 1 and passing -1 for a size will set it to 
            %  the full image extent for that dimension.
            %  @param xmin|fac is required.  Solitary fac symmetrically sets Euclidean (not time) size := fac*size and
            %                                symmetrically sets all min.
            %  @param xsize is optional.
            %  @param ymin  is optional.
            %  @param ysize is optional.
            %  @param zmin  is optional.
            %  @param zsize is optional.
            %  @param tmin  is optional.  Solitary tmin with tsize is supported.
            %  @param tsize is optional.
            %  @returns copy(this)
            
            %error('mlfourd:IncompleteImplementationError', 'ImagingContext2.zoomed');
            
            this.selectMaskingTool;
            that = copy(this);
            that.state_.zoomed(varargin{:});
        end
        
        %% mfourdfp.RegistrationTool
        
        %% mlfourd.ImagingFormatTool
        
        function this = addImgrec(this, varargin)
            this.selectImagingFormatTool;
            this.state_.addImgrec(varargin{:});
        end
        function this = addLog(this, varargin)
            %% ADDLOG
            %  @param varargin are log entries for the imaging state
            
            this.selectImagingFormatTool;
            this.state_.addLog(varargin{:});
        end
        function c    = char(this)
            this.selectImagingFormatTool;
            c = this.state_.char;
        end
        function d    = double(this)
            this.selectImagingFormatTool;
            d = this.state_.double;
        end
        function this = ensureSaved(this)
            %% ENSURESAVED saves the imaging state as this.fqfilename on the filesystem if not already saved.
            
            if (~lexist(this.fqfilename))
                this.save;
            end
        end
        function        freeview(this, varargin)
            this.selectImagingFormatTool;
            this.state_.freeview(varargin{:});
        end
        function        fslview(this, varargin)
            this.selectImagingFormatTool;
            this.state_.fslview(varargin{:});
        end
        function        fsleyes(this, varargin)
            this.selectImagingFormatTool;
            this.state_.fsleyes(varargin{:});
        end
        function        hist(this, varargin)
            this.selectImagingFormatTool;
            this.state_.hist(varargin{:});
        end
        function tf   = isempty(this)
            %% ISEMPTY
            %  @return tf is boolean for state emptiness
            
            this.selectImagingFormatTool;
            tf = this.state_.isempty;
        end
        function l    = length(this)
            %% LENGTH
            %  @return l is the length of a composite imaging state
            
            this.selectImagingFormatTool;
            l = this.state_.length;
        end
        function l    = logical(this)
            this.selectImagingFormatTool;
            l = this.state_.logical;
        end
        function s    = mat2str(this, varargin)
            this.selectImagingFormatTool;
            s = this.state_.mat2str(varargin{:});
        end
        function n    = ndims(this)
            this.selectImagingFormatTool;
            n = this.state_.ndims;
        end
        function r    = rank(this)
            %% DEPRECATED; use ndims.
            
            this.selectImagingFormatTool;
            r = this.ndims;
        end
        function        save(this)
            %% SAVE saves the imaging state as this.fqfilename on the filesystem.
            
            this.selectImagingFormatTool;
            this.state_.save;
        end
        function this = saveas(this, varargin)
            %% SAVEAS saves the imaging state as this.fqfilename on the filesystem.
            %  @param filename is a string that is compatible with requirements of the filesystem;
            %  @return this for compatibility with non-handle interfaces.
            %  it replaces internal filename & filesystem information.

            this.selectImagingFormatTool;
            this.state_ = this.state_.saveas(varargin{:});
        end   
        function s    = single(this)
            this.selectImagingFormatTool;
            s = this.state_.single;
        end  
        function s    = size(this, varargin)
            s = this.state_.size(varargin{:});
        end 
        function tf   = sizeEq(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for equal size

            this.selectImagingFormatTool;
            tf = this.state_.sizeEq(ic);
        end
        function tf   = sizeGt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for > size

            this.selectImagingFormatTool;
            tf = this.state_.sizeGt(ic);
        end
        function tf   = sizeLt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for < size

            this.selectImagingFormatTool;
            tf = this.state_.sizeLt(ic);
        end
        function this = updateImagingFormatTool(this, u)
            %  first call {fourdfp,mgz,nifti}, make adjustments, then call updateImagingFormatTool for fine-grained aufbau.
            %  @param u is mlfourd.ImagingFormatContext.
            
            this.selectImagingFormatTool;
            this.state_.updateInnerImaging(u);
        end
        function        view(this, varargin)
            %% VIEW
            %  @param are additional filenames and other arguments to pass to the viewer, 
            %  which will be saved to the filesystem as needed.
            %  @return new window with a view of the imaging state
            
            this.selectImagingFormatTool;
            this.state_.view(varargin{:});
        end
        
        %%
        
        function this = ImagingContext2(obj, varargin)
            %% ImagingContext2 
            %  @param obj is imaging data:  ImagingContext2, ImagingContext, char, data supported by ImagingFormatTool.
            %  @return initialized context for a state design pattern.  
            
            import mlfourd.*;
            if (0 == nargin) % must support empty ctor
                this.state_ = ImagingFormatTool(this);
                return
            end
            if (isa(obj, 'mlfourd.ImagingContext2')) % copy ctor for legacy behavior
                this = copy(obj);
                return
            end            
            if (isa(obj, 'mlfourd.ImagingContext')) % legacy objects
                this.state_ = ImagingFormatTool(this, obj.niftid, varargin{:});
                return
            end
            if (ischar(obj))
                this.state_ = FilesystemTool(this, obj);
                return
            end
            this.state_ = ImagingFormatTool(this, obj, varargin{:});
        end
        function that = clone(this)
            that = copy(this);
        end
    end  
    
    %% PROTECTED
    
    properties (Access = protected)
        state_ = []
    end 
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.state_ = copy(this.state_);
        end
    end
        
    %% HIDDEN
    
	methods (Hidden)
        function changeState(this, s)
            %% should only be accessed by AbstractImagingTool.
            
            assert(isa(s, 'mlfourd.AbstractImagingTool'));
            this.state_ = s;
        end
    end
    
    %% DEPRECATED

    methods (Static, Hidden)
        function ic = recastImagingContext(obj, oriClass)
            %% provides support for legacy objects.

            obj = mlfourd.ImagingContext2(obj);
            switch (oriClass)
                case 'mlfourd.ImagingContext'
                    ic = mlfourd.ImagingContext(obj);
                case 'mlfourd.ImagingContext2'
                    ic = obj;
                case 'mlmr.MRImagingContext'
                    ic = mlmr.MRImagingContext(obj);
                case 'mlpet.PETImagingContext'
                    ic = mlpet.PETImagingContext(obj);
                otherwise
                    error('mlfourd:unsupportedSwitchCase', ....
                          'ImagingContext2.recastImagingContext.oriClass->%s is not supported', oriClass);
            end
        end
    end
    
    methods (Hidden)
        function ifc = niftid(this)
            this.selectImagingFormatTool;
            ifc = this.nifti;
        end
        function ifc = numericalNiftid(this)
            this.selectNumericalTool;
            ifc = this.nifti;
        end 
    end  
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

