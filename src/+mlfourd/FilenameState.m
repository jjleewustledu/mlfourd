classdef FilenameState < mlfourd.ImagingState
	%% FILENAMESTATE 
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlpatterns.State, mlfourd.DoubleState.
    %  TODO:      setting filenames should not change state to FilenameState.  

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/FilenameState.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FilenameState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	
	properties (Dependent)
        composite
        mgh
        nifti
        niftid
    end
    
    methods %% GET
        function f  = get.composite(this)
            this.contextH_.changeState( ...
                mlfourd.ImagingComponentState(this.fqfilename, this.contextH_));
            f = this.contextH_.composite;
        end
        function f  = get.mgh(this)
            this.contextH_.changeState( ...
                mlfourd.MGHState(this.fqfilename, this.contextH_));
            f = this.contextH_.mgh;
        end
        function f  = get.nifti(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIState(this.fqfilename, this.contextH_));
            f = this.contextH_.nifti;
        end
        function f  = get.niftid(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState(this.fqfilename, this.contextH_));
            f = this.contextH_.niftid;
        end
    end
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.FilenameState(varargin{:});
        end
    end
    
    methods 
        function a = atlas(this, varargin)
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState(this.fqfilename, this.contextH_));
            a = this.contextH_.atlas(varargin{:});
        end
        function view(~)
        end
    end
    
    %% PROTECTED
    
    methods (Access = protected)
        function this = FilenameState(obj, h)
            this.concreteState_ = mlio.ConcreteIO(obj);
            this.contextH_ = h;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

