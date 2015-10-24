classdef ImageBuilderInterface 
	%% IMAGEBUILDERINTERFACE interface for mlfourd.ImageBuilder
	
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ImageBuilderInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImageBuilderInterface.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Abstract)
        theProduct
        studyPath
        sessionPath
        foreground
        converter
        averaging
        verbose
    end 

    methods (Static, Abstract)
        bldr = createFromConverter(cverter)
        cmp  = brightest(cmps)
        cmp  = lowestSeriesNumber(cmps)
        cmp  = mostEntropy(cmps)
        cmp  = mostNegentropy(cmps)
        cmp  = smallestVoxels(cmps)
        cmp  = longestDuration(cmps)
        cmps = timeDependent(cmps)
        cmps = timeIndependent(cmps)
        cmps = notPet(cmps)
    end
    
	methods (Abstract)
        cmp  = average(cmp)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

