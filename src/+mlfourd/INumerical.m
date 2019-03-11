classdef (Abstract) INumerical 
	%% INUMERICAL  

	%  $Revision$
 	%  was created 22-Jan-2018 16:18:20 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.3.0.713579 (R2017b) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    methods (Abstract)
       blurred(this, blur)
       masked(this)
       thresh(this, t)
       threshp(this, p)
       timeAveraged(this)
       timeContracted(this, varargin)
       timeSummed(this)
       uthresh(this, u)
       uthreshp(this, p)
       volumeAveraged(this)
       volumeContracted(this, varargin)
       volumeSummed(this)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

