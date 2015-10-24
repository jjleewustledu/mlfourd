classdef ImagingState < mlio.IOInterface
	%% IMAGINGSTATE   
    %  See also:  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlfourd.ImagingLocation, mlpatterns.State

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingState.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	 
	properties (Abstract)
        mgh
        niftid
        nifti
        imcomponent
    end
    
    methods (Abstract, Static)
        this = load(obj, h)
    end

    methods (Static)
        
        %% KLUDGE to manage MGHState
        
        function fname = ensureNiigz(fname) 
            assert(ischar(fname), 'mlfourd.ImagingState.ensureNiigz does not support objects of class %s', class(fname));
            if (lstrfind(fname, '.mgz') || lstrfind(fname, '.mgh'))
                fname = mlsurfer.MGH.mghFilename2niiFilename(fname); end 
        end
        function fname = ensureMgz(fname)
            assert(ischar(fname), 'mlfourd.ImagingState.ensureMgz does not support objects of class %s', class(fname));
            if (lstrfind(fname, '.nii.gz'))
                fname = mlsurfer.MGH.mri_convert(fname); end
        end
    end
    
    methods
        function this = changeState(this, s)
            this.contextHandle_.changeState(s);
        end
    end
    
    %% PROTECTED
    
    properties (Access = 'protected')
        contextHandle_
    end
    
    methods (Access = 'protected')
        function this = ImagingState
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

