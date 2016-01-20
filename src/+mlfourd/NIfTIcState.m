classdef NIfTIcState < mlfourd.ImagingState
	%% NIFTICSTATE  

	%  $Revision$
 	%  was created 15-Jan-2016 23:01:37
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
	properties (Dependent)
        niftid
        niftic
        numericalNiftid
        numericalNiftic
 	end 

	methods %% GET
        function g = get.niftid(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState(this.concreteState_, this.contextH_));
            g = this.contextH_.niftid;
        end   
        function g = get.niftic(this)
            g = this.concreteState_;
        end   
        function g = get.numericalNiftid(this)       
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState(this.concreteState_, this.contextH_));
            g = this.contextH_.numericalNiftid;     
        end   
        function g = get.numericalNiftic(this)
            niic = mlfourd.NIfTIc;
            iter = this.concreteState_.createIterator;
            while (iter.hasNext)
                niic = niic.add(mlfourd.NumericalNIfTId(iter.next));
            end
            g = niic;
        end       
    end
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.NIfTIcState(varargin{:});
        end
        function obj  = dedecorate(obj)
            while (isa(obj, 'mlfourd.NIfTIdecorator'))
                obj = obj.component;
            end
        end
    end
    
    methods 
        function a = atlas(this, varargin)
            %% ATLAS
            %  @param [varargin] are any ImagingContext objects.
            %  @return a is an ImagingContext with NIfTIdState.
            
            a = this.niftic;
            a = a.prepend_fileprefix('atlas');
            a = a.prepend_descrip('atlas');
            a = a/dipmedian(a);
            for v = 1:length(varargin)
                a = a + varargin{v}.atlas;
            end
            a = mlfourd.ImagingContext(a);
        end
    end

    
    %% PROTECTED
    
    methods (Access = protected)
        function this = NIfTIcState(obj, h)
            if (~isa(obj, 'mlfourd.NIfTIc'))
                try
                    obj = this.dedecorate(obj);
                    obj = mlfourd.NIfTIc(obj, 'dedecorate', true);
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'NIfTIcState.load does not support objects of type %s', class(obj));
                end
            end
            this.concreteState_ = obj;
            this.contextH_ = h;
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

