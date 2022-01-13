classdef (Abstract) AbstractImagingTool < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlio.IOInterface
	%% ABSTRACTIMAGINGTOOL defines an interface for encapsulating the behavior associated with particular states of 
    %  ImagingContext2.  
    %
	%  $Revision$
 	%  was created 10-Aug-2018 02:22:10 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%  It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.

    properties (Dependent)        
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        noclobber

        compatibility
        filesystem
        logger
        viewer
    end
    
    methods

        %% SET/GET
        
        function     set.filename(this, s)
            this.imagingFormat_.filename = s;
        end
        function g = get.filename(this)
            g = this.imagingFormat_.filename;
        end
        function     set.filepath(this, s)
            this.imagingFormat_.filepath = s;
        end
        function g = get.filepath(this)
            g = this.imagingFormat_.filepath;
        end
        function     set.fileprefix(this, s)
            this.imagingFormat_.fileprefix = s;
        end
        function g = get.fileprefix(this)
            g = this.imagingFormat_.fileprefix;
        end
        function     set.filesuffix(this, s)
            this.imagingFormat_.filesuffix = s;
        end
        function g = get.filesuffix(this)
            g = this.imagingFormat_.filesuffix;
        end
        function     set.fqfilename(this, s)
            this.imagingFormat_.fqfilename = s;
        end
        function g = get.fqfilename(this)
            g = this.imagingFormat_.fqfilename;
        end
        function     set.fqfileprefix(this, s)
            this.imagingFormat_.fqfileprefix = s;
        end
        function g = get.fqfileprefix(this)
            g = this.imagingFormat_.fqfileprefix;
        end
        function     set.fqfn(this, s)
            this.imagingFormat_.fqfn = s;
        end
        function g = get.fqfn(this)
            g = this.imagingFormat_.fqfn;
        end
        function     set.fqfp(this, s)
            this.imagingFormat_.fqfp = s;
        end
        function g = get.fqfp(this)
            g = this.imagingFormat_.fqfp;
        end
        function     set.noclobber(this, s)
            this.imagingFormat_.noclobber = s;
        end
        function g = get.noclobber(this)
            g = this.imagingFormat_.noclobber;
        end

        function     set.compatibility(this, s)
            assert(islogical, s)
            this.compatibility_ = s;
        end
        function g = get.compatibility(this)
            g = this.compatibility_;
        end
        function g = get.filesystem(this)
            try
                g = copy(this.imagingFormat_.filesystem);
            catch ME
                handwarning(ME)
                g = [];
            end
        end
        function g = get.logger(this)
            try
                g = copy(this.imagingFormat_.logger);
            catch ME
                handwarning(ME)
                g = [];
            end
        end
        function g = get.viewer(this)
            g = this.imagingFormat_.viewer;
        end
               
        %% select states
        
        function selectBlurringTool(this, h)
            if (~isa(this, 'mlfourd.BlurringTool'))
                h.changeState( ...
                    mlfourd.BlurringTool(h, this.imagingFormat_, ...
                                         'logger', this.logger));
            end
            this.addLog('mlfourd.AbstractImagingTool.selectBlurringTool');
        end
        function selectDynamicsTool(this, h)
            if (~isa(this, 'mlfourd.DynamicsTool'))
                h.changeState( ...
                    mlfourd.DynamicsTool(h, this.imagingFormat_, ...
                                         'logger', this.logger));
            end
            this.addLog('mlfourd.AbstractImagingTool.selectDynamicsTool');
        end
        function selectFilesystemTool(this, h)
            if (~isa(this, 'mlfourd.FilesystemTool'))
                this.save;
                h.changeState( ...
                    mlfourd.FilesystemTool(h, this.fqfilename, ...
                                         'logger', this.logger));
            end
            this.addLog('mlfourd.AbstractImagingTool.selectFilesystemTool');
        end
        function selectImagingTool(this, h)
            if (~isa(this, 'mlfourd.ImagingTool'))
                h.changeState( ...
                    mlfourd.ImagingTool(h, this.imagingFormat_, ...
                                         'logger', this.logger));
            end
            this.addLog('mlfourd.AbstractImagingTool.selectImagingTool');
        end
        function selectMaskingTool(this, h)
            if (~isa(this, 'mlfourd.MaskingTool'))
                h.changeState( ...
                    mlfourd.MaskingTool(h, this.imagingFormat_, ...
                                         'logger', this.logger));
            end
            this.addLog('mlfourd.AbstractImagingTool.selectMaskingTool');
        end
        function selectNumericalTool(this, h)
            if (~isa(this, 'mlfourd.NumericalTool'))
                h.changeState( ...
                    mlfourd.NumericalTool(h, this.imagingFormat_, ...
                                         'logger', this.logger));
            end
            this.addLog('mlfourd.AbstractImagingTool.selectNumericalTool');
        end
        
        %%
        
        function addLog(this, varargin)
            try
                this.imagingFormat_.addLog(varargin{:})
            catch ME
                handwarning(ME)
            end
        end
        function c = char(this, varargin)
            c = char(this.imagingFormat_, varargin{:});
        end
        function imgf = imagingFormat(this)
            try
                imgf = copy(this.imagingFormat_);
            catch ME
                handwarning(ME)
                imgf = [];
            end
        end
        function imgi = imagingInfo(this)
            try
                imgi = this.imagingFormat_.imagingInfo;
            catch ME
                handwarning(ME)
                imgi = [];
            end
        end
        function s = string(this, varargin)
            s = string(this.imagingFormat_, varargin{:});
        end
    end
    
    %% PROTECTED

    properties (Access = protected)
        compatibility_
        imagingFormat_
    end
    
    methods (Access = protected)                 
        function this = AbstractImagingTool(contexth, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): option provides numerical imaging data.  Default := [].
            %      compatibility (logical): retain compatibility with previous software versions.
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingContext2'))
            addOptional(ip, 'imagingFormat', [], @(x) isempty(x) || isa(x, 'mlfourd.IImagingFormat'))
            addParameter(ip, 'compatibility', true, @islogical)
            parse(ip, contexth, varargin{:})
            ipr = ip.Results;
            this.contexth_ = ipr.contexth;
            this.imagingFormat_ = ipr.imagingFormat;
            this.compatibility_ = ipr.compatibility;
 		end
        function that = copyElement(this)
            that = copyElement@matlab.mixin.Copyable(this);
            that.imagingFormat_ = copy(this.imagingFormat_);
        end
    end 

    %% HIDDEN
    
    properties (Hidden)
        contexth_
    end
    
    methods (Hidden)
        function this = changeState(this, s)
            %  Args:
            %      s (AbstractImagingTool2): state which is requesting state transition.

            assert(isa(s, 'mlfourd.AbstractImagingTool'))
            this.contexth_.changeState(s);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

