classdef NIfTId < mlfourd.AbstractNIfTId
    %% NIFTID accepts Jimmy Shen's NIfTI-structs or image arrays.   Ctor w/o args is also allowed.
    %  A minimal NIfTId has hdr.dime.pixdim, hdr.hist.descrip, fileprefix & img.
    
    %  Created by John Lee on 2009-9-3.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to bug.jjlee.wustl.edu@gmail.com.

    properties (Constant)
        ISEQUAL_IGNORES      = {'label' 'descrip' 'hdxml' 'creationDate' 'originalType'}
        SUPPORTED_EXTENSIONS = {'.nii.gz' '.nii' '.mgh' '.mgz' '.hdr' '.dcm' '.IMA'} % fist extension is default
        CLEAN_UP_WORK_FILES  = true
        OPTIMIZED_PRECISION  = false
    end
 
    properties (SetAccess = 'protected') 
        
        %% After mlfourd.JimmyShenInterface:  to support struct arguments to NIfTId ctor
        
        ext
        filetype = 2;  % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr            %     N.B.:  to change the data type, set nii.hdr.dime.datatype,
                       %            and nii.hdr.dime.bitpix to:
                       %   0 None                     (Unknown bit per voxel) 
                       %   1 Binary                         (ubit1, bitpix=1) 
                       %   2 Unsigned char         (uchar or uint8, bitpix=8) 
                       %   4 Signed short                  (int16, bitpix=16) 
                       %   8 Signed integer                (int32, bitpix=32) 
                       %  16 Floating point    (single or float32, bitpix=32) 
                       %  32 Complex, 2 float32      (Use float32, bitpix=64) 
                       %  64 Double precision  (double or float64, bitpix=64) 
                       % 512 Unsigned short               (uint16, bitpix=16) 
                       % 768 Unsigned integer             (uint32, bitpix=32) 
                       %1024 Signed long long              (int64, bitpix=64) % DT_INT64, NIFTI_TYPE_INT64
                       %1280 Unsigned long long           (uint64, bitpix=64) % DT_UINT64, NIFTI_TYPE_UINT64
        originalType
        untouch = true;
    end
    
    properties (Dependent)
        descrip
        img
        mmppix
        pixdim
    end  
    
    methods %% Set/Get 
        function d    = get.descrip(this)
            d = this.hdr.hist.descrip;
        end        
        function this = set.descrip(this, s)
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            
            assert(ischar(s));
            this.hdr.hist.descrip = strtrim(s);
            this.untouch = false;
        end       
        function im   = get.img(this)
            im = this.img_;
        end        
        function this = set.img(this, im)
            %% SET.IMG sets new image state.  If NIfTId.OPTIMIZED_PRECISION, selects single precision if tolerated by data.
            %  updates datatype, bitpix, dim
            
            import mlfourd.*;
            assert(isnumeric(im));
            if (this.OPTIMIZED_PRECISION)
                this                         = this.optimizePrecision; 
            elseif (isa(im, 'double'))
                this.img_                    = im;
            else
                this.img_                    = double(im);
            end
            this.hdr.dime.dim                = zeros(1,8);
            this.hdr.dime.dim(1)             = this.rank;
            this.hdr.dime.dim(2:this.rank+1) = this.size;
            this.untouch = false;
        end   
        function mpp  = get.mmppix(this)
            mpp = this.hdr.dime.pixdim(2:this.rank+1);
        end        
        function this = set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            assert(all(this.rank == length(mpp)));
            this.hdr.dime.pixdim(2:this.rank+1) = mpp;
        end
        function pd   = get.pixdim(this)
            pd = this.mmppix;
        end        
        function this = set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s.
            
            this.mmppix = pd;
        end    
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
            this.hdr.dime.datatype = 64;
            this.hdr.dime.bitpix   = 64;
        end % forceDouble        
        function this     = forceSingle(this)
            this.img_ = mlfourd.AbstractNIfTId.ensureSing(this.img_);
            this.hdr.dime.datatype = 16;
            this.hdr.dime.bitpix   = 32;
        end % forceSingle 
        function [tf,msg] = isequal(this, nii)
            [tf,msg] = this.isequaln(nii);
        end
        function [tf,msg] = isequaln(this, nii)
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
                save_nii(        struct(this), [this.fqfileprefix '.nii.gz']);
            end
            warning('on'); %#ok<WNON>
        end         
        
        function obj  = clone(this)
            obj = mlfourd.NIfTId(this, this.fqfileprefix, ['clone of ' this.descrip], this.pixdim);
        end        
        function nii  = makeSimilar(this, varargin)
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
                nii.descrip = nii.descrip(1:this.DESC_LEN_LIM); end
            
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
                this.originalType = class(datobj);

                import mlfourd.*;
                switch (this.originalType)
                    case 'char'
                        switch (nargin)
                            case 1
                                this              = NIfTId.load(datobj);
                            case 2
                                this              = NIfTId.load(datobj);
                                this.fqfileprefix = fprefix;
                            case 3
                                this              = NIfTId.load(datobj);
                                this.fqfileprefix = fprefix;
                                this.descrip      = desc;
                            case 4
                                this              = NIfTId.load(datobj);
                                this.fqfileprefix = fprefix;
                                this.descrip      = desc;
                                this.pixdim       = pixdim;
                        end 
                    case 'struct'
                        switch (nargin)
                            case 1
                                this.img          = datobj.img;
                                this.hdr          = datobj.hdr;
                                this.filetype     = datobj.filetype;
                                this.fqfileprefix = datobj.fileprefix;
                                this.ext          = datobj.ext;
                                this.untouch      = datobj.untouch;
                            case 2
                                this.img          = datobj.img;
                                this.hdr          = datobj.hdr;
                                this.descrip      = datobj.hdr.descrip;
                                this.filetype     = datobj.filetype;
                                this.fqfileprefix = datobj.fileprefix;
                                this.ext          = datobj.ext;
                                this.untouch      = datobj.untouch;
                                this.fileprefix   = fprefix;
                            case 3
                                this.img          = datobj.img;
                                this.hdr          = datobj.hdr;
                                this.filetype     = datobj.filetype;
                                this.fqfileprefix = datobj.fileprefix;
                                this.ext          = datobj.ext;
                                this.untouch      = datobj.untouch;
                                this.fileprefix   = fprefix;
                                this.descrip      = desc;
                            case 4
                                this.img          = datobj.img;
                                this.hdr          = datobj.hdr;
                                this.filetype     = datobj.filetype;
                                this.fqfileprefix = datobj.fileprefix;
                                this.ext          = datobj.ext;
                                this.untouch      = datobj.untouch;
                                this.fileprefix   = fprefix;
                                this.descrip      = desc;
                                this.pixdim       = pixdim;
                        end
                    otherwise
                        if (isnumeric(datobj))
                            switch (nargin)
                                case 1
                                    this.img                            = double(datobj);
                                    this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                                case 2
                                    this.img                            = double(datobj);
                                    this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                                    this.fqfileprefix                   = fprefix;
                                case 3
                                    this.img                            = double(datobj);
                                    this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                                    this.fqfileprefix                   = fprefix;
                                    this.descrip                        = desc;
                                case 4                                        
                                    this.img                            = double(datobj);
                                    this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                                    this.fqfileprefix                   = fprefix;
                                    this.descrip                        = desc;
                                    this.pixdim                         = pixdim;
                            end
                        elseif (isa(datobj, 'mlfourd.NIfTIdInterface')) % copy ctor
                            switch (nargin)
                                case 1                                        
                                    this.img          = datobj.img;
                                    this.hdr          = datobj.hdr;
                                    this.filetype     = datobj.filetype;
                                    this.fqfileprefix = datobj.fqfileprefix;
                                    this.ext          = datobj.ext;
                                    this.untouch      = datobj.untouch;
                                    this.label        = datobj.label;
                                    this.separator    = datobj.separator;
                                case 2
                                    this.img          = datobj.img;
                                    this.hdr          = datobj.hdr;
                                    this.filetype     = datobj.filetype;
                                    this.fqfileprefix = datobj.fqfileprefix;
                                    this.ext          = datobj.ext;
                                    this.untouch      = datobj.untouch;
                                    this.label        = datobj.label;
                                    this.separator    = datobj.separator;
                                    this.fileprefix   = fprefix;
                                case 3
                                    this.img          = datobj.img;
                                    this.hdr          = datobj.hdr;
                                    this.filetype     = datobj.filetype;
                                    this.fqfileprefix = datobj.fqfileprefix;
                                    this.ext          = datobj.ext;
                                    this.untouch      = datobj.untouch;
                                    this.label        = datobj.label;
                                    this.separator    = datobj.separator;
                                    this.fileprefix   = fprefix;
                                    this.descrip      = desc;
                                case 4
                                    this.img          = datobj.img;
                                    this.hdr          = datobj.hdr;
                                    this.filetype     = datobj.filetype;
                                    this.fqfileprefix = datobj.fqfileprefix;
                                    this.ext          = datobj.ext;
                                    this.untouch      = datobj.untouch;
                                    this.label        = datobj.label;
                                    this.separator    = datobj.separator;
                                    this.fileprefix   = fprefix;
                                    this.descrip      = desc;
                                    this.pixdim       = pixdim;
                            end
                        else
                            error('mlfourd:NotImplemented', ...
                                 ['NIfTId could not recognize datob with class->' class(datobj)]);
                        end
                end
            end
        end 
    end
   
    %% PRIVATE
 
    properties (Access = 'private')
        img_
    end
        
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
            try
                if (lstrfind(p.Results.ext, {'.nii.gz' '.nii'}))
                    nii = NIfTId(load_untouch_nii(fn));
                    nii.filepath = pth;
                    nii.fileprefix = fp;
                    nii.filesuffix = p.Results.ext;
                    nii.descrip = p.Results.desc;
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
            this.img                     = zeros(3,3,3);
            this.fileprefix              = ['NIfTId_D' datestr(now,30)];
            this.filesuffix_             = mlfourd.NIfTIdInterface.FILETYPE_EXT;
            
            this.hdr.hist                = struct;
            this.hdr.hist.descrip        = ['NIfTId(' num2str(nargin) ' argin)'];
            this.hdr.hist.originator     = [0 0 0];
            this.hdr.hist.aux_file       = '';
            this.hdr.hist.qform_code     = 0;
            this.hdr.hist.sform_code     = 0;
            this.hdr.hist.quatern_b      = 0;
            this.hdr.hist.quatern_c      = 0;
            this.hdr.hist.quatern_d      = 0;
            this.hdr.hist.qoffset_x      = 0;
            this.hdr.hist.qoffset_y      = 0;
            this.hdr.hist.qoffset_z      = 0;
            this.hdr.hist.srow_x         = zeros(1,4);
            this.hdr.hist.srow_y         = zeros(1,4);
            this.hdr.hist.srow_z         = zeros(1,4);
            this.hdr.hist.intent_name    = '';
            this.hdr.hist.magic          = 'n+1';          
          
            this.hdr.dime                = struct;
            this.hdr.dime.dim            = [3 3 3 3 1 1 1 1];
            this.hdr.dime.intent_p1      = 0;
            this.hdr.dime.intent_p2      = 0;
            this.hdr.dime.intent_p3      = 0;
            this.hdr.dime.intent_code    = 0;
            this.hdr.dime.datatype       = 64;
            this.hdr.dime.bitpix         = 64;
            this.hdr.dime.slice_start    = 0;
            this.hdr.dime.pixdim         = [-1 1 1 1 1 0 0 0];
            this.hdr.dime.vox_offset     = 0;
            this.hdr.dime.scl_slope      = 1;
            this.hdr.dime.scl_inter      = 0;
            this.hdr.dime.slice_end      = 0;
            this.hdr.dime.slice_code     = 0;
            this.hdr.dime.xyzt_units     = 1;
            this.hdr.dime.cal_max        = 0;
            this.hdr.dime.cal_min        = 0;
            this.hdr.dime.slice_duration = 0;
            this.hdr.dime.toffset        = 0;
            this.hdr.dime.glmax          = 0;
            this.hdr.dime.glmin          = 0;
            
            this.hdr.hk                  = struct;
            this.hdr.hk.sizeof_hdr       = 348;
            this.hdr.hk.data_type        = '';
            this.hdr.hk.db_name          = '';
            this.hdr.hk.extents          = 0;
            this.hdr.hk.session_error    = 0;
            this.hdr.hk.regular          = 'r';
            this.hdr.hk.diminfo          = 0;            
            this.hdr.hk.dim_info         = 0;
            
            this.originalType            = 'mlfourd.NIfTId';
        end
        function this     = optimizePrecision(this)
            import mlfourd.*;
            try
                bandwidth = dipmax(this.img_) - dipmin(this.img_);
                if (islogical(this.img_))
                    this.img_ = NIfTId.ensureUint8(this.img_);                    
                    this.hdr.dime.datatype = 2;
                    this.hdr.dime.bitpix   = 8;
                    return
                end
                if (bandwidth < realmax('single')/10)
                    if (bandwidth > 10*realmin('single'))
                        this.img_ = NIfTId.ensureSing(this.img_);
                        this.hdr.dime.datatype = 16;
                        this.hdr.dime.bitpix   = 32;
                        return
                    end
                end
                
                % default double
                                
                this.img_ = NIfTId.ensureDble(this.img_);
                this.hdr.dime.datatype = 64;
                this.hdr.dime.bitpix   = 64;
            catch ME
                warning(ME.message);
            end
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

