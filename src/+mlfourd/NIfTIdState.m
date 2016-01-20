classdef NIfTIdState < mlfourd.NumericalState 
	%% NIFTIDSTATE has-an mlfourd.ImagingComponentState 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlfourd.FilenameState, mlpatterns.State, mlfourd.DoubleState

	%  $Revision$
 	%  was created 21-Oct-2015 00:44:09
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	properties (Dependent)
        niftid
        niftic
        numericalNiftid
        numericalNiftic
 	end 

	methods %% GET
        function g = get.niftid(this)
            g = this.concreteState_;
        end   
        function g = get.niftic(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIcState(this.concreteState_, this.contextH_));
            g = this.contextH_.niftic;
        end   
        function g = get.numericalNiftid(this)            
            g = mlfourd.NumericalNIfTId(this.concreteState_);
        end   
        function g = get.numericalNiftic(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIcState(this.concreteState_, this.contextH_));
            g = this.contextH_.numericalNiftic;
        end        
    end
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.NIfTIdState(varargin{:});
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
            
            a = this.niftid;
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
        function this = NIfTIdState(obj, h)
            if (~isa(obj, 'mlfourd.NIfTId'))
                try
                    obj = this.dedecorate(obj);
                    obj = mlfourd.NIfTId(obj, 'dedecorate', true);
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'NIfTIdState.load does not support objects of type %s', class(obj));
                end
            end
            this.concreteState_ = obj;
            this.contextH_ = h;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

