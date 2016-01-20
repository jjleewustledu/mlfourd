classdef INIfTI
	%% INIFTI provide a minimal set of imaging properties, methods

	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
    properties (Constant) 
        FILETYPE     = 'NIFTI_GZ'
        FILETYPE_EXT = '.nii.gz'
    end
    
	properties (Abstract)
        img
        
        bitpix 
        creationDate
        datatype
        descrip
        entropy
        hdxml
        label
        machine
        mmppix
        negentropy
        orient
        pixdim
        seriesNumber        
    end 
    
	methods (Abstract) 
        
        %% for NIfTId and other concrete imaging classes
        
        this = clone(this)
        [tf,msg] = isequal(this, n)
        [tf,msg] = isequaln(this, n)
        this = makeSimilar(this)
        
        %% for AbstractNIfTId and other abstract imaging classes
        
        char(this)
        append_descrip(this, s)
        prepend_descrip(this, s)
        double(this)
        duration(this)
        append_fileprefix(this, s)
        prepend_fileprefix(this, s)
        fov(this)
        matrixsize(this)
        ones(this)
        rank(this)
        scrubNanInf(this)
        single(this)
        size(this)
        zeros(this)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

