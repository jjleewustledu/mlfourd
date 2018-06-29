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
        ext
        filetype % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr
        img
        originalType
        untouch
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

