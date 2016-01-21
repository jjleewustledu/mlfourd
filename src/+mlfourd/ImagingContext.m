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
        function a = atlas(this, varargin)
            %% ATLAS
            %  @param imaging_objects[, ...] have typeclasses supported by ImagingContext.  All alignment
            %  operations between imaging objects must have been completed.  Time-domains will be summed.
            %  @return a is the voxel-by-voxel weighted sum of this image and any submitted images; 
            %  each image is weighted by its median value.
            %  @throws MATLAB:dimagree, MATLAB:UndefinedFunction
            
            a = this.state_.atlas(varargin{:});
        end
        function a = add(this, varargin)
            %% ADD
            %  @param imaging_objects[, ...] are objects supported by ImagingContext.  All alignment
            %  operations between imaging objects must have been completed.  Time-domains will be summed.
            %  @return a is the voxel-by-voxel sum of this image and any submitted images.
            %  @throws MATLAB:dimagree, MATLAB:UndefinedFunction
            
            a = this.state_.add(varargin{:});
        end
        function     addLog(this, lg)
        end
        function b = binarized(this)
        end
        function     blurred(this, varargin)
            ip = inputParser;
            addOptional(ip, 'blur', mlpet.PETRegistry.instance.petPointSpread, @isnumeric);
            parse(ip, varargin{:});
            
            niid = mlfourd.BlurringNIfTId(this.niftid_);
            niid = niid.blurred(ip.Results.blur);
            this.niftid_ = niid.component;
        end 
        function f = char(this)
            f = char(this.state_);
        end
        function     disp(this)
            disp(this.state_);
        end
        function d = double(this)
            d = double(this.state_);
        end
        function e = ecatExactHRPlus(this)
        end
        function g = get(this, varargin)
            %% GET
            %  @param varargin are integer locations corresponding to the imaging state
            %  @return g is an element of the imaging state
            
            g = this.state_.get(varargin{:});
        end
        function l = length(this)
            %% LENGTH
            %  @return l is the number of elements of the imaging state
            l = this.state_.length;
        end
        function m = masked(this, mask)
        end
        function     remove(this, varargin)
            %% REMOVE
            %  @param varargin are integer locations corresponding to the imaging state
            %  which will be removed .
            
            this.state_.remove(varargin{:});
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
        function     summed(this, varargin)
            %% SUMMED returns the voxel-by-voxel sum of imaging state with 
            %  all passed images.
            %  Usage:  voxelwise_summed_image = this.summed(image2[,image3,...]);
            
            img  = this.niftid_.img;
            fp   = this.niftid_.fileprefix;
            for n = 1:length(varargin)
                ic  = mlfourd.ImagingContext(varargin{n});
                img = img + ic.niftid.img;
                fp  = [fp '+' ic.fileprefix];
            end
            this.niftid_.img = img;
            this.niftid_.fileprefix = fp;
            [~,d] = strtok(fp, '+');
            this.niftid_ = this.niftid_.append_descrip(d);
        end
        function t = thresh(this)
        end
        function p = threshp(this)
        end
        function     timeSummed(this)
            niid = mlfourd.DynamicNIfTId(this.niftid_);
            niid = niid.timeSummed;
            this.niftid_ = niid.component;
        end
        function u = uthresh(this)
        end
        function p = uthreshp(this)
        end
        function     volumeSummed(this, varargin)
            error('mlfourd:notImplemented', 'ImagingState.volumeSummed');
        end
        function     view(this)
            %% VIEW
            %  @return new window with a view of the imaging state
            this.state_.view;
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
            if (isa(obj, 'mlfourd.NIfTId'))
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

