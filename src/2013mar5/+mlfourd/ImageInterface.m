classdef ImageInterface 
	%% IMAGEINTERFACE provides the interface for AbstractImage
	
	%  Version $Revision: 2321 $ was created $Date: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImageInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ImageInterface.m 2321 2013-01-21 06:17:57Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Abstract) 
        bitpix  
        datatype
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
        pixdim
    end 
    
    methods (Abstract, Static)
        load
    end

	methods (Abstract)
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
        horzcat(this, varargin)
        isequal(this, b)
        length(this) % of last non-singleton dimension
        makeSimilar(this)
        ones(this)
        prod(this)
        rank(this)
        save(this)
        saveas(this, fnames)
        single(this)
        size(this)
        vertcat(this, varargin)
        zeros(this)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

