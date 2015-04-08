classdef (Abstract) NIfTIdInterface
	%% NIFTIDINTERFACE provide a minimal set of imaging properties, methods
    
	%  $Revision: 2608 $
 	%  was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NIfTIdInterface.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: NIfTIdInterface.m 2608 2013-09-08 00:14:08Z jjlee $

    properties (Constant) 
        FILETYPE     = 'NIFTI_GZ';
        FILETYPE_EXT = '.nii.gz';
    end
    
	properties (Abstract)   
        creationDate
        descrip
        entropy
        hdxml
        label
        machine
        negentropy
        orient
        seriesNumber
        
        img
        bitpix
        datatype
        mmppix
        pixdim
    end 
    
	methods (Abstract) 
        char(this)
        double(this)
        duration(this)
        ones(this)
        rank(this)
        scrubNanInf(this)
        single(this)
        size(this)
        zeros(this)
        
        forceDouble(this)
        forceSingle(this)
        [tf,msg] = isequal(this, n)
        [tf,msg] = isequaln(this, n)
        prepend_fileprefix(this, s)
        append_fileprefix(this, s)
        prepend_descrip(this, s)
        append_descrip(this, s)
        
        clone(this)
        makeSimilar(this)
        freeview(this)
        fslview(this)
        imshow(this)
        imtool(this)
        mlimage(this)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

