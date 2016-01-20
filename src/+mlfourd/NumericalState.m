classdef NumericalState < mlfourd.ImagingState & mlpatterns.Numerical & mlpatterns.DipNumerical
	%% NUMERICALSTATE  

	%  $Revision$
 	%  was created 16-Jan-2016 09:19:03
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		
 	end

	methods 
		  
 		function this = NumericalState(varargin)
 			this = this@mlfourd.ImagingState(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

