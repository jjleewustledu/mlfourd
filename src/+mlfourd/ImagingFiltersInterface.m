classdef ImagingFiltersInterface 
	%% IMAGINGPARSERINTERFACE interface for finding image objects or image filenames
	%  $Revision: 2466 $
 	%  was created $Date: 2013-08-10 21:27:30 -0500 (Sat, 10 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-10 21:27:30 -0500 (Sat, 10 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingParserInterface.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: ImagingParserInterface.m 2466 2013-08-11 02:27:30Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
        IMAGING_SUFFIXES = {'.nii.gz' '.nii' '.hdr'};
    end  

	methods (Abstract, Static)
        obj  = brightest(obj)
        obj  = isMcf(obj)
        obj  = isMr(obj)
        obj  = isPet(obj)
        obj  = leastEntropy(obj)
        obj  = longestDuration(obj)
        obj  = lowestSeriesNumber(obj)
        obj  = maximum(obj)
        obj  = minimum(obj)
        obj  = mostEntropy(obj)
        obj  = mostPixels(obj)
        obj  = notIsMcf(obj)
        obj  = notIsMr(obj)
        obj  = notIsPet(obj)
        obj  = smallestVoxels(obj)
        obj  = timeDependent(obj)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

