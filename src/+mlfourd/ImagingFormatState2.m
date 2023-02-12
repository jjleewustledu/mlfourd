classdef (Abstract) ImagingFormatState2 < handle & mlfourd.IImagingFormat
    %% IMAGINGFORMATSTATE2 defines an abstraction for encapsulating the behavior associated with particular states of 
    %  ImagingFormatContext2.  Concrete states may include FilesystemFormatTool, DicomTool, ListmodeTool, MatlabFormatTool, NiftiTool, 
    %  CiftiTool, GiftiTool, FourdfpTool, and TrivialFormatTool.  These state-defining tools should remain encapsulated by 
    %  ImagingFormatContext2.
    %  N.B.:  select*Tool() generate imagingInfo from the filesystem.
    %  
    %  Created 02-Dec-2021 21:23:23 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
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
        img % required by mlniftitools.{save_nii,save_untouch_nii}
        logger
        viewer
    end

    methods

        %% set/get

        function     set.filename(this, s)
            this.filesystem_.filename = s;
        end
        function g = get.filename(this)
            g = this.filesystem_.filename;
        end
        function     set.filepath(this, s)
            this.filesystem_.filepath = s;
        end
        function g = get.filepath(this)
            g = this.filesystem_.filepath;
        end
        function     set.fileprefix(this, s)
            this.filesystem_.fileprefix = s;
        end
        function g = get.fileprefix(this)
            g = this.filesystem_.fileprefix;
        end
        function     set.filesuffix(this, s)
            this.filesystem_.filesuffix = s;
        end
        function g = get.filesuffix(this)
            g = this.filesystem_.filesuffix;
        end
        function     set.fqfilename(this, s)
            this.filesystem_.fqfilename = s;
        end
        function g = get.fqfilename(this)
            g = this.filesystem_.fqfilename;
        end
        function     set.fqfileprefix(this, s)
            this.filesystem_.fqfileprefix = s;
        end
        function g = get.fqfileprefix(this)
            g = this.filesystem_.fqfileprefix;
        end
        function     set.fqfn(this, s)
            this.filesystem_.fqfn = s;
        end
        function g = get.fqfn(this)
            g = this.filesystem_.fqfn;
        end
        function     set.fqfp(this, s)
            this.filesystem_.fqfp = s;
        end
        function g = get.fqfp(this)
            g = this.filesystem_.fqfp;
        end
        function     set.noclobber(this, s)
            this.filesystem_.noclobber = s;
        end
        function g = get.noclobber(this)
            g = this.filesystem_.noclobber;
        end

        function g = get.bytes(this)
            g = numel(getByteStreamFromArray(this.img_));
        end
        function g = get.filesystem(this)
            g = this.filesystem_;
        end
        function g = get.img(this)
            g = this.img_;
        end
        function     set.img(this, s)
            %  Args:
            %      im (numeric):  incoming imaging data
            %  Returns:
            %      this: with updated img, imagingInfo
            
            assert(isnumeric(s) || islogical(s))
            this.img_ = s;
            this.adjustHdrForImg(s) % supports ImagingFormatTool
        end
        function     set.logger(this, s)
            assert(isa(s, 'mlpipeline.ILogger'))
            this.logger_ = s;
        end
        function g = get.logger(this)
            g = this.logger_;
        end        
        function     set.viewer(this, s)
            assert(isa(s, 'mlfourd.IViewer'))
            this.viewer_ = s;
        end
        function g = get.viewer(this)
            g = this.viewer_;        
        end

        %% select states

        function that = selectTrivialFormatTool(this, contexth)
            if ~isa(this, 'mlfourd.TrivialFormatTool')
                this.addLog('selectMatlabFormatTool');
                that = mlfourd.TrivialFormatTool(contexth, ...
                                      [], ...
                                      'filesystem', this.filesystem_, ...
                                      'logger', this.logger, ...
                                      'viewer', this.viewer);
                contexth.changeState(that);
            else
                that = this;
            end
        end
        function that = selectFilesystemFormatTool(this, contexth)
            if ~isa(this, 'mlfourd.FilesystemFormatTool')
                this.addLog('selectFilesystemFormatTool');
                that = mlfourd.FilesystemFormatTool(contexth, ...
                                      [], ...
                                      'filesystem', this.filesystem_, ...
                                      'logger', this.logger, ...
                                      'viewer', this.viewer);
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectImagingFormatTool(this, contexth)
            if isa(this, 'mlfourd.ImagingFormatTool') % short-circuit type-casting
                return
            end
            if this.hasFourdfp()
                that = this.selectFourdfpTool(contexth);
                return
            end
            if this.hasMgh()
                that = this.selectMghTool(contexth);
                return
            end
            if this.hasNifti()
                that = this.selectNiftiTool(contexth);
                return
            end
            that = this.selectMatlabFormatTool(contexth);
        end
        function that = selectMatlabFormatTool(this, contexth)
            if ~isa(this, 'mlfourd.MatlabFormatTool')
                this.addLog('ImagingFormatState2.selectMatlabFormatTool');
                info_ = mlfourd.ImagingInfo.createFromFilesystem(this.filesystem_);
                temp = mlfourd.MatlabFormatTool(contexth, ...
                                      this.img_, ...
                                      'imagingInfo', info_, ...
                                      'filesystem', this.filesystem_, ...
                                      'logger', this.logger, ...
                                      'viewer', this.viewer);
                that = mlfourd.MatlabFormatTool.createFromImagingFormat(temp);
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectFourdfpTool(this, contexth)
            if ~isa(this, 'mlfourd.FourdfpTool')
                this.filesystem_.filesuffix = '.4dfp.hdr';
                this.addLog('ImagingFormatState2.selectFourdfpTool');
                info_ = mlfourd.FourdfpInfo(this.filesystem_);
                temp = mlfourd.FourdfpTool(contexth, ...
                                      this.img_, ...
                                      'imagingInfo', info_, ...
                                      'filesystem', this.filesystem_, ...
                                      'logger', this.logger, ...
                                      'viewer', this.viewer);
                that = mlfourd.FourdfpTool.createFromImagingFormat(temp);
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectMghTool(this, contexth)
            if ~isa(this, 'mlfourd.MghTool')
                this.filesystem_.filesuffix = '.mgz';
                this.addLog('ImagingFormatState2.selectMghTool');
                info_ = mlfourd.MGHInfo(this.filesystem_);
                temp = mlfourd.MghTool(contexth, ...
                                      this.img_, ...
                                      'imagingInfo', info_, ...
                                      'filesystem', this.filesystem_, ...
                                      'logger', this.logger, ...
                                      'viewer', this.viewer);
                that = mlfourd.MghTool.createFromImagingFormat(temp);
                contexth.changeState(that);
            else
                that = this;
            end            
        end
        function that = selectNiftiTool(this, contexth)
            if ~isa(this, 'mlfourd.NiftiTool')
                if ~contains(this.filesystem_.filesuffix, '.nii')
                    this.filesystem_.filesuffix = '.nii.gz';
                end
                this.addLog('ImagingFormatState2.selectNiftiTool');
                info_ = mlfourd.NIfTIInfo(this.filesystem_);
                temp = mlfourd.NiftiTool(contexth, ...
                                      this.img_, ...
                                      'imagingInfo', info_, ...
                                      'filesystem', this.filesystem_, ...
                                      'logger', this.logger, ...
                                      'viewer', this.viewer);
                that = mlfourd.NiftiTool.createFromImagingFormat(temp);
                contexth.changeState(that);
            else
                that = this;
            end            
        end

        %% implementations of IImagingFormat

        function tf = isempty(this)
            tf = ~isfile(this.fqfilename) && isempty(this.img_);
        end
        function len = length(this)
            len = length(this.img_);
        end
        function n = ndims(this)
            n = ndims(this.img_);
        end
        function n = numel(this)
            n = numel(this.img_);
        end
        function s = size(this, varargin)
            s = size(this.img_, varargin{:});
        end

        %%

        function addLog(this, varargin)
            this.logger_.add(varargin{:});
        end
        function c = char(~, varargin)
            c = evalc('disp(this)');
            c = char(c, varargin{:});
        end
        function c = complex(this)
            d = double(this.img);
            re = real(d);
            im = imag(d);
            c = complex(re, im);
        end
        function d = double(this)
            d = double(this.img);
        end
        function tf = hasFourdfp(this)
            tf = strcmp(this.filesuffix, '.4dfp.hdr') || ...
                strcmp(this.filesuffix, '.4dfp.img');
        end
        function tf = hasMgh(this)
            tf = strcmp(this.filesuffix, '.mgz') || ...
                strcmp(this.filesuffix, '.mgh');
        end
        function tf = hasNifti(this)
            tf = strcmp(this.filesuffix, '.nii') || ...
                strcmp(this.filesuffix, '.nii.gz');
        end
        function tf = haveDistinctContextHandles(this, that)
            %  Args:
            %      that (ImagingContext2): which may possess a context handle
            %  Returns:
            %      tf (logical): context handles are distinct

            tf = this.contexth_ ~= that.contexth_;
        end
        function h = histogram(this, varargin)
            msk = this.img ~= 0;
            h = histogram(this.img(msk), varargin{:});
        end        
        function d = int8(this)
            d = int8(this.img);
        end
        function d = int16(this)
            d = int16(this.img);
        end
        function d = int32(this)
            d = int32(this.img);
        end
        function d = int64(this)
            d = int64(this.img);
        end
        function l = logical(this)
            l = logical(this.img);
        end
        function save(this, varargin)
            %% SAVE saves this as this.fqfilename on the filesystem.

            that = this.selectMatlabFormatTool(this.contexth_);
            save_mat(that, varargin{:});
        end
        function s = single(this)
            s = single(this.img);
        end
        function s = string(this, varargin)
            s = convertCharsToStrings(this.char(varargin{:}));
        end
        function d = uint8(this)
            d = uint8(this.img);
        end
        function d = uint16(this)
            d = uint16(this.img);
        end
        function d = uint32(this)
            d = uint32(this.img);
        end
        function d = uint64(this)
            d = uint64(this.img);
        end
    end

    %% PROTECTED

    properties (Access = protected)
        filesystem_
        filesystemRegistry_
        img_
        logger_
        viewer_
    end

    methods (Static, Access = protected)
        function tag = tupleTag(tup)
            assert(isnumeric(tup));
            tag = mat2str(tup);
            tag = strrep(tag, ' ', '_');
            tag = strrep(tag, '.', 'p');
            tag = strrep(tag, '[', '');
            tag = strrep(tag, ']', '');
        end
    end

    methods (Access = protected)
        function this = ImagingFormatState2(contexth, varargin)
            %  Args:
            %      contexth (ImagingContext2 required):  handle to ImagingContexts of the state design pattern.
            %      img (numeric option):  provides numerical imaging data.  Default := [].
            %      filesystem (HandleFilesystem):  Default := mlio.HandleFilesystem().
            %      logger (mlpipeline.ILogger):  Default := log on filesystem | mlpipeline.Logger2(filesystem.fqfileprefix).
            %      viewer (IViewer):  Default := mlfourd.Viewer().
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'contexth', @(x) isa(x, 'mlfourd.ImagingFormatContext2'))
            addOptional(ip, 'img', [], @(x) isnumeric(x) || islogical(x))
            addParameter(ip, 'filesystem', mlio.HandleFilesystem(), @(x) isa(x, 'mlio.HandleFilesystem')) 
            addParameter(ip, 'logger', [], @(x) isempty(x) || isa(x, 'mlpipeline.ILogger'))
            addParameter(ip, 'viewer', mlfourd.Viewer())
            parse(ip, contexth, varargin{:})
            ipr = ip.Results;
            this.contexth_ = ipr.contexth;
            this.img_ = ipr.img;
            this.filesystem_ = ipr.filesystem;
            if isa(ipr.logger, 'mlpipeline.ILogger')
                % reuse existing
                this.logger_ = ipr.logger; 
                this.logger_.fqfileprefix = this.fqfileprefix;
            else
                % generate
                logfile = strcat(this.filesystem_.fqfileprefix, '.log');
                if isfile(logfile) 
                    % read existing from filesystem
                    this.logger_ = mlpipeline.Logger2.createFromFilename(logfile);
                else 
                    % create new logger
                    this.logger_ = mlpipeline.Logger2(this.filesystem_.fqfileprefix);
                end
            end
            this.viewer_ = ipr.viewer;
            this.filesystemRegistry_ = mlio.FilesystemRegistry.instance;
        end

        function adjustHdrForImg(~)
            %% this stub, called by set.img(), supports overriding by ImagingFormatTool.adjustHdrForImg()
        end
        function that = copyElement(this)
            that = copyElement@matlab.mixin.Copyable(this);
            that.filesystem_ = copy(this.filesystem_);
            that.logger_ = copy(this.logger_);
        end
        function fn   = tempFqfilename(this, varargin)
            ip = inputParser;
            addOptional(ip, 'fqfp', this.fqfileprefix, @ischar);
            parse(ip, varargin{:});
            
            fn = strcat(myfileprefix(ip.Results.fqfp), '.mat');
            fn = tempFqfilename(fn);
        end
    end

    %% HIDDEN
    
    properties (Hidden)
        contexth_
    end
    
    methods (Hidden)
        function this = changeState(this, s)
            %  Args:
            %      s (ImagingFormatState2): state which is requesting state transition.

            assert(isa(s, 'mlfourd.ImagingFormatState2'))
            this.contexth_.changeState(s);
        end
    end

    %% DEPRECATED

    methods (Hidden)
        function this = append_fileprefix(this, varargin)
            %% APPEND_FILEPREFIX
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates fileprefix with separator_ and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', this.fileprefix, astring);
            this.addLog('ImagingFormatState2.append_fileprefix:  %s', astring);
        end               
        function this = prepend_fileprefix(this, varargin)
            %% PREPEND_FILEPREFIX
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates fileprefix with prepended string and separator_.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', astring, this.fileprefix);
            this.addLog('ImagingFormatState2.prepend_fileprefix:  %s', astring);
        end
        function this = scrubNanInf(this, varargin)
            %% SCRUBNANINF sets to zero non-finite elements of its argument
            %  @param obj := this.img_ by default.
            %  @return this.
            %  See also mlfourd.AbstractNIfTIComponent and mlfourd.NIfTIdecorator.
            
            p = inputParser;
            addOptional(p, 'obj', this.img_, @isnumeric);
            parse(p, varargin{:});
            img__ = double(p.Results.obj);
            
            if (all(isfinite(img__(:))))
                return; end
            switch (ndims(img__))
                case 1
                    img__ = scrub1D(this, img__);
                case 2
                    img__ = scrub2D(this, img__);
                case 3
                    img__ = scrub3D(this, img__);
                case 4
                    img__ = scrub4D(this, img__);
                otherwise
                    error('mlfourd:unsupportedParamValue', ...
                          'InnerNIfTI.scrubNanInf:  ndims(img) -> %i', ndims(img__));
            end            
            this.img = img__;
            
            function im   = scrub1D(this, im)
                assert(isnumeric(im));
                for x = 1:this.size(1)
                    if (~isfinite(im(x)))
                        im(x) = 0; end
                end
            end
            function im   = scrub2D(this, im)
                assert(isnumeric(im));
                for y = 1:this.size(2)
                    for x = 1:this.size(1)
                        if (~isfinite(im(x,y)))
                            im(x,y) = 0; end
                    end
                end
            end
            function im   = scrub3D(this, im)
                assert(isnumeric(im));
                for z = 1:this.size(3)
                    for y = 1:this.size(2)
                        for x = 1:this.size(1)
                            if (~isfinite(im(x,y,z)))
                                im(x,y,z) = 0; end
                        end
                    end
                end
            end
            function im   = scrub4D(this, im)
                assert(isnumeric(im));
                for t = 1:this.size(4)
                    for z = 1:this.size(3)
                        for y = 1:this.size(2)
                            for x = 1:this.size(1)
                                if (~isfinite(im(x,y,z,t)))
                                    im(x,y,z,t) = 0; end
                            end
                        end
                    end
                end
            end 
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
