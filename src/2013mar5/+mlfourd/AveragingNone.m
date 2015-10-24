classdef AveragingNone < mlfourd.AveragingType 
	%% AVERAGINGNONE is a place-holder for AveragingStrstegy for the case of no averaging
	%  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AveragingNone.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: AveragingNone.m 2318 2013-01-20 06:52:48Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties
       blur = 0;
   end

	methods 

 		function this = AveragingNone(varargin) 
 			this = this@mlfourd.AveragingType(varargin{:}); 
 		end %  ctor 
        
        function imgcmp = average(~, imgcmp) 
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

