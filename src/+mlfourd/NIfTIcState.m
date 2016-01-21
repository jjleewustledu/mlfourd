classdef NIfTIcState < mlfourd.ImagingState
	%% NIFTICSTATE  

	%  $Revision$
 	%  was created 15-Jan-2016 23:01:37
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
	properties (Dependent)
        cellComposite
        mgh
        niftic
        niftid
        numericalNiftid
 	end 

	methods %% GET
        function g = get.niftid(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.niftid;
        end   
        function g = get.niftic(this)
            g = this.concreteObj_;
        end   
        function g = get.numericalNiftid(this)       
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState(this.concreteObj_, this.contexth_));
            g = this.contexth_.numericalNiftid;     
        end         
    end
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.NIfTIcState(varargin{:});
        end
    end
    
    methods 
        function a = add(this, varargin)
            %% ADD combines the composite with addition of images.
            %  @param [varargin] are any ImagingContext objects.
            %  @return a is an ImagingContext with NIfTIdState.
            
            this = this.accumulateNIfTId(varargin{:});
            
            import mlfourd.*;
            niic = this.niftic;
            a = NumericalNIfTId(niic.get(1).zeros);
            a = a.timeSummed; % reduce to 3D
            for o = 1:niic.length
                b = NumericalNIfTId(niic.get(o));
                b = b.timeSummed;
                a = a + b;
            end
            a = a.append_fileprefix('_add');
            a = a.append_descrip('add');
            a = ImagingContext(NIfTId(a));
        end
        function a = atlas(this, varargin)
            %% ATLAS builds an atlas over the composite.
            %  @param [varargin] are any ImagingContext objects.
            %  @return a is an ImagingContext with NIfTIdState.
            
            this = this.accumulateNIfTId(varargin{:});
            
            import mlfourd.*;
            niic = this.niftic;
            a = NumericalNIfTId(niic.get(1).zeros);
            a = a.timeSummed; % reduce to 3D
            for o = 1:niic.length
                b = NumericalNIfTId(niic.get(o));
                b = b.timeSummed;
                a = a + b/dipmedian(b);
            end
            a = a.append_fileprefix('_atlas');
            a = a.append_descrip('atlas');
            a = ImagingContext(NIfTId(a));
        end
        function this = accumulateNIfTId(this, varargin)
            for v = 1:length(varargin)
                if (isa(varargin{v}, 'mlfourd.INIfTIc'))
                    for w = 1:length( varargin{v})
                        this.concreteObj_ = this.concreteObj_.add( ...
                            mlfourd.NIfTId(varargin{v}.get(w)));
                    end
                else
                    this.concreteObj_ = this.concreteObj_.add( ...
                        mlfourd.NIfTId(varargin{v}));
                end
            end
        end
        
        function this = NIfTIcState(obj, h)
            if (~isa(obj, 'mlfourd.NIfTIc'))
                try
                    obj = mlfourd.NIfTIc(this.dedecorate(obj), 'dedecorate', true);
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'NIfTIcState.load does not support objects of type %s', class(obj));
                end
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

