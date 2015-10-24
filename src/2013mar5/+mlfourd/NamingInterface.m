classdef NamingInterface
	%% NAMINGINTERFACE is an interface for file-naming conventions
	%  $Revision: 2308 $
 	%  was created $Date: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/NamingInterface.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: NamingInterface.m 2308 2013-01-12 23:51:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties
        FSL_DATA_STANDARD = '/usr/local/fsl/data/standard';
        backupFolder
    end
    
    methods (Static)
        fn   = formFilename(varargin)
        prts = splitFilename(varargin)
        str  = beforeToken(varargin)
        str  = afterToken(varargin)
    end
    
	methods (Abstract)
        obj = t1(this)
        obj = t2(this)
        obj = flair(this)
        obj = flair_abs(this)
        obj = gre(this)
        obj = tof(this)
        obj = ep2d(this)
        obj = ep2dMeanvol(this)
        obj = h15o(this)
        obj = o15o(this)
        obj = h15oMeanvol(this)
        obj = o15oMeanvol(this)
        obj = c15o(this)
        obj = tr(this)
        
        tf  = isPet(this, obj)
        tf  = isMr(this, obj)
        tf  = isAtlas(this, obj)
        tf  = onPet(this, obj)
        tf  = onMr(this, obj)
        tf  = onAtlas(this, obj)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

