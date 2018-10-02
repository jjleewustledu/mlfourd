classdef (Abstract) INIfTI
	%% INIFTI provide a minimal set of imaging properties, methods

	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified 31-May-2017 16:23:00
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.  Copyright 2015, 2017 John J. Lee.
    
	properties (Abstract)  
        hdr % See also:  mlfourd.ImagingInfo
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
        orient % Analyze 7.5 field := RADIOLOGICAL, NEUROLOGICAL; deprecated by NIfTI-1
        originalType
        pixdim
        seriesNumber
        
        imagingInfo
        logger
        separator % for descrip & label properties, not for filesystem behaviors
        stack
        viewer
    end 
    
	methods (Abstract) 
        addLog(this, varargin)
        append_descrip(this, s)
        prepend_descrip(this, s)
        double(this)
        duration(this)
        append_fileprefix(this, s)
        prepend_fileprefix(this, s)
        fov(this)
        freeview(this, varargin)
        fslentropy(this)
        fslEntropy(this)
        fsleyes(this, varargin)
        fslview(this, varargin)
        hist(this, varargin)
        matrixsize(this)
        prod(this, varargin)
        rank(this)
        save(this)
        saveas(this, fqfn)
        scrubNanInf(this)
        single(this)
        size(this)
        sum(this, varargin)
        tempFqfilename(this)
        view(this, varargin)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

