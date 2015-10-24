classdef MRIDirector < mlfourd.ImagingDirector
	%% MRIDIRECTOR is the client wrapper for building MRI imaging analyses; 
    %              takes part in builder design patterns
	
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/MRIDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: MRIDirector.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    methods (Static)

        function this = flirtToAtlas(this, img, atl)
        end
        function this = fnirtToAtlas(this, img, atl)
        end
        function this = invwarpROIs(this, rois, ref)
        end
    end
    
    methods
 
    end
    
    methods (Access = 'protected')
 		function this = MRIDirector(bldr) 
 			%% MRIDIRECTOR 
 			%  Usage:  prefer creation methods
            
            assert(isa(bldr, 'mlfsl.MRIBuilder'));
			this = this@mlfourd.ImagingDirector(bldr);
 		end % MRIDirector (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

