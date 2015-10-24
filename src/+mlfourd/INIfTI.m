classdef INIfTI 
	%% INIFTI provide a minimal set of imaging properties, methods

	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
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
        
        prod(this)
        sum(this)
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
        mlimage(this)
        imshow(this)
        imtool(this)
        imclose(this, varargin) 
        imdilate(this, varargin)
        imerode(this, varargin)
        imopen(this, varargin)        
        montage(this, varargin)        
        matrixsize(this)
        fov(this)   
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

