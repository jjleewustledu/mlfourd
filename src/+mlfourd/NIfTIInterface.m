classdef NIfTIInterface < mlfourd.VoxelInterface & mlio.IOInterface & mlanalysis.NumericalInterface & mlanalysis.DipInterface
	%% NIFTIINTERFACE provide a rich set of voxel, i/o, numerical-array methods
    
	%  $Revision: 2608 $
 	%  was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NIfTIInterface.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: NIfTIInterface.m 2608 2013-09-08 00:14:08Z jjlee $

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
    end 

	methods (Abstract) 
        imclose(this, varargin)
        imdilate(this, varargin)
        imerode(this, varargin)
        imopen(this, varargin)
        imshow(this, slice, varargin)
        imtool(this, slice, varargin)
        mlimage(this)
        montage(this, varargin)
        montage_coronal(this, varargin)
        montage_sagittal(this, varargin)
        matrixsize(this)
        fov(this)
        
        char(this)
        double(this)
        duration(this)
        ones(this)
        prod(this)
        prodSize(this)
        rank(this)
        scrubNanInf(this)
        single(this)
        size(this)
        sum(this)
        zeros(this)
        
        forceDouble(this)
        forceSingle(this)
        prepend_fileprefix(this, s)
        append_fileprefix(this, s)
        prepend_descrip(this, s)
        append_descrip(this, s)
        
        makeSimilar(this)
        clone(this)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

