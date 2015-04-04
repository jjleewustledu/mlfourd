classdef (Abstract) ImageProcessingInterface  
	%% IMAGEPROCESSINGINTERFACE   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
    methods (Abstract)        
        imclose(this, varargin) % Consider moving to a decorator pattern
        imdilate(this, varargin)
        imerode(this, varargin)
        imopen(this, varargin)
        imshow(this, slice, varargin)
        imtool(this, slice, varargin)
        mlimage(this)
        montage(this, varargin)
        montage_coronal(this, varargin)
        montage_sagittal(this, varargin)
        matrixsize(this)
        fov(this)        
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

