classdef PETImagingSeriesSet < mlfourd.PETImagingComposite 
	%% PETIMAGINGSERIESSET takes part in a composite design pattern
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/PETImagingSeriesSet.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: PETImagingSeriesSet.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function afun() 
 			%% AFUN  
 			%  Usage:   
 		end % afun 
 		function this = PETImagingSeriesSet(bldr, varargin) 
 			%% PETIMAGINGSERIESSET 
 			%  Usage:  prefer creation methods 

 			this = this@mlfourd.PETImagingComposite(bldr, varargin{:}); 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

