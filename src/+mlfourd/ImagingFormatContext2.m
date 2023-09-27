classdef ImagingFormatContext2 < handle & mlfourd.IImagingFormat
    %% IMAGINGFORMATCONTEXT2
    %  TODO: 
    %  - adjust/remove state changes from getters?
    %  - test compatiblity with FreeSurfer T1.mgz and need for fslreorient2std
    %  
    %  Created 05-Dec-2021 17:51:32 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
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
        filesystem
        hdr
        img
        json_metadata
        logger
        orient % external representation from fslorient:  RADIOLOGICAL | NEUROLOGICAL
        original
        qfac % internal representation from this.hdr.dime.pixdim(1)
        stateTypeclass
        viewer

        % 4dfp support
        mmppix
        originator
    end

    methods % SET/GET
        function     set.filename(this, s)
            this.selectFilesuffixTool(fullfile(this.filepath, s));
            this.state_.filename = s;
        end
        function g = get.filename(this)
            g = this.state_.filename;
        end
        function     set.filepath(this, s)
            this.state_.filepath = s;
        end
        function g = get.filepath(this)
            g = this.state_.filepath;
        end
        function     set.fileprefix(this, s)
            this.state_.fileprefix = s;
        end
        function g = get.fileprefix(this)
            g = this.state_.fileprefix;
        end
        function     set.filesuffix(this, s)
            this.selectFilesuffixTool(strcat(this.fqfp, s));
            this.state_.filesuffix = s;
        end
        function g = get.filesuffix(this)
            g = this.state_.filesuffix;
        end
        function     set.fqfilename(this, s)
            this.selectFilesuffixTool(s);
            this.state_.fqfilename = s;
        end
        function g = get.fqfilename(this)
            g = this.state_.fqfilename;
        end
        function     set.fqfileprefix(this, s)
            this.state_.fqfileprefix = s;
        end
        function g = get.fqfileprefix(this)
            g = this.state_.fqfileprefix;
        end
        function     set.fqfn(this, s)
            this.selectFilesuffixTool(s);
            this.state_.fqfn = s;
        end
        function g = get.fqfn(this)
            g = this.state_.fqfn;
        end
        function     set.fqfp(this, s)
            this.state_.fqfp = s;
        end
        function g = get.fqfp(this)
            g = this.state_.fqfp;
        end
        function     set.noclobber(this, s)
            this.state_.noclobber = s;
        end
        function g = get.noclobber(this)
            g = this.state_.noclobber;
        end

        function g = get.bytes(this)
            g = this.state_.bytes;
        end
        function g = get.filesystem(this)
            g = copy(this.state_.filesystem);
        end
        function     set.hdr(this, s)
            this.selectImagingFormatTool();
            this.state_.hdr = s;
        end
        function g = get.hdr(this)
            this.selectImagingFormatTool();
            g = this.state_.hdr;
        end
        function     set.img(this, s)
            % if ~isfile(this.fqfn)
                % warning("mlfourd:RunTimeWarning", ...
                %     "%s: %s may have lost data from mlfourd.{ImagingFormatState2,ImagingInfo}", ...
                %     stackstr(), this.fqfn)

                % prevent loss of objects mlfourd.{ImagingFormatState2,ImagingInfo}.
                %this.save();
            % end
            this.selectImagingFormatTool();
            this.state_.img = s;
        end
        function g = get.img(this)
            this.selectImagingFormatTool();
            g = this.state_.img;
        end
        function g = get.json_metadata(this)
            this.selectImagingFormatTool();
            g = this.state_.json_metadata;
        end
        function     set.json_metadata(this, s)
            this.selectImagingFormatTool();
            this.state_.json_metadata = s;
        end
        function g = get.logger(this)
            g = copy(this.state_.logger);
        end
        function g = get.orient(this)
            g = this.state_.orient;
        end
        function g = get.original(this)
            this.selectImagingFormatTool();
            g = this.state_.original;
        end
        function g = get.qfac(this)
            g = this.state_.qfac;
        end
        function g = get.stateTypeclass(this)
            g = class(this.state_);
        end
        function g = get.viewer(this)
            g = this.state_.viewer;
        end

        function     set.mmppix(this, s)
            this.selectImagingFormatTool();
            this.state_.mmppix = s;
        end
        function g = get.mmppix(this)
            this.selectImagingFormatTool();
            g = this.state_.mmppix;
        end
        function     set.originator(this, s)
            this.selectImagingFormatTool();
            this.state_.originator = s;
        end
        function g = get.originator(this)
            this.selectImagingFormatTool();
            g = this.state_.originator;
        end
    end

    methods

        %% select states

        function this = selectFilesuffixTool(this, filename)
            %% SELECTFILESUFFIXTOOL selects imaging format state from filename.
            %  Args:
            %      filename (text): is compatible with requirements of the filesystem;
            %  Returns:
            %      this for compatibility with non-handle interfaces,
            %      replacing internal filename & filesystem information.

            assert(istext(filename))
            [~,~,ext] = myfileparts(filename);
            switch ext
                case '.mat'
                    this.selectMatlabFormatTool();
                case {'.4dfp.hdr', '.4dfp.img'}
                    this.selectFourdfpTool();
                case {'.mgz', '.mgh'}
                    this.selectMghTool();
                case {'.nii', '.nii.gz'}
                    this.selectNiftiTool();
                otherwise
                    error('mlfourd:ValueError', 'ImagingFormatContext2.saveas().ext ~ %s', ext)
            end
        end
        function this = selectFilesystemFormatTool(this)
            this.state_.selectFilesystemFormatTool(this);
        end
        function this = selectMatlabFormatTool(this)
            this.state_.selectMatlabFormatTool(this);
        end
        function this = selectImagingFormatTool(this)
            this.state_.selectImagingFormatTool(this);
        end
        function this = selectFourdfpTool(this)
            this.state_.selectFourdfpTool(this);
        end
        function this = selectMghTool(this)
            this.state_.selectMghTool(this);
        end
        function this = selectNiftiTool(this)
            this.state_.selectNiftiTool(this);
        end
        function this = selectTrivialFormatTool(this)
            this.state_.selectTrivialFormatTool(this);
        end
        
        %% implementations of IImagingFormat
        
        function tf = isempty(~)
            tf = false; %%% isempty(this.state_); % has pathologies
        end
        function len = length(this)
            len = length(this.state_);
        end
        function n = ndims(this)
            %% NDIMS provides fast queries of allocation of img

            n = ndims(this.state_);
        end
        function n = numel(this)
            %% NUMEL provides fast queries of allocation of img

            n = numel(this.state_);
        end
        function r = rank(this, varargin)
            r = this.ndims(varargin{:});
        end
        function s = size(this, varargin)
            %% SIZE provides fast queries of allocation of img

            s = size(this.state_, varargin{:});
        end 

        %%

        function this = addImgrec(this, varargin)
            %  Args:
            %      varargin are img.rec entries for the imaging state
            
            this.selectFourdfpTool();
            this.state_.addImgrec(varargin{:});
        end
        function this = addJsonMetadata(this, varargin)
            %  Args:
            %      varargin are structs containing json metadata
            
            this.state_.addJsonMetadata(varargin{:});
        end
        function this = addLog(this, varargin)
            %  Args:
            %      varargin are log entries for the imaging state
            
            this.state_.addLog(varargin{:});
        end
        function c = char(this, varargin)
            c = char(this.state_, varargin{:});
        end
        function c = complex(this)
            c = complex(this.state_);
        end
        function disp_debug(this)
            disp('=============== ImagingFormatContext2.disp_debug ===============')
            disp('=============== imagingInfo ===============')
            disp(this.imagingInfo)
            disp('=============== hdr ===============')
            disp(this.hdr.hk)
            disp(this.hdr.dime)
            disp(this.hdr.hist)
            disp('=============== original.hdr ===============')
            disp(this.original.hdr.hk)
            disp(this.original.hdr.dime)
            disp(this.original.hdr.hist)
            disp('=============== fslhd ===============')
            disp(this.fslhd)
            disp('=============== string(logger) ===============')
            disp(string(this.logger))
        end
        function d = double(this)
            d = double(this.state_);
        end
        function r = fslhd(this)
            try
                [~,r] = mlbash(sprintf('fslhd %s', this.fqfilename));
            catch ME
                handwarning(ME)
                r = '';
            end
        end
        function tf = haveDistinctStates(this, that)
            %  Args:
            %      that (ImagingContext2): with distinct state.

            tf = this.state_ ~= that.state_;
        end
        function tf = haveDistinctContextHandles(this, that)
            %  Args:
            %      that (ImagingContext2): with distinct context handle, used by state to access its context

            tf = haveDistinctContextHandles(this.state_, that.state_);
        end
        function h = histogram(this, varargin)
            h = this.state_.histogram(varargin{:});
        end
        function imgi = imagingInfo(this)
            this.selectImagingFormatTool();
            imgi = copy(this.state_.imagingInfo());
        end
        function d = int8(this)
            d = int8(this.state_);
        end
        function d = int16(this)
            d = int16(this.state_);
        end
        function d = int32(this)
            d = int32(this.state_);
        end
        function d = int64(this)
            d = int64(this.state_);
        end
        function l = logical(this)
            l = logical(this.state_);
        end        
        function this = reset_scl(this)
            this.selectImagingFormatTool();
            this.state_ = this.state_.reset_scl();
        end
        function save(this, varargin)
            %% SAVE saves the imaging format state as this.fqfilename on the filesystem.
            
            save(this.state_, varargin{:});
        end
        function this = saveas(this, filename)
            %% SAVEAS saves the imaging format state as this.fqfilename on the filesystem.
            %  Args:
            %      filename (text): is compatible with requirements of the filesystem;
            %  Returns:
            %      this for compatibility with non-handle interfaces,
            %      replacing internal filename & filesystem information.

            this.selectFilesuffixTool(filename);
            this.state_.fqfilename = filename;
            this.save();
        end
        function s = single(this)
            s = single(this.state_);
        end
        function s = string(this, varargin)
            s = string(this.state_, varargin{:});
        end
        function d = uint8(this)
            d = uint8(this.state_);
        end
        function d = uint16(this)
            d = uint16(this.state_);
        end
        function d = uint32(this)
            d = uint32(this.state_);
        end
        function d = uint64(this)
            d = uint64(this.state_);
        end
        function [s,r] = save_qc(this, varargin)
            if strcmp(this.stateTypeclass, 'mlfourd.MatlabFormatTool')
                this.state_.selectNiftiTool(this.state_.contexth_);
            end
            [s,r] = this.state_.save_qc(varargin{:});
        end
        function [s,r] = view(this, varargin)
            if strcmp(this.stateTypeclass, 'mlfourd.MatlabFormatTool')
                this.state_.selectNiftiTool(this.state_.contexth_);
            end
            [s,r] = this.state_.view(varargin{:});
        end
        function [s,r] = view_qc(this, varargin)
            if strcmp(this.stateTypeclass, 'mlfourd.MatlabFormatTool')
                this.state_.selectNiftiTool(this.state_.contexth_);
            end
            [s,r] = this.state_.view_qc(varargin{:});
        end

        function this = ImagingFormatContext2(imgobj, varargin)
            %  Args:
            %      imgobj (any): contains any imaging, such as [], Matlab numeric objects, filenames, another ImagingFormatContext2 
            %                    for copy-construction or any object supported by stateful ImagingFormatTool (~ ImagingFormatState2).

            import mlfourd.*;

            if 0 == nargin || isempty(imgobj)
                % must support empty ctor
                this.state_ = TrivialFormatTool(this);
                return
            end

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'imgobj')
            parse(ip, imgobj, varargin{:})
            ipr = ip.Results;
            
            if isa(ipr.imgobj, 'mlfourd.ImagingFormatContext2')
                % copy ctor
                this = copy(ipr.imgobj);
                return
            end
            if isnumeric(ipr.imgobj) || islogical(ipr.imgobj)
                this.state_ = MatlabFormatTool(this, ipr.imgobj, varargin{:});
                return
            end
            if istext(ipr.imgobj)
                this.state_ = FilesystemFormatTool(this, ipr.imgobj, varargin{:});
                return
            end
            this.state_ = ImagingFormatTool(ipr.imgobj, varargin{:});
        end
    end
    
    %% PROTECTED
    
    properties (Access = protected)
        state_
    end
    
    methods (Access = protected)
        function that = copyElement(this)
            that = copyElement@matlab.mixin.Copyable(this);
            that.state_ = copy(this.state_);
            that.state_.contexth_ = that;
        end
    end
        
    %% HIDDEN
    
	methods (Hidden)
        function changeState(this, s)
            %  Args:
            %      s (ImagingFormatState2): state which is requesting state transition.
            
            assert(isa(s, 'mlfourd.ImagingFormatState2'))
            this.state_ = s;
        end
    end

    %% DEPRECATED

    methods (Hidden)
        function this = append_descrip(this, varargin)
            this.state_ = this.state_.append_descrip(varargin{:});
        end
        function this = append_fileprefix(this, varargin)
            this.state_ = this.state_.append_fileprefix(varargin{:});
        end
        function this = ensureComplex(this)
            this.state_ = this.state_.ensureComplex;
        end
        function this = ensureDouble(this)
            this.state_ = this.state_.ensureDouble;
        end
        function this = ensureSingle(this)
            this.state_ = this.state_.ensureSingle;
        end
        function        freeview(this, varargin)
            this.selectImagingFormatTool();
            if ~contains(this.viewer.app, 'freeview')
                [~,r] = mlbash('which freeview');
                this.viewer = mlfourd.Viewer('app', strtrim(r));
            end
            this.state_.view(varargin{:});
        end
        function        fsleyes(this, varargin)
            this.selectImagingFormatTool();
            if ~contains(this.viewer.app, 'fsleyes')
                [~,r] = mlbash('which fsleyes');
                this.viewer = mlfourd.Viewer('app', strtrim(r));
            end
            this.state_.view(varargin{:});
        end
        function        fslview(this, varargin)
            this.fsleyes(varargin{:})
        end
        function this = prepend_descrip(this, varargin)
            this.state_ = this.state_.prepend_descrip(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.state_ = this.state_.prepend_fileprefix(varargin{:});
        end
        function this = scrubNanInf(this)
            this.state_ = this.state_.scrubNanInf;
        end
        function fqfn = tempFqfilename(this, varargin)
            fqfn = this.state_.tempFqfilename(varargin{:});
        end
        function this = zoom(this, varargin)
            this = this.zoomed(varargin{:});
        end
        function this = zoomed(this, varargin)
            this.state_ = this.state_.zoomed(varargin{:});
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
