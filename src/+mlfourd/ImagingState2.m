classdef (Abstract) ImagingState2 < handle & mlfourd.IImaging
    %% IMAGINGSTATE2 defines an interface for encapsulating the behavior associated with particular states of 
    %  ImagingContext2.  Concrete states include FilesystemTool, XnatTool, MatlabTool, SpacetimeTool, BlurringTool,
    %  MaskingTool, RegistrationTool, ManifoldTool, EEGTool, and TrivialTool.  These state-defining tools should 
    %  remain encapsulated by ImagingContext2 since complex states use handle representations that should not be 
    %  the concern of clients applications.
    %
    %  COLLABORATIONS.  ImagingContext2 may pass itself as an argument to the ImagingState2 object handling the request,
    %  allowing states to access the context as needed.  ImagingContext2 is the primary interface for clients.  Clients
    %  configure contexts with concrete states, after which clients need not deal with states directly.  Either
    %  ImagingContext2 or ImagingState2 subclasses decide how, and under which circumstances, states succeed one
    %  another.
    %
    %  CONSEQUENCES.  
    %  1.  This design pattern localizes state-specific behavior and partitions behavior.  Because state-specific
    %  codes live in state subclasses, new states and transitions are easily added by defininig new subclasses.  State
    %  objects partition the logic of state transitions, providing structures preferable to complex conditional
    %  statements.  This helps clarify the intent of codes.
    %  2.  This design pattern makes state transitions explicit, helping protect the context from inconsistent internal
    %  states.  State transitions are atomic from the perspective of the context.  
    %  3.  State objects can be shared if they possess no instance variables.  That is, state is encoded entirely by the
    %  object type, and contexts can share the same state object.  From the perspective of the flyweight, intrinsic
    %  state is eliminated, leaving only behavior.  
    %
    %  See also:  Erich Gamma, et al. Design patterns : elements of reusable object-oriented software. Reading, Mass.: 
    %             Addison-Wesley, 1995.
    %  
    %  Created 02-Dec-2021 14:07:45 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
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

        bytes
        compatibility
        filesystem
        logger
        stateTypeclass
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

        function g = get.bytes(this)
            g = this.imagingFormat_.bytes;
        end
        function g = get.compatibility(this)
            g = this.contexth_.compatibility;
        end
        function g = get.filesystem(this)
            try
                g = this.imagingFormat_.filesystem;
            catch ME
                handwarning(ME)
                g = [];
            end
        end
        function g = get.logger(this)
            try
                g = this.imagingFormat_.logger;
            catch ME
                handwarning(ME)
                g = [];
            end
        end
        function g = get.stateTypeclass(this)
            g = class(this.imagingFormat_);
        end 
        function g = get.viewer(this)
            g = this.imagingFormat_.viewer;
        end
        
        %% select states

        function selectBlurringTool(this, contexth)
            if ~isa(this, 'mlfourd.BlurringTool')
                this.addLog('mlfourd.ImagingState2.selectBlurringTool');
                contexth.changeState( ...
                    mlfourd.BlurringTool(contexth, this.imagingFormat_));
            end
        end
        function selectDynamicsTool(this, contexth)
            if ~isa(this, 'mlfourd.DynamicsTool')
                this.addLog('mlfourd.ImagingState2.selectDynamicsTool');
                contexth.changeState( ...
                    mlfourd.DynamicsTool(contexth, this.imagingFormat_));
            end
        end
        function selectFilesystemTool(this, contexth)
            if ~isa(this, 'mlfourd.FilesystemTool')
                this.addLog('mlfourd.ImagingState2.selectFilesystemTool');
                contexth.changeState( ...
                    mlfourd.FilesystemTool(contexth, this.fqfilename));
            end
        end
        function selectImagingTool(this, contexth)
            if ~isa(this, 'mlfourd.ImagingTool')
                this.addLog('mlfourd.ImagingState2.selectImagingTool');
                contexth.changeState( ...
                    mlfourd.ImagingTool(contexth, this.imagingFormat_));
            end
        end
        function selectMaskingTool(this, contexth)
            if ~isa(this, 'mlfourd.MaskingTool')
                this.addLog('mlfourd.ImagingState2.selectMaskingTool');
                contexth.changeState( ...
                    mlfourd.MaskingTool(contexth, this.imagingFormat_));
            end
        end
        function selectMatlabTool(this, contexth)
            if ~isa(this, 'mlfourd.MatlabTool')
                this.addLog('mlfourd.ImagingState2.selectMatlabTool');
                contexth.changeState( ...
                    mlfourd.MatlabTool(contexth, this.imagingFormat_));
            end
        end
        function selectNumericalTool(this, contexth)
            if ~this.compatibility
                this.selectMatlabTool(contexth)
                return
            end
            if ~isa(this, 'mlfourd.NumericalTool')
                this.addLog('mlfourd.ImagingState2.selectNumericalTool');
                contexth.changeState( ...
                    mlfourd.NumericalTool(contexth, this.imagingFormat_));
            end
        end
        function selectPointCloudTool(this, contexth)
            if ~isa(this, 'mlfourd.PointCloudTool')
                this.addLog('mlfourd.ImagingState2.selectPointCloudTool');
                contexth.changeState( ...
                    mlfourd.PointCloudTool(contexth, this.imagingFormat_));
            end
        end
        function selectTrivialTool(this, contexth)
            if ~isa(this, 'mlfourd.TrivialTool')
                this.addLog('mlfourd.ImagingState2.selectTrivialTool');
                contexth.changeState( ...
                    mlfourd.TrivialTool(contexth));
            end
        end
        
        %% implementations of IImaging
        
        function tf = isempty(this)
            tf = isempty(this.imagingFormat_);
        end
        function len = length(this)
            len = length(this.imagingFormat_);
        end
        function n = ndims(this)
            n = ndims(this.imagingFormat_);
        end
        function n = numel(this)
            n = numel(this.imagingFormat_);
        end
        function s = size(this, varargin)
            s = size(this.imagingFormat_, varargin{:});
        end

        %%

        function addLog(this, varargin)
            try
                this.imagingFormat_.addLog(varargin{:});
            catch ME
                handwarning(ME)
            end
        end
        function c = char(this, varargin)
            c = char(this.imagingFormat_, varargin{:});
        end
        function c = complex(this)
            d = double(this);
            re = real(d);
            im = imag(d);
            c = complex(re, im);
        end
        function d = double(this)
            d = double(this.imagingFormat_.img);
        end
        function tf = haveDistinctContextHandles(this, that)
            %  Args:
            %      that (ImagingContext2): which may possess a context handle
            %  Returns:
            %      tf (logical): context handles are distinct

            tf = this.contexth_ ~= that.contexth_;
        end
        function imgf = imagingFormat(this)
            try
                imgf = this.imagingFormat_; % internal state must share handles
            catch ME
                handwarning(ME)
                imgf = [];
            end
        end
        function imgi = imagingInfo(this)
            try
                imgi = this.imagingFormat_.imagingInfo; % internal state must share handles
            catch ME
                handwarning(ME)
                imgi = [];
            end
        end
        function d = int8(this)
            d = int8(this.imagingFormat_.img);
        end
        function d = int16(this)
            d = int16(this.imagingFormat_.img);
        end
        function d = int32(this)
            d = int32(this.imagingFormat_.img);
        end
        function d = int64(this)
            d = int64(this.imagingFormat_.img);
        end
        function l = logical(this)
            l = logical(this.imagingFormat_.img);
        end
        function save(this)
            addLog(this, 'mlfourd.ImagingState2.save %s', this.fqfilename);
            save(this.imagingFormat_);
        end
        function this = saveas(this, varargin)
            this.imagingFormat_ = this.imagingFormat_.saveas(varargin{:});
        end
        function s = single(this)
            s = single(this.imagingFormat_.img);
        end
        function s = string(this, varargin)
            s = string(this.imagingFormat_, varargin{:});
        end
        function d = uint8(this)
            d = uint8(this.imagingFormat_.img);
        end
        function d = uint16(this)
            d = uint16(this.imagingFormat_.img);
        end
        function d = uint32(this)
            d = uint32(this.imagingFormat_.img);
        end
        function d = uint64(this)
            d = uint64(this.imagingFormat_.img);
        end
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        annotateFileprefix_ = true
        imagingFormat_
    end
    
    methods (Access = protected)
        function this = ImagingState2(contexth, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): option provides numerical imaging data.  Default := [].
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingContext2'))
            addOptional(ip, 'imagingFormat', [], @(x) isempty(x) || isa(x, 'mlfourd.IImagingFormat'))
            parse(ip, contexth, varargin{:})
            ipr = ip.Results;
            this.contexth_ = ipr.contexth;
            this.imagingFormat_ = ipr.imagingFormat;
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
            %      s (ImagingState2): state which is requesting state transition.

            assert(isa(s, 'mlfourd.ImagingState2'))
            this.contexth_.changeState(s);
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
