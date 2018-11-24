classdef ImagingContext < handle & mlfourd.ImagingContext2
    
	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingContext.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a).  Copyright 2017 John Joowon Lee.
 	%  $Id: ImagingContext.m 2627 2013-09-16 06:18:10Z jjlee $ 
    
    methods
        function this = ImagingContext(varargin)
            this = mlfourd.ImagingContext2(varargin{:});
        end
        function c    = clone(this)
            %% CLONE simplifies calling the copy constructor.
            %  @return deep copy on new handle
            
            c = mlfourd.ImagingContext(this);
        end
    end  
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

