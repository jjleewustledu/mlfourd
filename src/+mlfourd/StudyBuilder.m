classdef StudyBuilder < mlfsl.FslBuilder
	%% STUDYBUILDER is a design-pattern builder of imaging composites
	%  Version $Revision: 2627 $ was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/StudyBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: StudyBuilder.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		function this = StudyBuilder(cvert, varargin) 
 			%% STUDYBUILDER 
 			%  Usage:  obj = StudyBuilder(converter[, foreground_object])	 
            
            this = this@mlfsl.FslBuilder(cvert, varargin{:});
 		end % StudyBuilder (ctor) 
    end % methods    

    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

