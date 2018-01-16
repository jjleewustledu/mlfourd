classdef ImagingContext < handle
	%% IMAGINGCONTEXT provides the context for a state design pattern for imaging data.  It also 
    %  provides a facade pattern for many classes that directly represent imaging data.  It's intent  
    %  is to improve the fluent expressivity of behaviors involving imaging data.
    %  See also:  mlfourd.ImagingState, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState,
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State, 
    %             mlio.IOInterface, mlfourd.DoubleState.
    %  When adding methods, see also:  mlfourd.ImagingState, mlfourd.NumericalNIfTIdState, mlfourd.NumericalNIfTId,
    %                                  mlfourd.MaskingNIfTId, mlpet.PETImagingContext, mlmr.MRImagingContext;
    %                                  or comparable mlfourd.*State, mlfourd.*NIfTId.
    
	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingContext.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a).  Copyright 2017 John Joowon Lee.
 	%  $Id: ImagingContext.m 2627 2013-09-16 06:18:10Z jjlee $ 
    
    properties (Constant)
        LOCATION_TYPES = {'folder' 'path'}
        IMAGING_TYPES  = { ...
            'ext' ...
            'filename' 'fn' 'fqfilename' 'fqfn' 'fileprefix' 'fp' 'fqfileprefix' 'fqfp' ...
            'imagingContext' 'mlfourd.ImagingContext' 'mgh' 'mgz' 'mhdr' 'mrImagingContext' 'mlmr.MRImagingContext' ...
            'nii' 'nii.gz' 'petImagingContext' 'mlpet.PETImagingContext' 'v' 'v.hdr' 'v.mhdr' ...
            '4dfp.hdr' '.4dfp.hdr' '4dfp.ifh' '.4dfp.ifh' '4dfp.img' '.4dfp.img' '4dfp.img.rec' '.4dfp.img.rec' ...
            'folder' 'path'}
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
        
        cellComposite
        fourdfp
        mgh
        niftic
        niftid
        numericalNiftid
        petNiftid
        stateTypeclass
        viewer
    end
    
    methods (Static)
        function im   = imagingType(typ, obj)
            %% IMAGINGTYPE returns imaging data cast as a requested representative type detailed below.
            %  @param typ is the requested representation:  'filename', 'fn', fqfilename', 'fqfn', 'fileprefix', 'fp',
            %  'fqfileprefix', 'fqfp', 'folder', 'path', 'ext', 'imagingContext', 
            %  '4dfp.hdr', '4dfp.ifh', '4dfp.img', '4dfp.img.rec', 'v', 'v.hdr', 'v.mhdr'. 
            %  @param obj is the representation of imaging data provided by the client.  
            %  @returns im is the imaging data obj cast as the requested representation.
            %  See also mlfourd.ImagingContext
            
            import mlfourd.*;
            if (ischar(obj) && isdir(obj))
                im = ImagingContext.locationType(typ, obj);
                return
            end
            obj = ImagingContext(obj);
            switch (typ)
                case  'folder'
                    [~,im] = fileparts(obj.filepath);
                case {'filepath' 'path'}
                    im = obj.filepath;
                case {'fileprefix' 'fp'}
                    im = obj.fileprefix;
                case  'ext'
                    [~,~,im] = myfileparts(obj.filename);
                case {'filename' 'fn'}
                    im = obj.filename;
                case {'fqfilename' 'fqfn'}
                    im = obj.fqfilename;
                case {'fqfileprefix' 'fqfp' 'fdfp'}
                    im = obj.fqfileprefix;
                case {'imagingContext' 'ImagingContext' 'mlfourd.ImagingContext'}
                    im = mlfourd.ImagingContext(obj);
                case {'mgz' '.mgz'}
                    im = [obj.fqfileprefix '.mgz'];
                case {'mhdr' '.mhdr'}
                    im = [obj.fqfileprefix '.mhdr'];
                case {'mrImagingContext' 'MRImagingContext' 'mlmr.MRImagingContext'}
                    im = mlmr.MRImagingContext(obj);                    
                case {'nii' '.nii'}
                    im = [obj.fqfileprefix '.nii'];
                case {'nii.gz' '.nii.gz'}
                    im = [obj.fqfileprefix '.nii.gz'];
                case {'petImagingContext' 'PETImagingContext' 'mlpet.PETImagingContext'}
                    im = mlpet.PETImagingContext(obj);  
                case {'v' '.v'}
                    im = [obj.fqfileprefix '.v'];
                case {'v.hdr' '.v.hdr'}
                    im = [obj.fqfileprefix '.v.hdr'];
                case {'v.mhdr' '.v.mhdr'}
                    im = [obj.fqfileprefix '.v.mhdr'];
                case {'4dfp.hdr' '.4dfp.hdr'}
                    im = [obj.fqfileprefix '.4dfp.hdr'];
                case {'4dfp.ifh' '.4dfp.ifh'}
                    im = [obj.fqfileprefix '.4dfp.ifh'];
                case {'4dfp.img' '.4dfp.img'}
                    im = [obj.fqfileprefix '.4dfp.img'];
                case {'4dfp.img.rec' '.4dfp.img.rec'}
                    im = [obj.fqfileprefix '.4dfp.img.rec'];
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
                case 'cellComposite'
                    im = obj.cellComposite;
                case 'fourdfp'
                    im = obj.fourdfp;
                case  'mgh'
                    im = obj.mgh;
                case  'niftic'
                    im = obj.niftic;
                case  'niftid'
                    im = obj.niftid;
                case  'numericalNiftid'
                    im = obj.numericalNiftid;
                case  'petNiftid'
                    im = obj.petNiftid;
                otherwise
                    error('mlfourd:insufficientSwitchCases', ...
                          'ImagingContext.imagingType.obj->%s not recognized', obj);
            end
        end
        function tf   = isImagingType(t)
            tf = lstrcmp(t, mlfourd.ImagingContext.IMAGING_TYPES);
        end
        function tf   = isLocationType(t)
            tf = lstrcmp(t, mlfourd.ImagingContext.LOCATION_TYPES);
        end
        function this = load(obj)
            %% LOAD:  cf. ctor
            
            this = mlfourd.ImagingContext(obj);
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
                          'ImagingContext.locationType.loc0->%s not recognized', loc0);
            end
        end
        function ic   = repackageImagingContext(obj, oriClass)
            switch (oriClass)
                case 'mlfourd.ImagingContext'
                    ic = mlfourd.ImagingContext(obj);
                case 'mlmr.MRImagingContext'
                    ic = mlmr.MRImagingContext(obj);
                case 'mlpet.PETImagingContext'
                    ic = mlpet.PETImagingContext(obj);
                otherwise
                    error('mlfourd:unsupportedSwitchCase', ....
                          'ImagingContext.repackageImagingContext.oriClass->%s is not supported', oriClass);
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
        function f = get.noclobber(this)
            f = this.state_.noclobber;
        end
        
        function f = get.cellComposite(this)
            f = this.state_.cellComposite;
        end
        function f = get.fourdfp(this)
            f = this.state_.fourdfp;
        end
        function f = get.mgh(this)
            f = this.state_.mgh;
        end
        function f = get.niftic(this)
            f = this.state_.niftic;
        end
        function f = get.niftid(this)
            f = this.state_.niftid;
        end
        function f = get.numericalNiftid(this)
            f = this.state_.numericalNiftid;
        end     
        function f = get.petNiftid(this)
            f = this.state_.petNiftid;
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
    
        %%
        
        function      add(this, varargin)
            %% ADD
            %  @param varargin are added to a composite imaging state
            
            this.state_ = this.state_.add(varargin{:});
        end
        function      addLog(this, varargin)
            %% ADDLOG
            %  @param varargin are log entries for the imaging state
            
            this.state_.addLog(varargin{:});
        end
        function a  = atlas(this, varargin)
            %% ATLAS
            %  @param imaging_objects[, ...] have typeclasses supported by ImagingContext.  All alignment
            %  operations between imaging objects must have been completed.  Time-domains will be summed.
            %  @return a is the voxel-by-voxel weighted sum of this image and any submitted images; 
            %  each image is weighted by its median value.
            %  @throws MATLAB:dimagree, MATLAB:UndefinedFunction
            
            a = mlfourd.ImagingContext(this.state_.atlas(varargin{:}));
        end
        function b  = binarized(this)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            b = mlfourd.ImagingContext(this.state_.binarized);
        end
        function b  = binarizeBlended(this, varargin)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            b = mlfourd.ImagingContext(this.state_.binarizeBlended(varargin{:}));
        end
        function b  = blurred(this, varargin)
            %% BLURRED
            %  @param [fwhh_x fwhh_y fwhh_z] describes the anisotropic Gaussian blurring kernel
            %  applied to the internally stored image
            %  @return the blurred image
            
            b =  mlfourd.ImagingContext(this.state_.blurred(varargin{:}));
        end 
        function f  = char(this)
            f = char(this.state_);
        end
        function      close(this)
            this.state_.close;
        end
        function b  = coulombPotential(this, varargin)
            %% COULOMBPOTENTIAL
            %  @param 'mask' is numeric or is an mlfourd.INIfTI
            %  @return the blurred image
            
            b =  mlfourd.ImagingContext(this.state_.coulombPotential(varargin{:}));
        end 
        function c  = createIterator(this)
            %% CREATEITERATOR
            %  @return c is an iterator for a mlpatterns.Composite instance, if any
            
            c = this.state_.createIterator;
        end
        function c  = csize(this)
            %% CSIZE
            %  @return c is the size of the imaging state when it is composite
            
            c = this.state_.csize;
        end
        function      disp(this)
            disp(this.state_);
        end
        function d  = double(this)
            d = double(this.state_);
        end
        function      ensureSaved(this)
            %% ENSURESAVED saves the imaging state as this.fqfilename on the filesystem if not already saved.
            
            if (~lexist(this.fqfilename))
                this.state_.save;
            end
        end
        function f  = false(this, varargin)
            f =  mlfourd.ImagingContext(this.state_.false(varargin{:}));
        end
        function f  = find(this, varargin)
            %% FIND
            %  @param varargin are objects to find within a composite imaging state
            %  %return f is the position within the composite of the object
            
            f = this.state_.find(varargin{:});
        end
        function g  = get(this, varargin)
            %% GET
            %  @param varargin are integer locations within a composite imaging state
            %  @return g is an element of the imaging state
            
            g =  mlfourd.ImagingContext(this.state_.get(varargin{:}));
        end
        function g  = getLog(this)
            %% GETLOG
            %  @return g is the internal logger (handle) for the imaging state
            
            g =  this.state_.getLog;
        end
        function      hist(this)
            hist(this.niftid);
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
        function l  = logical(this)
            l = this.double > 0;
        end
        function m  = maskBlended(this, varargin)
            this = this.numericalNiftid;
            m = mlfourd.ImagingContext(this.state_maskBlended(varargin{:}));
        end
        function m  = masked(this, varargin)
            %% MASKED
            %  @param INIfTId of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            m =  mlfourd.ImagingContext(this.state_.masked(varargin{:}));
        end
        function m  = maskedByZ(this, varargin)
            %% MASKEDBYZ
            %  @param rng = [low-z high-z], typically equivalent to [inferior superior];
            %  @return internal image is cropped by rng.  
            %  @throws MATLAB:assertion:failed for rng out of bounds.
            
            m =  mlfourd.ImagingContext(this.state_.maskedByZ(varargin{:}));
        end
        function n  = nan(this, varargin)
            n =  mlfourd.ImagingContext(this.state_.nan(varargin{:}));
        end
        function n  = not(this, varargin)
            n =  mlfourd.ImagingContext(this.state_.not(varargin{:}));
        end
        function o  = ones(this, varargin)
            o =  mlfourd.ImagingContext(this.state_.ones(varargin{:}));
        end
        function r  = rank(this)
            r = this.state_.rank;
        end
        function      rm(this, varargin)
            %% RM
            %  @param varargin are integer locations which will be removed from the imaging state.
            
            this.state_ = this.state_.rm(varargin{:});
        end
        function      save(this)
            %% SAVE saves the imaging state as this.fqfilename on the filesystem.
            
            this.state_.save;
        end
        function      saveas(this, filename)
            %% SAVEAS saves the imaging state as this.fqfilename on the filesystem.
            %  @param filename is a string that is compatible with requirements of the filesystem;
            %  it replaces internal filename & filesystem information.

            this.state_ = this.state_.saveas(filename);
        end
        function      setNoclobber(this, s)
            this.state_ = this.state_.setNoclobber(s);
        end        
        function s  = single(this)
            s = single(this.double);
        end
        function tf = sizeEq(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext to compare to this for size
            %  @returns tf logical for equal size

            tf = this.state_.sizeEq(ic);
        end
        function tf = sizeGt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext to compare to this for size
            %  @returns tf logical for > size

            tf = this.state_.sizeGt(ic);
        end
        function tf = sizeLt(this, ic)
            %% SIZEEQ 
            %  @param ImagingContext to compare to this for size
            %  @returns tf logical for < size

            tf = this.state_.sizeLt(ic);
        end
        function t  = thresh(this, t)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)
            %  @returns t, the modified imaging context
            
            t = mlfourd.ImagingContext(this.state_.thresh(t));
        end
        function p  = threshp(this, p)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            %  @returns p, the modified imaging context
            
            p =  mlfourd.ImagingContext(this.state_.threshp(p));
        end
        function ic = timeSummed(this)
            %% TIMESUMMED integrates over imaging dimension 4. 
            %  @return ic, the modified imaging context, a dynamic image reduced to summed volume.
            
            ic = mlfourd.ImagingContext(this.state_.timeSummed);
        end
        function ic = timeContracted(this, varargin)
            %% TIMECONTRACTED
            %  @param T is numeric \in [{\Bbb R} {\Bbb R}]
            %  @return ic := \int_T dt this.state_(\vec{r}, t).
            
            ic = mlfourd.ImagingContext(this.state_.timeContracted(varargin{:}));
        end
        function t  = true(this, varargin)
            t =  mlfourd.ImagingContext(this.state_.true(varargin{:}));
        end
        function u  = uthresh(this, u)
            %% UTHRESH
            %  @param u:  use t to upper-threshold current image (zero anything above the number)
            %  @returns u, the modified imaging context
            
            u =  mlfourd.ImagingContext(this.state_.uthresh(u));
        end
        function p  = uthreshp(this, p)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything above the number)
            %  @returns p, the modified imaging context
            
            p =  mlfourd.ImagingContext(this.state_.uthreshp(p));
        end
        function ic = volumeSummed(this)
            %% VOLUMESUMMED integrates over imaging dimensions 1:3. 
            %  @return ic, the modified imaging context, a dynamic image reduced to time series
            
            ic = mlfourd.ImagingContext(this.state_.volumeSummed);
        end
        function ic = volumeContracted(this, varargin)
            %% VOLUMECONTRACTED
            %  @param mask as ImagingContext specifying \Omega \in {\Bbb R}^3.
            %  @return ic := \int_{\Omega} d^3r this.state_(mask(\vec{r}), t).
            
            ic = mlfourd.ImagingContext(this.state_.volumeContracted(varargin{:}));
        end
        function      view(this, varargin)
            %% VIEW
            %  @param are additional filenames and other arguments to pass to the viewer, 
            %  which will be saved to the filesystem as needed.
            %  @return new window with a view of the imaging state
            %  @throws mlfourd:IOError
            
            this.ensureAnyFormsSaved(varargin{:});
            this.state_.view(varargin{:});
        end
        function z  = zeros(this, varargin)
            z =  mlfourd.ImagingContext(this.state_.zeros(varargin{:}));
        end
        function z  = zoomed(this, varargin)
            %% ZOOMED 
            %  @param vector of zoom multipliers; zoom(i) > 1 embeds this.img in a larger img.
            %  @return internal image is zoomed.
            
            z =  mlfourd.ImagingContext(this.state_.zoomed(varargin{:}));
        end
        
        function this = ImagingContext(obj)
            %% IMAGINGCONTEXT 
            %  @param obj is imaging data:  filename, INIfTI, MGH, ImagingComponent, double, [] or 
            %  ImagingContext for copy-ctor.  
            %  @return initializes context for a state design pattern.  
            %  @throws mlfourd:switchCaseError, mlfourd:unsupportedTypeclass.
            
            import mlfourd.*;
            if (~exist('obj', 'var'))
                return
            end
            if (isa(obj, 'mlfourd.ImagingContext'))
                switch (obj.stateTypeclass)
                    case 'mlfourd.CellCompositeState'
                        this.state_ = CellCompositeState(obj.cellComposite, this);
                    case 'mlfourd.NIfTIcState'
                        this.state_ = NIfTIcState(obj.niftic, this);
                    case 'mlfourd.MGHState'
                        this.state_ = MGHState(obj.mgh, this);
                    case 'mlfourd.NumericalNIfTIdState'
                        this.state_ = NumericalNIfTIdState(obj.numericalNiftid, this);
                    case 'mlfourd.NIfTIdState'
                        this.state_ = NIfTIdState(obj.niftid, this);
                    case 'mlfourd.FilenameState'
                        this.state_ = FilenameState(obj.fqfilename, this);
                    case 'mlfourd.FourdfpState'
                        this.state_ = FourdfpState(obj.fqfilename, this);
                    case 'mlfourd.DoubleState'
                        this.state_ = DoubleState(obj.double, this);
                    otherwise
                        error('mlfourd:switchCaseError', ...
                              'ImagingContext.ctor.obj.stateTypeclass -> %s', obj.stateTypeclass);
                end
                return
            end
            if (isa(obj, 'mlfourd.NIfTIc') || isa(obj, 'mlpatterns.CellComposite') || iscell(obj))
                this.state_ = NIfTIcState(obj, this);
                return
            end
            if (isa(obj, 'mlsurfer.MGH'))
                this.state_ = MGHState(obj, this);
                return
            end
            if (isa(obj, 'mlfourdfp.Fourdfp'))
                this.state_ = FourdfpState(obj, this);
                return
            end
            if (isa(obj, 'mlfourd.NumericalNIfTId'))
                this.state_ = NumericalNIfTIdState(obj, this);
                return
            end
            if (isa(obj, 'mlfourd.NIfTId') || ...
                isa(obj, 'mlfourd.BlurringNIfTId') || ...
                isa(obj, 'mlfourd.MaskingNIfTId') || ...
                isa(obj, 'mlfourd.DynamicNIfTId') || ...
                isnumeric(obj))
                this.state_ = NIfTIdState(obj, this);
                return
            end
            if (ischar(obj)) 
                % filename need not yet exist 
                this.state_ = FilenameState(obj, this);
                return
            end
            error('mlfourd:unsupportedTypeclass', ...
                  'class(ctor.obj)->%s\nchar(ctor.obj)->%s', class(obj), char(obj));
        end
        function c    = clone(this)
            %% CLONE simplifies calling the copy constructor.
            %  @return deep copy on new handle
            
            c = mlfourd.ImagingContext(this);
        end
    end  
    
    %% PROTECTED
    
    properties (Access = protected)
        state_
    end    
    
    methods (Static, Access = protected)
        function ensureAnyFormsSaved(varargin)
            %% ENSUREANYFORMSSAVED saves all INIfTIc, INIfTId to the filesystem.
            %  @param varargin of imaging objects (ImagingContext, NIfTIcState, INIfTIc, INIfTId)
            %  TODO:  consider moving ensureAnyFormsSaved to mlfourd.ImagingState.
            
            for v = 1:length(varargin)
                vobj = varargin{v};
                if (isa(vobj, 'mlfourd.ImagingContext'))
                    import mlfourd.*;
                    if (strcmp(vobj.stateTypeclass, 'mlfourd.NIfTIcState'))
                        ImagingContext.ensureAnyFormsSaved(vobj.niftic);
                    else                        
                        ImagingContext.ensureAnyFormsSaved(vobj.niftid);
                    end
                end
                if (isa(vobj, 'mlfourd.INIfTIc'))
                    iter = vobj.createIterator;
                    while (iter.hasNext)
                        cached = iter.next;
                        if (~lexist(cached.fqfilename, 'file'))
                            cached.save;
                        end
                    end
                end
                if (isa(vobj, 'mlfourd.INIfTId'))
                    if (~lexist(vobj.fqfilename, 'file'))
                        vobj.save;
                    end
                end
            end
        end
    end
    
    %% HIDDEN
    
	methods (Hidden)
        function changeState(this, s)
            %% CHANGESTATE
            %  @param s must be an ImagingState; it replaces the current internal state.
            
            assert(isa(s, 'mlfourd.ImagingState'));
            this.state_ = s;
        end
    end  
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

