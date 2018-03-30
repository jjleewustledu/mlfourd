classdef MRImagingSeries < mlfourd.ImagingSeries
	%% MRIMAGINGSERIES is a leaf in a composite design pattern
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/MRImagingSeries.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: MRImagingSeries.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 


 		function this = MRImagingSeries(varargin)
 			%% MRIMAGINGSERIES 
 			%  Usage:  prefer creation methods 

 			this = this@mlfourd.ImagingSeries(varargin{:}); 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

