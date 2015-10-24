classdef ImageInterface 
	%% IMAGEINTERFACE provides the interface for AbstractImage
	
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ImageInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImageInterface.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Abstract) 
        bitpix  
        debugging
        descrip
        entropy
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        img
        mmppix
        negentropy
        noclobber
 	end 

	methods (Abstract)
        makeSimilar(this)
        save(this)
        saveas(this, fnames)
        plus(this, b)
        minus(this, b)
        times(this, b)
        rdivide(this, b)
        ldivide(this, b)
        power(this, b)
        max(this, b)
        min(this, b)
        rem(this, b) % remainder after division
        mod(this, b)
        eq(this, b)
        ne(this, b)
        lt(this, b)
        le(this, b)
        gt(this, b)
        ge(this, b)
        and(this, b)
        or(this, b)
        xor(this, b)
        not(this, b)
        char(this) % fully-qualified filename
        double(this)
        length(this) % of last non-singleton dimension
        size(this)
        ones(this)
        prod(this)
        rank(this)
        single(this)
        zeros(this)        
        isequal(this, b)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

