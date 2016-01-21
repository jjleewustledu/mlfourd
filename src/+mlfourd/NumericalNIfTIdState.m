classdef NumericalNIfTIdState < mlfourd.ImagingState
	%% NumericalNIfTIdState  

	%  $Revision$
 	%  was created 16-Jan-2016 09:19:03
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
        function g = get.cellComposite(this)
            this.contexth_.changeState( ...
                mlfourd.CellCompositeState(this.concreteObj_, this.contexth_));
            g = this.contexth_.cellComposite;
        end
        function g = get.mgh(this)
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.concreteObj_, this.contexth_));
            g = this.contexth_.mgh;
        end
        function g = get.niftic(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIcState(this.concreteObj_, this.contexth_));
            g = this.contexth_.niftic;
        end   
        function g = get.niftid(this)
            g = this.dedecorateNIfTId(this.concreteObj_);
        end   
        function g = get.numericalNiftid(this)
            g = this.concreteObj_;
        end     
    end

	methods
        function a = atlas(this, varargin)
            %% ATLAS recursively adds images into an atlas.
            %  @param [varargin] are any ImagingContext objects.
            %  @return a is an ImagingContext with NIfTIdState.
            
            a = this.numericalNiftid;
            a = a.timeSummed;
            a = a / dipmedian(a);
            for v = 1:length(varargin)
                cached = varargin{v}.atlas;
                a = a + cached.niftid;
            end
            a = a.append_fileprefix('_atlas');
            a = a.append_descrip('atlas');
            import mlfourd.*;
            a = ImagingContext(NIfTId(a));
        end
 		function this = NumericalNIfTIdState(obj, h) 			
            if (~isa(obj, 'mlfourd.NumericalNIfTId'))
                try
                    obj = mlfourd.NumericalNIfTId(this.dedecorateNIfTId(obj));
                catch ME
                    handexcept(ME, 'mlfourd:castingError', ...
                        'NIfTIdState.ctor does not support objects of type %s', class(obj));
                end
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

