classdef ImagingContext < handle
	%% IMAGINGCONTEXT provides the context for a state design pattern for imaging data.  It also 
    %  provides a facade pattern for many classes that directly represent imaging data.  It's intent  
    %  is to improve the fluent expressivity of behaviors involving imaging data.
    %  See also:  mlfourd.ImagingState, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState,
    %             mlfourd.CellCompositeState, mlfourd.FilenameState, mlpatterns.State, 
    %             mlio.IOInterface, mlfourd.DoubleState.
    
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
    end 
    
    methods (Static)
        function this = load(obj)
            %% LOAD:  cf. ctor
            
            this = mlfourd.ImagingContext(obj);
        end
    end

    methods
        function     add(this, varargin)
            %% ADD
            %  @param varargin are added to a composite imaging state
            
            this.state_ = this.state_.add(varargin{:});
        end
        function     addLog(this, varargin)
            %% ADDLOG
            %  @param varargin are log entries for the imaging state
            
            this.state_.addLog(varargin{:});
        end
        function a = atlas(this, varargin)
            %% ATLAS
            %  @param imaging_objects[, ...] have typeclasses supported by ImagingContext.  All alignment
            %  operations between imaging objects must have been completed.  Time-domains will be summed.
            %  @return a is the voxel-by-voxel weighted sum of this image and any submitted images; 
            %  each image is weighted by its median value.
            %  @throws MATLAB:dimagree, MATLAB:UndefinedFunction
            
            a = this.state_.atlas(varargin{:});
        end
        function b = binarized(this)
            %% BINARIZED
            %  @return internal image is binary: values are only 0 or 1.
            %  @warning mlfourd:possibleMaskingError
            
            b = this.state_.binarized;
        end
        function b = biographMMR(this)
        end
        function b = blurred(this, varargin)
            %% BLURRED
            %  @param [fwhh_x fwhh_y fwhh_z] describes the anisotropic Gaussian blurring kernel
            %  applied to the internally stored image
            %  @return the blurred image
            
            b = this.state_.blurred(varargin{:});
        end 
        function f = char(this)
            f = char(this.state_);
        end
        function     close(this)
            this.state_.close;
        end
        function c = createIterator(this)
            %% CREATEITERATOR
            %  @return c is an iterator for a mlpatterns.Composite instance, if any
            
            c = this.state_.createIterator;
        end
        function c = csize(this)
            %% CSIZE
            %  @return c is the size of the imaging state when it is composite
            
            c = this.state_.csize;
        end
        function     disp(this)
            disp(this.state_);
        end
        function d = double(this)
            d = double(this.state_);
        end
        function e = ecatExactHRPlus(this)
        end
        function f = find(this, varargin)
            %% FIND
            %  @param varargin are objects to find within a composite imaging state
            %  %return f is the position within the composite of the object
            
            f = this.state_.find(varargin{:});
        end
        function g = get(this, varargin)
            %% GET
            %  @param varargin are integer locations within a composite imaging state
            %  @return g is an element of the imaging state
            
            g = this.state_.get(varargin{:});
        end
        function tf = isempty(this)
            %% ISEMPTY
            %  @return tf is boolean for state emptiness
            
            tf = this.state_.isempty;
        end
        function l = length(this)
            %% LENGTH
            %  @return l is the length of a composite imaging state
            
            l = this.state_.length;
        end
        function m = masked(this, varargin)
            %% MASKED
            %  @param INIfTId of a mask with values [0 1], not required to be binary.
            %  @return internal image is masked.
            %  @warning mflourd:possibleMaskingError
            
            m = this.state_.masked(varargin{:});
        end
        function m = maskedByZ(this, varargin)
            %% MASKEDBYZ
            %  @param rng = [low-z high-z], typically equivalent to [inferior superior];
            %  @return internal image is cropped by rng.  
            %  @throws MATLAB:assertion:failed for rng out of bounds.
            
            m = this.state_.maskedByZ(varargin{:});
        end
        function     rm(this, varargin)
            %% RM
            %  @param varargin are integer locations which will be removed from the imaging state.
            
            this.state_ = this.state_.rm(varargin{:});
        end
        function     save(this)
            %% SAVE saves the imaging state as this.fqfilename on the filesystem.
            
            this.state_.save;
        end
        function     saveas(this, filename)
            %% SAVEAS saves the imaging state as this.fqfilename on the filesystem.
            %  @param filename is a string that is compatible with requirements of the filesystem;
            %  it replaces internal filename & filesystem information.

            this.state_ = this.state_.saveas(filename);
        end
        function t = thresh(this)
            %% THRESH
            %  @param t:  use t to threshold current image (zero anything below the number)
            
            t = this.state_.thresh;
        end
        function p = threshp(this)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            
            p = this.state_.threshp;
        end
        function t = timeSummed(this)
            %% TIMESUMMED integrates over imaging dimension 4. 
            %  @return dynamic image reduced to summed volume.
            
            t = this.state_.timeSummed;
        end
        function u = uthresh(this)
            %% UTHRESH
            %  @param t:  use t to upper-threshold current image (zero anything above the number)
            
            u = this.state_.uthresh;
        end
        function p = uthreshp(this)
            %% THRESHP
            %  @param p:  use percentage p (0-100) of ROBUST RANGE to threshold current image (zero anything below the number)
            
            p = this.state_.uthreshp;
        end
        function v = volumeSummed(this)
            %% VOLUMESUMMED integrates over imaging dimensions 1:3. 
            %  @return dynamic image reduced to time series.
            
            v = this.state_.volumeSummed;
        end
        function     view(this, varargin)
            %% VIEW
            %  @param are additional filenames and other arguments to pass to the viewer.
            %  @return new window with a view of the imaging state
            
            this.state_.view(varargin{:});
        end
        
        %% CTOR
        
        function this = ImagingContext(obj)
            %% IMAGINGCONTEXT 
            %  @param obj is imaging data:  filename, INIfTI, MGH, ImagingComponent, double, [] or 
            %  ImagingContext for copy-ctor.  
            %  @return initializes context for a state design pattern.  
            %  @throws mlfourd:switchCaseError, mlfourd:unsupportedTypeclass.
            
            import mlfourd.*;
            if (nargin == 1 && isa(obj, 'mlfourd.ImagingContext'))
                switch (obj.stateTypeclass)
                    case 'mlfourd.CellCompositeState'
                        this = ImagingContext(obj.cellComposite);
                    case 'mlfourd.NIfTIcState'
                        this = ImagingContext(obj.niftic);
                    case 'mlfourd.MGHState'
                        this = ImagingContext(obj.mgh);
                    case 'mlfourd.NumericalNIfTIdState'
                        this = ImagingContext(obj.numericalNiftid);
                    case 'mlfourd.NIfTIdState'
                        this = ImagingContext(obj.niftid);
                    case 'mlfourd.FilenameState'
                        this = ImagingContext(obj.fqfilename);
                    case 'mlfourd.DoubleState'
                        this = ImagingContext(obj.double);
                    otherwise
                        error('mlfourd:switchCaseError', ...
                              'ImagingContext.ctor.obj.stateTypeclass -> %s', obj.stateTypeclass);
                end
                return
            end
            
            if (isa(obj, 'mlpatterns.CellComposite') || iscell(obj))
                this.state_ = CellCompositeState(obj, this);
                return
            end
            if (isa(obj, 'mlfourd.NIfTIc'))
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
                isa(obj, 'mlfourd.DynamicNIfTId'))
                this.state_ = NIfTIdState(obj, this);
                return
            end
            if (ischar(obj)) % filename need not yet exist 
                this.state_ = FilenameState(obj, this);
                return
            end
            if (isnumeric(obj)) % includes []
                this.state_ = DoubleState(obj, this);
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
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

