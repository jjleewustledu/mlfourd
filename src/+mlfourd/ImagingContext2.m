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
        stateTypeclass
        viewer
    end
    
    methods (Static)
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
    
        %% get some ImagingFormatContext 
        
        function ifc = fourdfp(this)
            ifc = this.state_.fourdfp;
        end
        function ifc = mgh(this)
            ifc = this.mgz;
        end
        function ifc = mgz(this)
            ifc = this.state_.mgz;
        end
        function ifc = nifti(this)
            ifc = this.state_.nifti;
        end
        
        %% select states
        
        function selectBlurringTool(this)
            this.state_.selectBlurringTool(this);
        end
        function selectDynamicsTool(this)
            this.state_.selectDynamicsTool(this);
        end
        function selectFilesystemTool(this)
            this.state_.selectFilesystemTool(this);
        end
        function selectIsNumericTool(this)
            this.state_.selectIsNumericTool(this);
        end
        function selectImagingFormatTool(this)
            this.state_.selectImagingFormatTool(this);
        end
        function selectMaskingTool(this)
            this.state_.selectMaskingTool(this);
        end
        function selectNumericalTool(this)
            this.state_.selectNumericalTool(this);
        end
        function selectRegistrationTool(this)
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
         
%         dipiqr(this)
%         dipisfinite(this)
%         dipisinf(this)
%         dipisnan(this)
%         dipisreal(this)
%         diplogprod(this)
%         dipmad(this)
%         dipmax(this)
%         dipmean(this)
%         dipmedian(this)
%         dipmin(this)
%         dipmode(this)
%         dipprctile(this)
%         dipprod(this)
%         dipquantile(this)
%         dipstd(this)
%         dipsum(this)
%         diptrimmean(this)
        
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
        
        function ic = timeAveraged(this, varargin)
            %% TIMEAVERAGED
            %  @param T is numeric \in [{\Bbb R} {\Bbb R}]
            %  @return ic := \int_T dt this.state_(\vec{r}, t).
            
            this.numericalNiftid;
            ic = mlfourd.ImagingContext2(this.state_.timeAveraged(varargin{:}));
        end
        function ic = timeContracted(this, varargin)
            %% TIMECONTRACTED
            %  @param T is numeric \in [{\Bbb R} {\Bbb R}]
            %  @return ic := \int_T dt this.state_(\vec{r}, t).
            
            this.numericalNiftid;
            ic = mlfourd.ImagingContext2(this.state_.timeContracted(varargin{:}));
        end
        function ic = timeSummed(this)
            %% TIMESUMMED integrates over imaging dimension 4. 
            %  @return ic, the modified imaging context, a dynamic image reduced to summed volume.
            
            this.numericalNiftid;
            ic = mlfourd.ImagingContext2(this.state_.timeSummed);
        end
        function ic = volumeAveraged(this, varargin)
            %% VOLUMEAVERAGED
            %  @param mask as ImagingContext2 specifying \Omega \in {\Bbb R}^3.
            %  @return ic := \int_{\Omega} d^3r this.state_(mask(\vec{r}), t).
            
            this.numericalNiftid;
            ic = mlfourd.ImagingContext2(this.state_.volumeAveraged(varargin{:}));
        end
        function ic = volumeContracted(this, varargin)
            %% VOLUMECONTRACTED
            %  @param mask as ImagingContext2 specifying \Omega \in {\Bbb R}^3.
            %  @return ic := \int_{\Omega} d^3r this.state_(mask(\vec{r}), t).
            
            this.numericalNiftid;
            ic = mlfourd.ImagingContext2(this.state_.volumeContracted(varargin{:}));
        end
        function ic = volumeSummed(this)
            %% VOLUMESUMMED integrates over imaging dimensions 1:3. 
            %  @return ic, the modified imaging context, a dynamic image reduced to time series
            
            this.numericalNiftid;
            ic = mlfourd.ImagingContext2(this.state_.volumeSummed);
        end
        
        %% MaskingTool
        
        function b  = binarized(this)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            this.numericalNiftid;
            b = mlfourd.ImagingContext2(this.state_.binarized);
        end
        function b  = binarizeBlended(this, varargin)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            this.numericalNiftid;
            b = mlfourd.ImagingContext2(this.state_.binarizeBlended(varargin{:}));
        end
        function l  = logical(this)
            l = this.double > 0;
        end
        function m  = maskBlended(this, varargin)
            this.numericalNiftid;
            m = mlfourd.ImagingContext2(this.state_maskBlended(varargin{:}));
        end
        function m  = masked(this, varargin)
            %% MASKED
            %  @param INIfTId of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            this.numericalNiftid;
            m =  mlfourd.ImagingContext2(this.state_.masked(varargin{:}));
        end
        function m  = maskedByZ(this, varargin)
            %% MASKEDBYZ
            %  @param rng = [low-z high-z], typically equivalent to [inferior superior];
            %  @return internal image is cropped by rng.  
            %  @throws MATLAB:assertion:failed for rng out of bounds.
            
            this.numericalNiftid;
            m =  mlfourd.ImagingContext2(this.state_.maskedByZ(varargin{:}));
        end
        function t  = thresh(this, t)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)
            %  @return t, the modified imaging context
            %  @return this if t == 0 or t is empty
            
            if (isempty(t)); t = this; return; end
            if (0 ==    t ); t = this; return; end
            this.numericalNiftid;
            t = mlfourd.ImagingContext2(this.state_.thresh(t));
        end
        function p  = threshp(this, p)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            %  @returns p, the modified imaging context
            %  @return this if p == 0 or p is empty
            
            if (isempty(p)); p = this; return; end
            if (0 ==    p ); p = this; return; end  
            this.numericalNiftid;          
            p =  mlfourd.ImagingContext2(this.state_.threshp(p));
        end
        function u  = uthresh(this, u)
            %% UTHRESH
            %  @param u:  use t to upper-threshold current image (zero anything above the number)
            %  @returns u, the modified imaging context
            %  @return this if u == 0 or u is empty
            
            if (isempty(u)); u = this; return; end
            if (0 ==    u ); u = this; return; end   
            this.numericalNiftid;         
            u =  mlfourd.ImagingContext2(this.state_.uthresh(u));
        end
        function p  = uthreshp(this, p)
            %% UTHRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything above the number)
            %  @returns p, the modified imaging context
            %  @return this if u == 0 or u is empty
            
            if (isempty(p)); p = this; return; end
            if (0 ==    p ); p = this; return; end  
            this.numericalNiftid;            
            p =  mlfourd.ImagingContext2(this.state_.uthreshp(p));
        end
        
        function that = zoomed(this, varargin)
            %% ZOOMED 
            %  @param vector of zoom multipliers; zoom(i) > 1 embeds this.img in a larger img.
            %  @return internal image is zoomed.
            %  @return this if varargin is empty
            %  @return this if prod(varargin{...}) == 1
            
            if (isempty(varargin));             z = this; return; end
            if (1 == prod(cell2mat(varargin))); z = this; return; end    
            this.selectMaskingTool  
            that = copy(this);
            that.state_.zoomed(varargin{:});
        end
        
        %% mfourdfp.RegistrationTool
        
        %%
        
        function      addImgrec(this, varargin)
            this.state_.addImgrec(varargin{:});
        end
        function      addLog(this, varargin)
            %% ADDLOG
            %  @param varargin are log entries for the imaging state
            
            this.state_.addLog(varargin{:});
        end
        function c    = char(this)
            c = this.state_.char;
        end
        function d  = double(this)
            d = this.state_.double;
        end
        function      ensureSaved(this)
            %% ENSURESAVED saves the imaging state as this.fqfilename on the filesystem if not already saved.
            
            if (~lexist(this.fqfilename))
                this.save;
            end
        end
        function      freeview(this, varargin)
            this.state_.freeview(varargin{:});
        end
        function      fslview(this, varargin)
            this.state_.fslview(varargin{:});
        end
        function      fsleyes(this, varargin)
            this.state_.fsleyes(varargin{:});
        end
        function      hist(this, varargin)
            this.state_.hist(varargin{:});
        end
        function tf = isempty(this)
            %% ISEMPTY
            %  @return tf is boolean for state emptiness
            
            tf = this.state_.isempty;
        end
        function l  = length(this)
            %% LENGTH
            %  @return l is the length of a composite imaging state
            
            l = this.state_.length;
        end
        function s  = mat2str(this, varargin)
            s = this.state_.mat2str(varargin{:});
        end
        function r  = rank(this)
            r = this.state_.rank;
        end
        function      save(this)
            %% SAVE saves the imaging state as this.fqfilename on the filesystem.
            
            this.state_.save(this);
        end
        function      saveas(this, varargin)
            %% SAVEAS saves the imaging state as this.fqfilename on the filesystem.
            %  @param filename is a string that is compatible with requirements of the filesystem;
            %  it replaces internal filename & filesystem information.

            this.state_.saveas(this, varargin{:});
        end   
        function s  = single(this)
            s = this.state_.single;
        end  
        function s  = size(this, varargin)
            s = this.state_.size(varargin{:});
        end 
        function tf = sizeEq(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for equal size

            tf = this.state_.sizeEq(ic);
        end
        function tf = sizeGt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for > size

            tf = this.state_.sizeGt(ic);
        end
        function tf = sizeLt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext2 to compare to this for size
            %  @returns tf logical for < size

            tf = this.state_.sizeLt(ic);
        end
        function      view(this, varargin)
            %% VIEW
            %  @param are additional filenames and other arguments to pass to the viewer, 
            %  which will be saved to the filesystem as needed.
            %  @return new window with a view of the imaging state
            
            this.state_.view(varargin{:});
        end
        
        function this = ImagingContext2(obj)
            %% ImagingContext2 
            %  @param obj is imaging data:  ImagingContext2, ImagingContext, char, data supported by ImagingFormatTool.
            %  @return initialized context for a state design pattern.  
            
            import mlfourd.*;
            if (~exist('obj', 'var')) % must support empty ctor
                this.state_ = ImagingFormatTool(this);
                return
            end
            if (isa(obj, 'mlfourd.ImagingContext2')) % copy ctor for legacy behavior
                this = copy(obj);
                return
            end            
            if (isa(obj, 'mlfourd.ImagingContext')) % legacy objects
                this.state_ = ImagingFormatTool(this, obj.niftid);
                return
            end
%             if (ischar(obj)) 
%                 this.state_ = FilesystemTool(this, obj);
%                 return
%             end
            this.state_ = ImagingFormatTool(this, obj);
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
            switch (oriClass)
                case 'mlfourd.ImagingContext'
                    ic = mlfourd.ImagingContext(obj);
                case 'mlfourd.ImagingContext2'
                    ic = mlfourd.ImagingContext2(obj);
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
        function g   = getLog(this)
            g = this.logger;
        end
        function ifc = niftid(this)
            ifc = this.state_.niftid;
        end
        function ifc = numericalNiftid(this)
            ifc = this.state_.numericalNiftid;
        end 
    end  
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

