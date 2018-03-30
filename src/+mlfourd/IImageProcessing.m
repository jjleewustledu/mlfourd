classdef (Abstract) IImageProcessing  
	%% IIMAGEPROCESSING   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
    methods (Abstract)        
        imclose(this, varargin) 
        imdilate(this, varargin)
        imerode(this, varargin)
        imopen(this, varargin)
        imshow(this, slice, varargin)
        imtool(this, slice, varargin)
        mlimage(this)
        montage(this, varargin)   
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

