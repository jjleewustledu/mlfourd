classdef NIfTId < mlfourd.AbstractNIfTId
    %% NIFTID accepts Jimmy Shen's NIfTI-structs or image arrays.  Ctor w/o args is also allowed.
    %  A minimal NIfTId has hdr.dime.pixdim, hdr.hist.descrip, fileprefix & img.
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.

    properties (Constant)
        ISEQUAL_IGNORES      = {'label' 'descrip' 'hdxml' 'creationDate' 'originalType' 'untouch' 'stack'}
        SUPPORTED_EXTENSIONS = {'.nii.gz' '.nii' '.mgh' '.mgz' '.hdr' '.dcm' '.IMA'} % fist extension is default
        CLEAN_UP_WORK_FILES  = true
    end    
    
    methods (Static) 
        function nii = load(fn, varargin)
            %% LOAD reads NIfTI objects from the file-system with file-names ending in NIfTId.SUPPORTED_EXTENSIONS.
            %  Freesurfer's mri_convert provides imaging format support.  If no file-extension is included, LOAD will attempt guesses.
            %  Usage:  nifti = NIfTId.load(filename[, description])
                   
            desc0 = ['NIfTId.load read ' fn ' on ' datestr(now)];
            
            p = inputParser;
            addRequired(p, 'fn', @ischar);
            addOptional(p, 'desc', desc0, @ischar);
            parse(p, fn, varargin{:});
            
            import mlfourd.*;  
            fe = NIfTId.findSupportedExtension(fn);
            if (~isempty(fe))
                nii = NIfTId.load_known_ext(fn, fe, p.Results.desc);
                return
            else 
                nii = NIfTId.load_guessing_ext(fn, p.Results.desc);
                return
            end
        end
        function fe  = findSupportedExtension(fname)
            import mlfourd.*;
            fe = [];
            exts = NIfTId.SUPPORTED_EXTENSIONS;
            for e = 1:length(exts)
                locs = strfind(fname, exts{e});
                if (~isempty(locs))
                    fe = fname(locs(end):end);
                    break
                end
            end
        end      
    end 
    
    methods 
        function this     = forceDouble(this)
            this.img_ = mlfourd.AbstractNIfTId.ensureDble(this.img_);
            this.hdr_.dime.datatype = 64;
            this.hdr_.dime.bitpix   = 64;
        end % forceDouble        
        function this     = forceSingle(this)
            this.img_ = mlfourd.AbstractNIfTId.ensureSing(this.img_);
            this.hdr_.dime.datatype = 16;
            this.hdr_.dime.bitpix   = 32;
        end % forceSingle 
        function [tf,msg] = isequal(this, nii)
            [tf,msg] = this.isequaln(nii);
        end
        function [tf,msg] = isequaln(this, nii)
            msg = '';
            tf = isa(nii, class(this));
            if (tf)
                [tf,msg] = this.fieldsequaln(nii);
            end
        end
        function            save(this)
            %% SAVE saves this NIfTId to this.fileprefix with extension .nii, then compresses with gzip
            
            import mlfourd.* mlniftitools.*;
            if (this.noclobber && lexist(this.fqfilename, 'file'))
                error('mlfourd:IOErr', ...
                      'NIfTId.save.fqfilename->%s already exists; stopping...%s', this.fqfilename); 
            end
            warning('off');  %#ok<WNOFF>
            delete(this.fqfilename);
            if (this.untouch)
                save_untouch_nii(struct(this), [this.fqfileprefix '.nii.gz']);
            else
                this = this.optimizePrecision;
                save_nii(        struct(this), [this.fqfileprefix '.nii.gz']);
            end
            warning('on'); %#ok<WNON>
        end 
        function this     = saveas(this, fqfn)
            this.fqfilename = fqfn;
            this.untouch_ = false;
            this.save;
        end % overloads AbstractSimpleIO.saveas        
        function nii      = clone(this)
            nii = mlfourd.NIfTId(this, this.fqfileprefix, ['clone of ' this.descrip], this.pixdim);
        end        
        function nii      = makeSimilar(this, varargin)
            %% MAKESIMILAR returns a similar NIfTId object
            %  n  = NIfTId(...)
            %  n1 = n.makeSimilar([paramName, paramValue][, ...])
            %
            %  supported parameters:  'img'
            %                         'datatype'
            %                         'label'
            %                         'bitpix'
            %                         'descrip'
            %                         'fileprefix'
            %                         'pixdim', 'mmppix'
    
            nii = this.clone;
            if (length(nii.descrip) > this.DESC_LEN_LIM)
                len = this.DESC_LEN_LIM - 5;
                len2 = floor(len/2);
                nii.descrip = ...
                    [nii.descrip(1:len2) ' ... ' nii.descrip(end+1-len2:end)]; 
            end
            
            p = inputParser;
            addParameter(p, 'img',        this.img,        @isnumeric);
            addParameter(p, 'datatype',   'double',        @(x) ischar(x) || isnumeric(x));
            addParameter(p, 'label',      this.label,      @ischar);
            addParameter(p, 'bitpix',     this.bitpix,     @isnumeric);
            addParameter(p, 'descrip',    'made similar',  @ischar);
            addParameter(p, 'fileprefix', this.fileprefix, @ischar);
            addParameter(p, 'mmppix',     this.mmppix,     @isnumeric);
            addParameter(p, 'pixdim',     this.pixdim,     @isnumeric);
            parse(p, varargin{:});             
            
            nii.img        = p.Results.img;
            nii.datatype   = p.Results.datatype;
            nii.label      = p.Results.label;
            nii.bitpix     = p.Results.bitpix;
            nii            = nii.append_descrip(p.Results.descrip);   
            nii.fileprefix = adjustFileprefix(p.Results.fileprefix);
            nii.mmppix     = p.Results.mmppix;
            nii.pixdim     = p.Results.pixdim;
            
            function fp = adjustFileprefix(fp)
                if ('_' == fp(1))
                    fp = [this.fileprefix fp]; return; end
                if ('_' == fp(end))
                    fp = [fp this.fileprefix]; return; end
            end
        end
        
        function this = NIfTId(datobj, fprefix, desc, pixdim)
            %% NIfTId is a copy ctor & also accepts Jimmy Sheng's NIfTI-structs or image arrays.
            %  It will also convert mlfourd.NIfTI objects to mlfourd.NIfTId.
            %  A minimal NIfTId has img, fileprefix, hdr.hist.descrip, hdr.dime.pixdim.
            %  Usage:  nii = NIfTId([object, fileprefix, descrip, pixdim])
            %                ^ ctor w/o args required by Matlab
            %                       ^ numeric arrays, NIfTId struct, NIfTId object
            %                               ^           ^ strings
            %                                                    ^ row vector of mm/pixel, length matched to
            %                                                      data object
            
            this = this@mlfourd.AbstractNIfTId;                       
            this = this.assignDefaults;
            
            %% Manage nargin 
            
            if (nargin > 4)
                error('mlfourd:InputParamErr', 'NIfTId could not process %i input args', nargin); end
            
            if (nargin > 0)
                this.originalType_ = class(datobj);

                import mlfourd.*;
                switch (this.originalType)
                    case 'char'
                        this = NIfTId.load(datobj);
                        switch (nargin)
                            case 2
                                this.fqfileprefix = fprefix;
                            case 3
                                this.fqfileprefix = fprefix;
                                this.descrip      = desc;
                            case 4
                                this.fqfileprefix = fprefix;
                                this.descrip      = desc;
                                this.pixdim       = pixdim;
                        end 
                    case 'struct'
                        this.img          = datobj.img;
                        this.hdr_         = datobj.hdr;
                        this.filetype_    = datobj.filetype;
                        this.fqfileprefix = datobj.fileprefix;
                        this.ext_         = datobj.ext;
                        this.untouch_     = datobj.untouch;
                        switch (nargin)
                            case 2
                                this.fileprefix   = fprefix;
                            case 3
                                this.fileprefix   = fprefix;
                                this.descrip      = desc;
                            case 4
                                this.fileprefix   = fprefix;
                                this.descrip      = desc;
                                this.pixdim       = pixdim;
                        end
                    otherwise
                        if (isnumeric(datobj))
                            rank                                 = length(size(datobj));
                            this.img                             = double(datobj);
                            this.hdr_.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                            this.hdr_.dime.dim                   = ones(1,8);
                            this.hdr_.dime.dim(1)                = rank;
                            this.hdr_.dime.dim(2:rank+1)         = size(datobj);
                            this.hdr_.dime.datatype              = 64;
                            this.hdr_.dime.bitpix                = 64;
                            switch (nargin)
                                case 2
                                    this.fqfileprefix = fprefix;
                                case 3
                                    this.fqfileprefix = fprefix;
                                    this.descrip      = desc;
                                case 4                              
                                    this.fqfileprefix = fprefix;
                                    this.descrip      = desc;
                                    this.pixdim       = pixdim;
                            end
                        elseif (isa(datobj, 'mlfourd.NIfTIInterface')) % convert to NIfTId                            
                            warning('off'); %#ok<WNOFF>
                            this = NIfTId(struct(datobj));
                            warning('on'); %#ok<WNON>
                            this.img = double(this.img);
                            switch (nargin)
                                case 2
                                    this.fileprefix = fprefix;
                                case 3
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                case 4
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                    this.pixdim     = pixdim;
                            end
                        elseif (isa(datobj, 'mlfourd.INIfTI')) % copy ctor
                            this.img          = datobj.img;
                            this.hdr_         = datobj.hdr;
                            this.filetype_    = datobj.filetype;
                            this.fqfileprefix = datobj.fqfileprefix;
                            this.ext_         = datobj.ext;
                            this.untouch_     = datobj.untouch;
                            this.label        = datobj.label;
                            this.separator    = datobj.separator;
                            switch (nargin)
                                case 2
                                    this.fileprefix = fprefix;
                                case 3
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                case 4
                                    this.fileprefix = fprefix;
                                    this.descrip    = desc;
                                    this.pixdim     = pixdim;
                            end
                        else
                            error('mlfourd:NotImplemented', ...
                                 ['NIfTId could not recognize datob with class->' class(datobj)]);
                        end
                end
            end
            if (~this.LOAD_UNTOUCHED)
                this = this.optimizePrecision; end
            this.stack = {this.descrip};
        end 
    end
   
    %% PRIVATE
 
    methods (Static, Access = 'private')
        function nii  = load_guessing_ext(fp, varargin)
            import mlfourd.*;
            exts = NIfTId.SUPPORTED_EXTENSIONS;
            desc0 = ['NIfTId.load_guessing_ext read ' fp ' on ' datestr(now)];
            p = inputParser;
            addRequired(p, 'fp',           @ischar);
            addOptional(p, 'desc', desc0,  @ischar)
            parse(p, fp, varargin{:});
            
            for e = 1:length(exts)
                if (lexist([fp exts{e}], 'file'))
                    nii = NIfTId.load_known_ext([fp exts{e}], exts{e}, p.Results.desc);
                    return
                end
            end
            error('mlfourd:malformedFilename', 'NIfTId.load_guessing_ext could not identify format of %s', fp);
        end
        function nii  = load_known_ext(fn, varargin)
            %% LOAD_KNOWN_EXT loads image formats listed in NIfTId.SUPPORTED_EXTENSIONS
            %  Usage:  nii = NIfTId.load_known_ext(filename[, extension, description])
            %                                      ^ filename with extension
            %                                                 ^ explicit extension, defaults to '.nii.gz'
            %                                                            ^ defaults to filename & time-stamp
            %  See also:  Jimmy Shen's load_untouch_nii
            
            import mlfourd.* mlniftitools.*;
            exts = NIfTId.SUPPORTED_EXTENSIONS;
            desc0 = ['NIfTId.load_known_ext read ' fn ' on ' datestr(now)];
            p = inputParser;
            addRequired(p, 'fn',           @(x) assert(lexist(x, 'file'), ...
                                                sprintf('NIfTId.load_known_ext:  file not found:  %s', fn)));
            addOptional(p, 'ext', exts{1}, @(x) any(strcmp(x, exts)));
            addOptional(p, 'desc', desc0,  @ischar)
            parse(p, fn, varargin{:});
            
            [pth,fp] = filepartsx(fn, p.Results.ext);
            s = false;
            try
                if (lstrfind(p.Results.ext, {'.nii.gz' '.nii'}))
                    nii = NIfTId(load_untouch_nii(fn));
                    nii.filepath = pth;
                    nii.fileprefix = fp;
                    nii.filesuffix = p.Results.ext;
                    nii.hdr_.hist.descrip = p.Results.desc;
                else
                    niiFqfn = fullfile(pth, [fp exts{1}]);                    
                    if (lstrfind(p.Results.ext, '.hdr'))
                        [s,r] = mlbash(sprintf('mri_convert -it analyze4d %s %s', fp, niiFqfn));
                    else
                        [s,r] = mlbash(sprintf('mri_convert %s %s', fn, niiFqfn));
                    end
                    nii = NIfTId.load_known_ext(niiFqfn, exts{1}, p.Results.desc); % will divert to first clause of if-else
                    if (NIfTId.CLEAN_UP_WORK_FILES)
                        mlbash(sprintf('rm %s', niiFqfn)); end
                end
            catch ME
                if (s); fprintf(r); end
                handexcept(ME);
            end
        end 
    end 
    
    methods (Access = 'private')
        function this     = assignDefaults(this)
            this.img_                     = zeros(3,3,3);
            this.fileprefix               = ['NIfTId_D' datestr(now,30)];
            this.filesuffix_              = mlfourd.INIfTI.FILETYPE_EXT;
            
            this.hdr_.hist                = struct;
            this.hdr_.hist.descrip        = ['NIfTId(' num2str(nargin) ' argin)'];
            this.hdr_.hist.originator     = [0 0 0];
            this.hdr_.hist.aux_file       = '';
            this.hdr_.hist.qform_code     = 0;
            this.hdr_.hist.sform_code     = 0;
            this.hdr_.hist.quatern_b      = 0;
            this.hdr_.hist.quatern_c      = 0;
            this.hdr_.hist.quatern_d      = 0;
            this.hdr_.hist.qoffset_x      = 0;
            this.hdr_.hist.qoffset_y      = 0;
            this.hdr_.hist.qoffset_z      = 0;
            this.hdr_.hist.srow_x         = zeros(1,4);
            this.hdr_.hist.srow_y         = zeros(1,4);
            this.hdr_.hist.srow_z         = zeros(1,4);
            this.hdr_.hist.intent_name    = '';
            this.hdr_.hist.magic          = 'n+1';          
          
            this.hdr_.dime                = struct;
            this.hdr_.dime.dim            = [3 3 3 3 1 1 1 1];
            this.hdr_.dime.intent_p1      = 0;
            this.hdr_.dime.intent_p2      = 0;
            this.hdr_.dime.intent_p3      = 0;
            this.hdr_.dime.intent_code    = 0;
            this.hdr_.dime.datatype       = 64;
            this.hdr_.dime.bitpix         = 64;
            this.hdr_.dime.slice_start    = 0;
            this.hdr_.dime.pixdim         = [-1 1 1 1 1 0 0 0];
            this.hdr_.dime.vox_offset     = 0;
            this.hdr_.dime.scl_slope      = 1;
            this.hdr_.dime.scl_inter      = 0;
            this.hdr_.dime.slice_end      = 0;
            this.hdr_.dime.slice_code     = 0;
            this.hdr_.dime.xyzt_units     = 1;
            this.hdr_.dime.cal_max        = 0;
            this.hdr_.dime.cal_min        = 0;
            this.hdr_.dime.slice_duration = 0;
            this.hdr_.dime.toffset        = 0;
            this.hdr_.dime.glmax          = 0;
            this.hdr_.dime.glmin          = 0;
            
            this.hdr_.hk                  = struct;
            this.hdr_.hk.sizeof_hdr       = 348;
            this.hdr_.hk.data_type        = '';
            this.hdr_.hk.db_name          = '';
            this.hdr_.hk.extents          = 0;
            this.hdr_.hk.session_error    = 0;
            this.hdr_.hk.regular          = 'r';
            this.hdr_.hk.diminfo          = 0;            
            this.hdr_.hk.dim_info         = 0;
            
            this.originalType_            = 'mlfourd.NIfTId';
        end
        function [tf,msg] = fieldsequaln(this, imobj)
            try
                [tf,msg] = this.checkFields(this, imobj, ...
                                            @(x) lstrfind(x, ['ISEQUAL_IGNORES' this.ISEQUAL_IGNORES 'hdr']));
                if (~tf); return; end                                  
                [tf,msg] = this.hdrsequaln(imobj);
            catch ME
                if (mlpipeline.PipelineRegistry.instance.verbosity > 0.5)
                    fprintf('NIfTId.fieldsequaln:  %s\n', msg);
                    handwarning(ME); 
                end
                tf = false;
            end
        end
        function [tf,msg] = hdrsequaln(this, imobj)
            tf = true; msg = '';
            if (isempty(this.hdr) && isempty(imobj.hdr))
                return; end
            [tf,msg] = this.checkFields(this.hdr.hk,   imobj.hdr.hk,   @(x) false);
            if (~tf)
                return; end
            [tf,msg] = this.checkFields(this.hdr.dime, imobj.hdr.dime, @(x) false);
            if (~tf)
                return; end
            [tf,msg] = this.checkFields(this.hdr.hist, imobj.hdr.hist, @(x) lstrfind(x, 'descrip'));            
        end
        function [tf,msg] = checkFields(~, obj1, obj2, toIgnore)
            tf = true; msg = '';
            flds = fieldnames(obj1);
            for f = 1:length(flds)
                if (~toIgnore(flds{f}))
                    if (~isequaln(obj1.(flds{f}), obj2.(flds{f})))
                        tf = false;
                        msg = sprintf('NIfTId.checkFields:  found mismatch at NIfTI.%s.', flds{f});
                        break
                    end
                end
            end
        end
    end 
    
end

