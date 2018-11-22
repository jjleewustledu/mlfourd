classdef (Abstract) AbstractImagingTool < handle & matlab.mixin.Copyable & mlio.HandleIOInterface
	%% ABSTRACTIMAGINGTOOL is the state and ImagingContext2 is the context forming a state design pattern for
    %  imaging tools.

	%  $Revision$
 	%  was created 10-Aug-2018 02:22:10 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    properties (Abstract)
        imagingInfo
        imgrec
        innerTypeclass
        logger
        viewer
    end
    
    properties 
        verbosity = 0;
    end
    
    methods  
        
        %% mlio.HandleIOInterface
        
        function c = char(this)
            c = this.fqfilename;
        end
        
        %% select states
        
        function selectBlurringTool(this, h)
            if (~isa(this, 'mlfourd.BlurringTool'))
                h.changeState( ...
                    mlfourd.BlurringTool(h, this.getInnerImaging));
            end
        end
        function selectDynamicsTool(this, h)
            if (~isa(this, 'mlfourd.DynamicsTool'))
                h.changeState( ...
                    mlfourd.DynamicsTool(h, this.getInnerImaging));
            end
        end
        function selectFilesystemTool(this, h)
            if (~isa(this, 'mlfourd.FilesystemTool'))
                this.save;
                h.changeState( ...
                    mlfourd.FilesystemTool(h, this.fqfilename));
            end
        end
        function selectIsNumericTool(this, h)
            if (~isa(this, 'mlfourd.IsNumericTool'))
                h.changeState( ...
                    mlfourd.IsNumericTool(h, this.getInnerImaging));
            end
        end
        function selectImagingFormatTool(this, h)
            if (~isa(this, 'mlfourd.ImagingFormatTool'))
                h.changeState( ...
                    mlfourd.ImagingFormatTool(h, this.getInnerImaging));
            end
        end
        function selectMaskingTool(this, h)
            if (~isa(this, 'mlfourd.MaskingTool'))
                h.changeState( ...
                    mlfourd.MaskingTool(h, this.getInnerImaging));
            end
        end
        function selectNumericalTool(this, h)
            if (~isa(this, 'mlfourd.NumericalTool'))
                h.changeState( ...
                    mlfourd.NumericalTool(h, this.getInnerImaging));
            end
        end
        function selectRegistrationTool(this, h)
            if (~isa(this, 'mlfourd.RegistrationTool'))
                h.changeState( ...
                    mlfourdfp.RegistrationTool(h, this.getInnerImaging));
            end
        end             
    end
    
    %% PROTECTED   
    
    methods (Abstract, Access = protected)
        iimg = getInnerImaging(this)
    end
    
    properties (Access = protected)
        contexth_
    end
    
    methods (Access = protected)         
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
        end
        
 		function this = AbstractImagingTool(h)
            assert(all(isvalid(h)));
            this.contexth_ = h;
 		end
    end 

    %% HIDDEN
    
    methods (Hidden)
        function this = changeState(this, s)
            this.contexth_.changeState(s);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

