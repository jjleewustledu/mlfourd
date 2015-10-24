classdef ImagingDirector 
	%% IMAGINGDIRECTOR is the client interface that supports ImageBuilder and its subclasses
    %
    %  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ImagingDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImagingDirector.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Access = 'protected')
        builder_
    end

    methods (Static)  
        function st = statsSample
        end      
        function st = stats(rois)
        end
        function      slices(   rois, ref)
        end
    end
    
    methods
        function      print(this, fname)
        end
        function      printslice(this, fname)
        end
        function      printmontage(this, fname)
        end        
        function      printexcel(this, fname)
        end
    end
    
	methods (Access = 'protected')
 		function this = ImagingDirector(bldr) 
 			%% IMAGINGDIRECTOR 
 			%  Usage:  prefer creation methods
            
            assert(isa(bldr, 'mlfourd.ImageBuilder'));
            this.builder_ = bldr;
 		end % ImagingDirector (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

