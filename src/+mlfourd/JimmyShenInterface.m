classdef JimmyShenInterface  
	%% JIMMYSHENINTERFACE describes the code base that is the foundation of the the mlfourd package.
    %  http://research.baycrest.org/~jimmy/
    %  http://www.mathworks.com/matlabcentral/fileexchange/authors/20638

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 
	properties (Abstract)  
        img      
        ext
        filetype % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr
        originalType
        untouch
    end 

    methods (Abstract)
%         [new_img,new_M] = affine(old_img, old_M, varargin)
%         nii = load_nii(filename, varargin)
%         nii = load_untouch_nii(filename, varargin)
%         reslice_nii(old_fn, new_fn, varargin)
%         save_nii(nii, filename, varargin)
%         save_untouch_nii(nii, filename)
%         status = view_nii(nii, varargin)
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

