classdef MRImagingComponent < mlfourd.ImagingComponent
	%% MRIMAGINGCOMPONENT is an abstract interface
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/MRImagingComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: MRImagingComponent.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
	
    properties 
        mrBlur
    end

    methods (Access = 'protected')
 		function this = MRImagingComponent(cal, varargin)
 			%% MRIMAGINGCOMPONENT is abstract
            %  this = this@mlfourd.MRImagingComponent(cell_array_list[, varargin]);
            
			this = this@mlfourd.ImagingComponent(cal, varargin{:});
 		end % MRImagingComponent (ctor) 
    end  % protected methods

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
