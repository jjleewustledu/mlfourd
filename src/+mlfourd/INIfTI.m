classdef INIfTI
	%% INIFTI provide a minimal set of imaging properties, methods

	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified 31-May-2017 16:23:00
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.  Copyright 2015, 2017 John J. Lee.
    
	properties (Abstract)        
        bitpix 
        creationDate
        datatype
        descrip
        entropy
        hdxml
        img
        label
        machine
        mmppix
        negentropy
        orient
        pixdim
        seriesNumber        
    end 
    
	methods (Abstract) 
        char(this)
        append_descrip(this, s)
        prepend_descrip(this, s)
        double(this)
        duration(this)
        append_fileprefix(this, s)
        prepend_fileprefix(this, s)
        fov(this)
        matrixsize(this)
        rank(this)
        scrubNanInf(this)
        single(this)
        size(this)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

