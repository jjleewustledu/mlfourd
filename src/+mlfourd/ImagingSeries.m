classdef ImagingSeries < mlfourd.ImagingComponent
	%% IMAGINGSERIES is the interface for leaves in composite design patterns.
    
	%  Version $Revision: 2608 $ was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingSeries.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImagingSeries.m 2608 2013-09-08 00:14:08Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    methods (Static)
        function this = createFromFilename(fn, varargin)
            %% CREATEFROMFILENAME returns an ImagingSeries object iff fn is a filename
            %                     to a NIfTI that is available on the fileesystem
            %  Usage:   imaging_series_obj = ImgagingSeries.createFromFilename(nifti_filename);
            
            import mlfourd.*;
            this = ImagingSeries.createFromINIfTI(NIfTId.load(fn), varargin{:});
        end
        function this = createFromINIfTI(nii, varargin)
            assert(isa(nii, 'mlfourd.INIfTI'));
            import mlfourd.*;
            ial = ImagingArrayList;
            ial.add(nii);
            this = ImagingSeries(ial, varargin{:});
        end
    end  
    
	methods
        function obj  = clone(this)
            import mlfourd.*;
            if (length(this) > 1)
                obj = ImagingComposite(this); return; end
            obj = ImagingSeries(this);
        end
 		function this = ImagingSeries(varargin)
 			%% IMAGINGSERIES expects a cell-array list
            
            this = this@mlfourd.ImagingComponent(varargin{:});
            assert(1 == length(this));
 		end %  ctor          

    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

