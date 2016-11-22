classdef ImagingContext < handle
	%% IMAGINGCONTEXT provides the context for a state design pattern for imaging data.  It also 
    %  provides a facade pattern for many classes that directly represent imaging data.  It's intent  
    %  is to improve the fluent expressivity of behaviors involving imaging data.
    %  See also:  mlfourd.ImagingState, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState,
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State, 
    %             mlio.IOInterface, mlfourd.DoubleState.
    %  When adding methods, see also:  mlfourd.ImagingState, mlfourd.NumericalNIfTIdState, mlfourd.NumericalNIfTId,
    %                                  mlfourd.MaskingNIfTId, mlfourd.PETImagingContext, mlfourd.MRImagingContext;
    %                                  or comparable mlfourd.*State, mlfourd.*NIfTId.
    
	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingContext.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingContext.m 2627 2013-09-16 06:18:10Z jjlee $ 
    
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
        mgh
        niftic
        niftid
        numericalNiftid
        
        stateTypeclass
    end
    
	methods %% GET/SET
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
        function c = get.stateTypeclass(this)
            c = class(this.state_);
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
    end 
    
    methods (Static)
        function this = load(obj)
            %% LOAD:  cf. ctor
            
            this = mlfourd.ImagingContext(obj);
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
        function t  = timeSummed(this)
            %% TIMESUMMED integrates over imaging dimension 4. 
            %  @return dynamic image reduced to summed volume.
            %  @returns t, the modified imaging context
            
            t =  mlfourd.ImagingContext(this.state_.timeSummed);
        end
        function u  = uthresh(this, u)
            %% UTHRESH
            %  @param u:  use t to upper-threshold current image (zero anything above the number)
            %  @returns u, the modified imaging context
            
            u =  mlfourd.ImagingContext(this.state_.uthresh(u));
        end
        function p  = uthreshp(this, p)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            %  @returns p, the modified imaging context
            
            p =  mlfourd.ImagingContext(this.state_.uthreshp(p));
        end
        function v  = volumeSummed(this)
            %% VOLUMESUMMED integrates over imaging dimensions 1:3. 
            %  @return dynamic image reduced to time series.
            %  @returns v, the modified imaging context
            
            v =  mlfourd.ImagingContext(this.state_.volumeSummed);
        end
        function      view(this, varargin)
            %% VIEW
            %  @param are additional filenames and other arguments to pass to the viewer.
            %  @return new window with a view of the imaging state
            %  @throws mlfourd:IOError
            
            this.ensureAnyFormsSaved(varargin{:});
            if (strcmp(this.filesuffix, '.4dfp.ifh'))
                this.filesuffix = '.4dfp.img';
            end
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
        
        %% CTOR
        
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
                if (FourdfpState.isFourdfp(obj))
                    this.state_ = FourdfpState(obj, this);
                    return
                end
                this.state_ = FilenameState(obj, this);
                return
            end
            error('mlfourd:unsupportedTypeclass', ...
                  'class(ctor.obj)->%s\nchar(ctor.obj)->%s', class(obj), char(obj));
        end
        function c = clone(this)
            %% CLONE simplifies calling the copy constructor.
            %  @return deep copy on new handle
            
            c = mlfourd.ImagingContext(this);
        end
    end
    
	methods (Hidden)
        function changeState(this, s)
            %% CHANGESTATE
            %  @param s must be an ImagingState; it replaces the current internal state.
            
            assert(isa(s, 'mlfourd.ImagingState'));
            this.state_ = s;
        end
    end    
    
    %% PROTECTED
    
    properties (Access = protected)
        state_
    end
    
    methods (Static, Access = protected)
        function ensureAnyFormsSaved(varargin)
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
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

