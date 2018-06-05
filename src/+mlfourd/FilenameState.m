classdef FilenameState < mlfourd.ImagingState
	%% FILENAMESTATE 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.CellCompositeState, mlpatterns.State, mlfourd.DoubleState.
    %  TODO:      setting filenames should not change state to FilenameState.  

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/FilenameState.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FilenameState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	
    methods
        
        %% state changes
        
        function f = fourdfp(this)
            this.contexth_.changeState( ...
                mlfourd.FourdfpState(this.fqfilename, this.contexth_));
            f = this.contexth_.fourdfp;
        end
        function f = mgh(this)
            this.contexth_.changeState( ...
                mlfourd.MGHState(this.fqfilename, this.contexth_));
            f = this.contexth_.mgh;
        end
        function f = niftid(this)
            this.contexth_.changeState( ...
                mlfourd.NIfTIdState(this.fqfilename, this.contexth_));
            f = this.contexth_.niftid;
        end
        function f = numericalNiftid(this)
            this.contexth_.changeState( ...
                mlfourd.NumericalNIfTIdState(this.fqfilename, this.contexth_));
            f = this.contexth_.numericalNiftid;
        end
        
        %%
        
        function     view(this, varargin)
            that = this.niftid;
            that.viewer = this.viewer;
            that.view(varargin{:});
        end
        
        function this = FilenameState(obj, h)
            try
                obj = mlio.ConcreteIO(obj);
            catch ME
                handexcept(ME, 'mlfourd:castingError', ...
                    'FilenameState does not support objects of type %s', class(obj));
            end
            this.concreteObj_ = obj;
            this.contexth_ = h;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

