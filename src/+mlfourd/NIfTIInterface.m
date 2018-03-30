classdef (Abstract) NIfTIInterface < ...
        mlfourd.INIfTI & ...
        mlio.IOInterface & ...
        mlanalysis.NumericalInterface & ...
        mlanalysis.DipInterface
	%% NIFTIINTERFACE provide a rich set of voxel, i/o, numerical-array methods.
    %  @deprecated prefer using INIfTI, INIfTId.
    
	%  $Revision: 2608 $
 	%  was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NIfTIInterface.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: NIfTIInterface.m 2608 2013-09-08 00:14:08Z jjlee $

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

