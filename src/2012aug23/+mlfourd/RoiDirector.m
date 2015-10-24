classdef RoiDirector 
	%% ROIDIRECTOR is a client interface for builders of ROIs
    %
    %  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/RoiDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: RoiDirector.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    methods (Static)
        function st = stats
        end
        
    end
    
	methods (Access = 'protected')

 		function this = RoiDirector(bldr) 
 			%% IMAGINGDIRECTOR 
 			%  Usage:  prefer creation methods
            
            assert(isa(bldr, 'mlfourd.ImageBuilder'));
            this.builder_ = bldr;
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

