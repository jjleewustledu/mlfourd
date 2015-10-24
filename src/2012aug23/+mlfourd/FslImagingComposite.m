classdef FslImagingComposite < mlfourd.FslImagingComponent 
	%% FSLIMAGINGCOMPOSITE takes part in a composite design pattern
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/FslImagingComposite.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: FslImagingComposite.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Dependent) 
 		NIfTI
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function nii   = get.NIfTI(this)
            cal = {};
            for c = 1:length(this) %#ok<FORFLG>
                cal{c} = this.get(c).NIfTI; %#ok<PFBNS>
            end
            nii = mlpatterns.CellArrayList;
            nii.add(cal);
        end
        
        function this = FslImagingComposite(varargin)
 			%% FSLIMAGINGCOMPOSITE 
 			%  Usage:  prefer creation methods 

 			this = this@mlfourd.FslImagingComponent(varargin{:}); 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

