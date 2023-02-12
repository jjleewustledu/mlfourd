classdef GiftiInfo < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlio.IOInterface
	%% IMAGINGINFO manages metadata and header information for imaging.  Internally, it uses GIFTI conventions.
    %  
    %  Created 05-Oct-2022 00:23:16 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.13.0.2049777 (R2022b) for MACI64.  Copyright 2022 John J. Lee.    
    
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

        filesystem % get/set handle, not copy, from external filesystem 
        json_metadata
        json_metadata_filesuffix
        machine
    end

    methods

        %% SET/GET

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

        function     set.filesystem(this, s)
            assert(isa(s, 'mlio.HandleFilesystem'))
            this.filesystem_ = s;
        end
        function g = get.filesystem(this)
            g = copy(this.filesystem_);
        end
        function g = get.json_metadata(this)
            g = this.json_metadata_;
        end
        function     set.json_metadata(this, s)
            assert(isstruct(s))
            this.json_metadata_ = s;
        end
        function g = get.json_metadata_filesuffix(this)
            g = this.json_metadata_filesuffix_;
        end
        function     set.json_metadata_filesuffix(this, s)
            assert(istext(s))
            this.json_metadata_filesuffix_ = s;
        end
        function g = get.machine(this)
            g = this.machine_;
            if (isempty(g))
                [~,~,m] = computer;
                if (strcmpi(m, 'L'))
                    this.machine_ = 'ieee-le';
                    g = this.machine_;
                else
                    this.machine_ = 'ieee-be';
                    g = this.machine_;
                end
            end
        end

        %%

        function c = char(this)
            c = char(this.filesystem_);
        end
        function s = string(this, varargin)
            s = string(this.filesystem_, varargin{:});
        end

        function this = GiftiInfo(varargin)
            %% GIFTIINFO 
            %  Args:
 			%      filesystem_ (text|mlio.HandleFilesystem):  
            %          If text, ImagingInfo creates isolated filesystem_ information.
            %          If mlio.HandleFilesystem, ImagingInfo will reference the handle for filesystem_ information,
            %          allowing for external modification for synchronization.
            %          For aufbau, the file need not exist on the filesystem.
            %      json_metadata (struct): read from filesystem by ImagingInfo hierarchy.
            %      json_metadata_filesuffix (text): for reading from filesystem by ImagingInfo hierarchy.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional( ip, 'filesystem', mlio.HandleFilesystem(), @(x) istext(x) || isa(x, 'mlio.HandleFilesystem'));
            addParameter(ip, 'json_metadata', [])
            addParameter(ip, 'json_metadata_filesuffix', '.json', @istext)
            parse(ip, varargin{:});
            ipr = ip.Results;
            if istext(ipr.filesystem)
                this.filesystem_ = mlio.HandleFilesystem.createFromString(ipr.filesystem);
            end
            if isa(ipr.filesystem, 'mlio.HandleFilesystem')
                this.filesystem_ = ipr.filesystem;
            end
            this.json_metadata_ = ipr.json_metadata;
            this.json_metadata_filesuffix_ = ipr.json_metadata_filesuffix;
        end
    end  
    
    methods (Static)
        function this = createFromFilename(fn, varargin)
            import mlfourd.*
            hf = mlio.HandleFilesystem.createFromString(fn);
            this = GiftiInfo(hf, varargin{:});
        end
        function this = createFromFilesystem(fs, varargin)
            import mlfourd.*
            this = GiftiInfo(fs, varargin{:});
        end
        function e = defaultFilesuffix()
            e = '.gii';
        end
        function f = tempFqfilename
            f = tempFqfilename(['mlfourd_GiftiInfo' mlfourd.GiftiInfo.defaultFilesuffix]);
        end
    end  
    
    %% PROTECTED
    
    properties (Access = protected)
        filesystem_
        json_metadata_
        json_metadata_filesuffix_
        machine_
    end

    methods (Access = protected)
        function that = copyElement(this)
            that = copyElement@matlab.mixin.Copyable(this);
            that.filesystem_ = copy(this.filesystem_);
        end
    end

    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
