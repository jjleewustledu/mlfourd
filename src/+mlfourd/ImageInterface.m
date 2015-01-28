classdef ImageInterface 
	%% IMAGEINTERFACE provides the interface for AbstractImage
	
	%  Version $Revision: 2578 $ was created $Date: 2013-08-29 02:57:22 -0500 (Thu, 29 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-29 02:57:22 -0500 (Thu, 29 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImageInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImageInterface.m 2578 2013-08-29 07:57:22Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Constant) 
        FILETYPE     = 'NIFTI_GZ';
        FILETYPE_EXT = '.nii.gz';
    end
    
	properties (Abstract) 
        bitpix  
        creationDate;
        datatype
        descrip
        entropy
        filetype
        img
        mmppix
        negentropy
        pixdim
    end 
    
	methods (Abstract)
        bsxfun(this, pfun, b)
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
        
        norm(this)
        abs(this)
        atan2(this, b)
        hypot(this, b)
        diff(this)
        
        char(this)
        double(this)
        duration(this)
        ensureNumeric(this)
        makeSimilar(this)
        ones(this)
        prod(this)
        prodSize(this)
        rank(this)
        scrubNanInf(this)
        single(this)
        size(this)
        sum(this)
        zeros(this)
        
        dip_image(this)
        dipshow(this)
        dipmax(this)
        dipmean(this)
        dipmin(this)
        dipprod(this)
        dipstd(this)
        dipsum(this)
        
        imclose(this, varargin)
        imdilate(this, varargin)
        imerode(this, varargin)
        imopen(this, varargin)
        imshow(this, slice, varargin)
        imtool(this, slice, varargin)
        mlimage(this)
        montage(this, varargin)
        matrixsize(this)
        fov(this)
    end 


	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

