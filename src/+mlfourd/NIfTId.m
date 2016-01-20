classdef NIfTId < mlfourd.InnerNIfTId
    %% NIFTID specifies imaging data with img, fileprefix, hdr.hist.descrip, hdr.dime.pixdim as
    %  described by Jimmy Shen's entries at Mathworks File Exchange
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.

    properties (Constant)
        ISEQUAL_IGNORES = {'hdr' 'label' 'descrip' 'hdxml' 'creationDate' 'originalType' 'untouch' 'stack'}
    end
    
    methods (Static) 
        function this = load(varargin)
            %% LOAD loads imaging objects from the filesystem.  In the absence of file extension, LOAD will attempt guesses.
            %  @param [fn] is a [fully-qualified] fileprefix or filename, specifies imaging objects on the filesystem.
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return this is an instance of mlfourd.NIfTId.
            %  See also:  mlfourd.NIfTId.NIfTId
            
            assert(nargin >= 1);
            assert(ischar(varargin{1}));
            this = mlfourd.NIfTId(varargin{:});
        end 
    end 
    
    methods 
        function niid = clone(this, varargin)
            %% CLONE
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niid copy-construction with niid.descrip appended with 'clone'.
            %  See also:  mlfourd.NIfTId.NIfTId
            
            niid = mlfourd.NIfTId(this, varargin{:});
            niid = niid.append_descrip('cloned');
        end
        function niid = makeSimilar(this, varargin)
            %% MAKESIMILAR 
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niid copy-construction with niid.descrip appended with 'made similar'.
            %  See also:  mlfourd.NIfTId.NIfTId
    
            niid = mlfourd.NIfTId(this, varargin{:});
            niid = niid.append_descrip('made similar');
        end
        
        function this = NIfTId(varargin)
            %% NIfTId specifies imaging data with img, fileprefix, hdr.hist.descrip, hdr.dime.pixdim as
            %  described by Jimmy Shen's entries at Mathworks File Exchange.  
            %  @ param [obj] may be a filename, numerical, INIfTI instantiation, struct compliant with 
            %  package mlniftitools; it constructs the class instance. 
            %  @ param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  Valid param-names:  bitpix, datatype, descrip, ext, filename, filepath, fileprefix,
            %  filetype, fqfilename, fqfileprefix, hdr, img, label, mmppix, noclobber, pixdim, separator.
            %  @ return this as a class instance.  Without arguments, this has default values.
            %  @ throws mlfourd:invalidCtorObj, mlfourd:fileTypeNotSupported, mlfourd:fileNotFound, mlfourd:unsupportedParamValue, 
            %  mlfourd:unknownSwitchCase, mlfourd:unsupportedDatatype, mfiles:unixException, MATLAB:assertion:failed
            %  See also:  http://www.mathworks.com/matlabcentral/fileexchange/authors/20638
            
            this = this@mlfourd.InnerNIfTId;
            if (0 == nargin); return; end
            
            import mlfourd.*;
            ip = inputParser;
            addOptional( ip, 'obj',          [], @NIfTId.validateCtorObj);
            addParameter(ip, 'bitpix',       [], @isnumeric);
            addParameter(ip, 'datatype',     [], @(x) isnumeric(x) || ischar(x));
            addParameter(ip, 'descrip',      '', @ischar);
            addParameter(ip, 'ext',          []);
            addParameter(ip, 'filename',     '', @ischar);
            addParameter(ip, 'filepath',     '', @ischar);
            addParameter(ip, 'fileprefix',   '', @ischar);
            addParameter(ip, 'filetype',     [], @(x) isnumeric(x) && (isempty(x) || (x >= 0 && x <= 2)));
            addParameter(ip, 'fqfilename',   '', @ischar);
            addParameter(ip, 'fqfileprefix', '', @ischar);
            addParameter(ip, 'hdr',  struct([]), @isstruct);
            addParameter(ip, 'img',          [], @(x) isnumeric(x) || islogical(x));
            addParameter(ip, 'label',        '', @ischar);
            addParameter(ip, 'mmppix',       [], @isnumeric);
            addParameter(ip, 'noclobber',    []);
            addParameter(ip, 'pixdim',       [], @isnumeric);
            addParameter(ip, 'separator',    '', @ischar);
            parse(ip, varargin{:});
            
            this.originalType_ = class(ip.Results.obj);
            switch (this.originalType) % no returns within switch!  must reach this.populateFieldsFromInputParser.
                case 'char'
                    ff = this.existingFileform(ip.Results.obj);
                    if (~isempty(ff))
                        this = NIfTId.load_existing(ff);
                    else
                        [p,f] = myfileparts(ip.Results.obj);
                        this.fqfilename = fullfile(p, [f this.FILETYPE_EXT]);
                    end
                case 'struct' 
                    % as described by mlniftitools.load_untouch_nii
                    this.hdr_         = ip.Results.obj.hdr;
                    this.filetype_    = ip.Results.obj.filetype;
                    this.fileprefix   = ip.Results.obj.fileprefix;
                    this.ext_         = ip.Results.obj.ext;
                    this.img_         = ip.Results.obj.img;
                    this.untouch_     = ip.Results.obj.untouch;
                otherwise
                    if (isnumeric(ip.Results.obj))
                        rank                                 = length(size(ip.Results.obj));
                        this.img_                            = double(ip.Results.obj);
                        this.hdr_.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                        this.hdr_.dime.dim                   = ones(1,8);
                        this.hdr_.dime.dim(1)                = rank;
                        this.hdr_.dime.dim(2:rank+1)         = size(ip.Results.obj);
                        this.hdr_.dime.datatype              = 64;
                        this.hdr_.dime.bitpix                = 64;
                    elseif (isa(ip.Results.obj, 'mlfourd.NIfTIInterface'))
                        warning('off', 'MATLAB:structOnObject');
                        this = NIfTId(struct(ip.Results.obj));
                        warning('on', 'MATLAB:structOnObject');
                    elseif (isa(ip.Results.obj, 'mlfourd.INIfTI'))
                        this.ext_         = ip.Results.obj.ext;
                        this.fqfileprefix = ip.Results.obj.fqfileprefix;
                        this.filetype_    = ip.Results.obj.filetype;
                        this.hdr_         = ip.Results.obj.hdr;
                        this.img_         = ip.Results.obj.img;                     
                        this.label        = ip.Results.obj.label;
                        this.noclobber    = ip.Results.obj.noclobber;
                        this.separator    = ip.Results.obj.separator;
                        this.untouch_     = ip.Results.obj.untouch;   
                    else
                        NIfTId.validateCtorObj(ip.Results.obj);
                    end
            end
            
            this = this.populateFieldsFromInputParser(ip);
        end 
    end
   
    %% PRIVATE
 
    methods (Static, Access = private)
        function ff   = existingFileform(ff)
            if (lexist(ff, 'file'))
                return
            end
            [p,f] = myfileparts(ff);
            e1s = mlfourd.JimmyShenInterface.SUPPORTED_EXT;
            e2s = mlsurfer.SurferRegistry.SUPPORTED_EXT;
            for e = 1:length(e1s)
                ff = fullfile(p, [f e1s{e}]);
                if (lexist(ff, 'file'))
                    return
                end
            end
            for e = 1:length(e2s)
                ff = fullfile(p, [f e2s{e}]);
                if (lexist(ff, 'file'))
                    return
                end
            end
            ff = '';
        end
        function this = load_existing(fn)
            try
                import mlfourd.*;
                e = NIfTId.selectExistingExtension(fn);
                if (lstrfind(e, JimmyShenInterface.SUPPORTED_EXT))
                    this = NIfTId.load_JimmyShen(fn);
                    this = this.adjustFieldsAfterLoading;
                    return
                end
                if (lstrfind(e, mlsurfer.SurferRegistry.SUPPORTED_EXT))
                    this = NIfTId.load_surfer(fn);
                    this = this.adjustFieldsAfterLoading;
                    return
                end
            catch ME
                handexcept(ME, ...
                    'mlfourd:fileNotFound', 'NIfTId.load_existing could not open fn->%s', fn);
            end
        end
        function this = load_surfer(fn)
            import mlfourd.*;
            [p,f] = myfileparts(fn);
            fn2 = fullfile(p, [f '_' datestr(now,30) NIfTId.FILETYPE_EXT]);
            mlbash(sprintf('mri_convert %s %s', fn, fn2));
            this = NIfTId.load_JimmyShen(fn2);
            deleteExisting(fn2);
        end
        function this = load_JimmyShen(fn)
            this = mlfourd.NIfTId(mlniftitools.load_untouch_nii(fn));
            this.fqfilename = fn;
        end
        function e    = selectExistingExtension(fn)
            [~,~,e] = myfileparts(fn);
            if (lexist(fn, 'file'))
                if (isempty(e))
                    error('mlfourd:fileTypeNotSupported', ...
                        'NIfTId.selectExistingExtension could not find a file extension in %s', fn);
                end
                return
            end
            if (isempty(e))
                files = mlsystem.DirTool([fn '.*']);
                for f = 1:length(files)
                    if (lstrfind(files{f}, mlfourd.JimmyShenInterface.SUPPORTED_EXT))
                        [~,~,e] = myfileparts(files{f});
                        return
                    end
                    if (lstrfind(files{f}, mlsurfer.SurferRegistry.SUPPORTED_EXT))
                        [~,~,e] = myfileparts(files{f});
                        return
                    end
                    
                end
            end
            error('mlfourd:fileTypeNotSupported', ...
                'NIfTId.load_existing does not support file extension %s', e);
        end
        function        validateCtorObj(obj)
            if (~(ischar(obj) || isstruct(obj) || isnumeric(obj) || ...
                    isa(obj, 'mlfourd.INIfTI') || isa(obj, 'mlfourd.NIfTIInterface')))
                error('mlfourd:invalidCtorObj', ...
                      'NIfTId.validateCtorObj does not support class(obj)->%s', class(obj));
            end
        end
    end 
    
    methods (Access = private)
        function this = adjustFieldsAfterLoading(this)
            if (~mlfourd.InnerNIfTId.LOAD_UNTOUCHED)
                this = this.optimizePrecision; 
            end
            this.hdr_.hist.descrip = sprintf('NIfTId.load read %s on %s', this.fqfilename, datestr(now, 30));
            this.label_ = this.fileprefix;
        end
        function this = populateFieldsFromInputParser(this, ip)
            for p = 1:length(ip.Parameters)
                if (~lstrfind(ip.Parameters{p}, ip.UsingDefaults))
                    switch (ip.Parameters{p})
                        case 'descrip'
                            this = this.append_descrip(ip.Results.descrip);
                        case 'ext'
                            this.ext_ = ip.Results.ext;
                        case 'hdr'
                            this.hdr_ = ip.Results.hdr;
                        case 'obj'
                        otherwise
                            this.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                    end
                end
            end
        end
    end 
    
end

