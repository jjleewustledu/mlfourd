classdef VoxelInterface 
	%% VOXELINTERFACE 
	
	%  Version $Revision: 2608 $ was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/VoxelInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: VoxelInterface.m 2608 2013-09-08 00:14:08Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Abstract) 
        bitpix
        datatype
        img
        mmppix
        pixdim
    end 
    

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

