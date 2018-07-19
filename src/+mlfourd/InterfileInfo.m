classdef InterfileInfo < mlfourd.ImagingInfo 
	%% INTERFILEINFO  

	%  $Revision$
 	%  was created 27-Jun-2018 01:19:39 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties (Dependent)
 		
 	end

	methods 		  
 		function this = InterfileInfo(varargin)
 			%% ANALYZE75INFO
 			%  @param .
 			
            this = this@mlfourd.ImagingInfo(varargin{:});
 		end
  	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

