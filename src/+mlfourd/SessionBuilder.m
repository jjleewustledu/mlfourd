classdef SessionBuilder < mlfsl.FslBuilder
	%% SESSIONBUILDER is a design-pattern builder of imaging leaves
	%  Version $Revision: 2386 $ was created $Date: 2013-03-06 22:27:39 -0600 (Wed, 06 Mar 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-03-06 22:27:39 -0600 (Wed, 06 Mar 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/SessionBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: SessionBuilder.m 2386 2013-03-07 04:27:39Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function this = SessionBuilder(cvert, varargin) 
 			%% SESSIONBUILDER 
 			%  Usage:  obj = SessionBuilder(converter[, foreground_object])
			
            this = this@mlfsl.FslBuilder(cvert, varargin{:});
 		end % SessionBuilder (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

