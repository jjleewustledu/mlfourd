classdef PETImagingComposite < mlfourd.ImagingComposite
	%% PETIMAGINGCOMPOSITE implements the composite design pattern with ImagingComponent and PETImaging leaves%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/PETImagingComposite.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: PETImagingComposite.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function this = PETImagingComposite(bldr, varargin) 
 			%% PETIMAGINGCOMPOSITE 
 			%  Usage:  prefer construction by PETBuilder 
            
            this = this@mlfourd.ImagingComposite(bldr, varargin{:});
 		end % PETImagingComposite (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

