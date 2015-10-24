classdef AbstractImageBuilder 
	%% ABSTRACTIMAGEBUILDER is the interface for all concrete builders
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/AbstractImageBuilder.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: AbstractImageBuilder.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Abstract)
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        
        studyPath
        sessionPath
        foreground
        reference
        atlas
        theProduct
    end
    
    methods (Abstract)
        coregister(    this, imgs, ref)
        createRois(    this, map)
        sampleWithRois(this, imgs, rois)
        slices(        this, imgs, ref)
        slicesdir(     this, imgs, opts)
        clean(         this)
        resetCache(    this)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

