classdef NIfTI < mlfourd.AbstractNIfTI
    %% NIFTI accepts Jimmy Shen's NIfTI-structs or image arrays.   Ctor w/o args is also allowed.
    %  A minimal NIfTI has hdr.dime.pixdim, hdr.hist.descrip, fileprefix & img.
    
    %  Created by John Lee on 2009-9-3.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.

    properties (Constant)
        ISEQUAL_IGNORES      = {'untouch' 'noclobber' 'debugging' 'filesuffix'   'label' ...
                                'descrip' 'machine'   'hdxml'     'creationDate' 'originalType' 'seriesNumber' 'hdr' 'ext'}; 
        NIFTI_SUBCLASS       = {'mlfourd.NIfTI' 'mlfourd.BlurringNIfTId' 'mlfourd.NiiBrowser' 'mlfourd.NIfTI_mask' 'mlfourd.NIfTId'} % @deprecated
    end
    
    properties (Dependent)
        descrip
        img
        mmppix
        pixdim
    end  
 
    properties % JimmyShenInterface:  to support struct arguments to NIfTI ctor
        originalType
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
        untouch  = true;
    end
    
    methods (Static) 
        function nii        = load(fn, varargin)
            %% LOAD 
            %  Usage:  nifti = NIfTI.load(fileprefix[, description])
            
            import mlfourd.*;            
            p = inputParser;
            addRequired(p, 'fn', @ischar);
            desc0 = ['NIfTI.load read ' fn ' on ' datestr(now)];
            addOptional(p, 'desc', desc0, @ischar);
            parse(p, fn, varargin{:});            
            [~, ~, fext] = fileparts(fn); 
            
            if (isempty(fext))
                nii = NIfTI.load_trials(fn, p.Results.desc); return; end
            if (strcmp(fext, '.gz'))
                nii = NIfTI.load_gz(    fn, p.Results.desc); return; end
            if (any(strcmp(fext, NIfTI.SUPPORTED_EXTENSIONS)))
                nii = NIfTI.load_suff(  fn, fext, p.Results.desc); return; end
            
            error('mlfourd:unsupportedParam', 'NIfTI.load does not support file-extension .%s', fext);
        end % static load               
        function [tf, obj1] = isNIfTI(obj)
            %% ISNIFTI
            %  Usage:  [truthval, obj] = isNIfTI(obj)
            %                                    ^ class, file
            %                     ^ obj may be modified to be valid NIfTI
            
            import mlfourd.*;
            tf = false;
            switch (class(obj))
                case 'char'
                    tf = exist(filename(obj), 'file');
                case 'struct'
                case NIfTI.NIFTI_SUBCLASS
                    try
                        obj1 = NIfTI.ensureNIfTI(obj);
                        tf   = exist('obj1', 'var');
                    catch ME %#ok<NASGU>
                        tf = false;
                    end
                otherwise
                    tf = false; obj1 = obj; return;
            end
            while (numel(tf) > 1)
                tf = all(tf);
            end
            tf = logical(tf);
        end % static isNIfTI             
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
            %% SET.IMG selects single or double representations, sets new state
            %  updates datatype, bitpix, dim
            %  Usages:  dip_image
            
            import mlfourd.*;
            %  following is very expensive per the profiler for large images, ~200s 
            this.img_                        = this.ensureNumeric(im);
            this                             = this.optimizePrecision;
            this.hdr.dime.dim                = zeros(1,8);
            this.hdr.dime.dim(1)             = this.rank;
            this.hdr.dime.dim(2:this.rank+1) = this.size;
            this.untouch = false;
        end   
        function mpp  = get.mmppix(this)
            mpp = this.hdr.dime.pixdim(2:this.rank+1);
        end        
        function this = set.mmppix(this, mpp)
            assert(all(this.rank == length(mpp)));
            this.hdr.dime.pixdim(2:this.rank+1) = mpp;
        end
        function pd   = get.pixdim(this)
            pd = this.mmppix;
        end        
        function this = set.pixdim(this, pd)
            this.mmppix = pd;
        end    
    end
    
    methods 
        function this = forceDouble(this)
            this.img_ = mlfourd.AbstractNIfTI.ensureDble(this.img_);
            this.hdr.dime.datatype = 64;
            this.hdr.dime.bitpix   = 64;
        end % forceDouble        
        function this = forceSingle(this)
            this.img_ = mlfourd.AbstractNIfTI.ensureSing(this.img_);
            this.hdr.dime.datatype = 16;
            this.hdr.dime.bitpix   = 32;
        end % forceSingle 
        function tf   = isequal(this, nii)
            tf = this.isequaln(nii);
        end
        function tf   = isequaln(this, nii)
            tf = isa(nii, class(this));
            if (tf)
                tf = this.fieldsequaln(nii);
            end
        end
        function        save(this)
            %% SAVE saves this NIfTI to this.fileprefix with extension .nii, then compresses with gzip
            
            import mlfourd.*;
            if (this.noclobber && lexist(this.fqfilename, 'file'))
                error('mlfourd:IOErr', 'NIfTI.save.fqfilename->%s already exists; stopping...%s', this.fqfilename); end
            warning('off');  %#ok<WNOFF>
            delete(this.fqfilename);
            if (this.untouch)
                mlniftitools.save_untouch_nii(struct(this), [this.fqfileprefix '.nii']);
            else
                mlniftitools.save_nii(        struct(this), [this.fqfileprefix '.nii']);
            end
            warning('on'); %#ok<WNON>
            this.gzip;
        end         
        
        function obj  = clone(this)
            obj = mlfourd.NIfTI(this, this.fqfileprefix, ['clone of ' this.descrip], this.pixdim);
        end        
        function nii  = makeSimilar(this, varargin) 
            %% MAKESIMILAR returns a similar NIfTI object
            %  n  = NIfTI(...)
            %  n1 = n.makeSimilar([img][, desc][, fpre][, pdim])
            %                      ^ image array or NIfTI
            %                             ^ appended to last desc
            %                                     ^ fileprefix
            %                                             ^ pixdim
    
            nii = mlfourd.NIfTI(this);      
            if (length(nii.descrip) > this.DESC_LEN_LIM)
                nii.descrip = nii.descrip(1:this.DESC_LEN_LIM); end
            
            p = inputParser;
            addOptional(p, 'img',  this.img,        @(x) ~isempty(x));
            addOptional(p, 'desc', 'made similar',  @ischar);
            addOptional(p, 'fpre', this.fileprefix, @ischar);
            addOptional(p, 'pdim', this.pixdim,     @(x) isnumeric(x) && this.rank == length(x));
            parse(p, varargin{:});             
            
            nii.img        = this.ensureNumeric(p.Results.img);
            nii            = nii.append_descrip(p.Results.desc);   
            nii.fileprefix = adjustFileprefix(p.Results.fpre);
            nii.pixdim     = p.Results.pdim;
            
            function fp = adjustFileprefix(fp)
                if ('_' == fp(1))
                    fp = [this.fileprefix fp]; return; end
                if ('_' == fp(end))
                    fp = [fp this.fileprefix]; return; end
            end
        end % makeSimilar  
        function this = NIfTI(datobj, fprefix, desc, pixdim)
            
            %% NIFTI is a copy ctor & also accepts Jimmy Sheng's NIfTI-structs or image arrays.
            %  A minimal NIfTI has hdr.dime.pixdim, hdr.hist.descrip, fileprefix & img
            %  Usage:  nii = NIfTI([object, fileprefix, descrip, pixdim])
            %                ^ ctor w/o args required by Matlab
            %                       ^ numeric arrays, NIfTI struct, NIfTI object
            %                               ^           ^ strings
            %                                                    ^ row vector of mm/pixel, length matched to
            %                                                      data object
            this = this@mlfourd.AbstractNIfTI;
            import mlfourd.*;
            
            %% Defaults
            
            this.filesuffix_             = mlfourd.NIfTIInterface.FILETYPE_EXT;
            
            this.img                     = zeros(2,2,2);
            this.fileprefix              = ['NIfTI_D' datestr(now,30)];
            this.hdr.hist                = struct;
            this.hdr.hist.descrip        = ['NIfTI(' num2str(nargin) ' argin)'];
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
            this.hdr.dime.dim            = [3 2 2 2 1 1 1 1];
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
            
            this.originalType            = 'mlfourd.NIfTI';
            
            %% Manage nargin 
            
            if (nargin > 0)
                this.originalType = class(datobj);
            end
            switch (nargin)
                case 0
                case 1
                    switch (this.originalType)
                        case 'char'
                            try
                                this = NIfTI.load(datobj);
                            catch ME
                                handexcept(ME, ['NIfTI.ctor.datobj could not be found on disk:  ' datobj]);
                            end
                        case numeric_types  
                            this.img                            = double(datobj);
                            this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                        case 'struct'                            
                            this.img          = datobj.img;
                            this.hdr          = datobj.hdr;
                            this.fqfileprefix = datobj.fileprefix;
                        case this.NIFTI_SUBCLASS
                            this.img          = datobj.img;
                            this.hdr          = datobj.hdr;
                            this.fqfileprefix = datobj.fqfileprefix;
                        otherwise
                            error('mlfourd:NotImplemented', ['NIfTI could not recognize datob with class->' class(datobj)]);
                    end
                case 2
                    switch (this.originalType)                        
                        case 'char'
                            try
                                this = NIfTI.load(datobj);
                            catch ME
                                handexcept(ME, ['NIfTI.ctor.datobj could not be found on disk:  ' datobj]);
                            end
                        case numeric_types
                            this.img                            = double(datobj);
                            this.fqfileprefix                   = fprefix;
                            this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                        case horzcat(this.NIFTI_SUBCLASS, 'struct')
                            this.img          = datobj.img;
                            this.hdr          = datobj.hdr;
                            this.fqfileprefix = fprefix;
                        otherwise
                            error('mlfourd:NotImplemented', ['NIfTI could not recognize datob with class->' class(datobj)]);
                    end
                case 3
                    switch (this.originalType)                        
                        case 'char'
                            try
                                this = NIfTI.load(datobj);
                            catch ME
                                handexcept(ME, ['NIfTI.ctor.datobj could not be found on disk:  ' datobj]);
                            end
                        case numeric_types
                            this.img                            = double(datobj);
                            this.fqfileprefix                   = fprefix;
                            this.descrip                        = desc;
                            this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                        case horzcat(this.NIFTI_SUBCLASS, 'struct')
                            this.img          = datobj.img;
                            this.hdr          = datobj.hdr;
                            this.fqfileprefix = fprefix;
                            this.descrip      = desc;
                        otherwise
                            error('mlfourd:NotImplemented', ['NIfTI could not recognize datob with class->' class(datobj)]);
                    end
                case 4
                    switch (this.originalType)                        
                        case 'char'
                            try
                                this = NIfTI.load(datobj);
                            catch ME
                                handexcept(ME, ['NIfTI.ctor.datobj could not be found on disk:  ' datobj]);
                            end
                        case numeric_types
                            this.img          = double(datobj);
                            this.fqfileprefix = fprefix;
                            this.descrip      = desc;
                            this.pixdim       = pixdim;
                        case horzcat(this.NIFTI_SUBCLASS, 'struct')
                            this.img          = datobj.img;
                            this.hdr          = datobj.hdr;
                            this.fqfileprefix = fprefix;
                            this.descrip      = desc;
                            this.pixdim       = pixdim;
                        otherwise
                            error('mlfourd:NotImplemented', ['NIfTI could not recognize datob with class->' class(datobj)]);
                    end
                otherwise
                    error('mlfourd:InputParamErr', ['NIfTI could not process ' num2str(nargin) ' input args']);
            end
            
            %% Manage structs and NIfTIs (copy ctors)
            
            if (nargin > 0 && ...
               (isstruct(datobj) || isa(datobj, 'mlfourd.NIfTIInterface')))
                                            obj_fields = fieldnames(datobj);
                if (any(strcmp('filetype',  obj_fields))); this.filetype   = datobj.filetype;  end
                if (any(strcmp('separator', obj_fields))); this.separator_ = datobj.separator; end
                if (any(strcmp('ext',       obj_fields))); this.ext        = datobj.ext;       end
                if (any(strcmp('untouch',   obj_fields))); this.untouch    = datobj.untouch;   end
                if (any(strcmp('descrip',   obj_fields)) && nargin > 2)
                                                           this.descrip    = datobj.descrip;   
                end
            end
        end 
    end
   
    %% PROTECTED
 
    properties (Access = 'protected')
        img_
    end
        
    methods (Static, Access = 'protected')
        function nii  = ensureNIfTI(obj)
            %% ENSURENIFTI tries to return a well-formed mlfourd.NIfTI for the passed object
            %  Usage:  nii1 = ensureNIfTI(nii)
            %                             ^ char, NIfTI, struct, numeric
            %          ^ NIfTI
            
            import mlfourd.*; 
            switch (class(obj))
                case 'char'
                    try
                        obj = NIfTI.load(obj);
                    catch ME
                        handexcept(ME);
                    end
                case 'mlfourd.NIfTI'
                case ['struct' numeric_types]
                    obj = NIfTI(obj);
                otherwise
                    error('mlfourd:UnsupportedTypeErr', 'NIfTI.ensureNIfTI:  class(nii)->%s', class(obj));
            end
            
            %% Self-Consistency Checks 
            try
                %% Check existence of required fields
                
                assert(lstrfind(fieldnames(obj),          'hdr')); % NIfTI.hdr is read-only
                assert(lstrfind(fieldnames(obj.hdr),      'dime'));
                assert(lstrfind(fieldnames(obj.hdr.dime), 'pixdim'));
                assert(lstrfind(fieldnames(obj.hdr),      'hist'));
                assert(lstrfind(fieldnames(obj.hdr.hist), 'descrip'));
                obj = ensurefield(obj,                            'fileprefix', @ischar, {}, ...
                                ['from_mlfourd_NIfTI_ensureNIfTI_' datestr(now,30)]);
                obj = ensurefield(obj,                            'img',  @isnumeric, {}, []);

                %% Check field values
                
                if (isa(obj, 'mlfourd.NIfTI'))
                    assert(   all(obj.hdr.dime.dim(2:obj.rank+1) == size(obj.img)));
                    assert(size(size(obj.img), 2) == obj.rank);
                end
                obj.img       = NIfTI.ensureDble(obj.img);
                obj.hdr.hist = ensurefield(obj.hdr.hist, 'qform_code', @isnumeric, {}, 0);
                obj.hdr.hist = ensurefield(obj.hdr.hist, 'sform_code', @isnumeric, {}, 0);
                obj.hdr.hk   = ensurefield(obj.hdr.hk,   'dim_info',   @isnumeric, {}, 0);
                obj.hdr.dime = ensurefield(obj.hdr.dime, 'scl_slope',  @isnumeric, {}, 1);
                obj.hdr.dime = ensurefield(obj.hdr.dime, 'xyzt_units', @isnumeric, {}, 10);
                
                fields = { 'intent_p1' 'intent_p2' 'intent_p3'  'intent_code'    'slice_start' ...
                           'scl_inter' 'slice_end' 'slice_code' 'slice_duration' 'toffset' }; 
                for f = 1:length(fields) %#ok<FORFLG>
                obj.hdr.dime = ensurefield(obj.hdr.dime,  fields{f},   @isnumeric, {}, 0); 
                end
                assert(length(obj.hdr.dime.dim) == length(obj.hdr.dime.pixdim));
                if (obj.hdr.dime.dim(1) ~= size(size(obj.img),2)) % set dim to match img size
                    obj.hdr.dime.dim(1)  = size(size(obj.img),2);
                end
                
                fields2 = { 'quatern_b' 'quatern_c' 'quatern_d' ...
                            'qoffset_x' 'qoffset_y' 'qoffset_z' };
                for f = 1:length(fields2) %#ok<FORFLG>
                    obj.hdr.hist = ensurefield(obj.hdr.hist, fields2{f}, @isnumeric, {}, 0); 
                end
                
                fields3 = { 'srow_x' 'srow_y' 'srow_z' };
                for f = 1:length(fields3) %#ok<FORFLG>
                    obj.hdr.hist = ensurefield(obj.hdr.hist, fields3{f}, @isnumeric, {}, [0 0 0 0]); 
                end
                obj.hdr.hist = ensurefield(obj.hdr.hist, 'originator',  @isnumeric, {}, 0);
                obj.hdr.hist = ensurefield(obj.hdr.hist, 'intent_name', @ischar,    {}, '');
                obj.hdr.hist = ensurefield(obj.hdr.hist, 'descrip',     @ischar, {}, ...
                                           ['NIfTI by NIfTI.ensureNIfTI at ' datestr(now)]);                              
                
                %% Make final assignments
                
                if (isstruct(obj))
                    nii = NIfTI(obj);
                else
                    nii = obj;
                end
            catch ME
                handexcept(ME);
            end
        end % static ensureNIfTI  
        function nii  = load_trials(fp, desc)
            import mlfourd.*;
            vprintf('\nNIfTI.load_trials:  guessing format for file %s ', fp);
            for e = 1:length(NIfTI.SUPPORTED_EXTENSIONS)
                try  
                    vprintf('....');
                    fn  = [fp NIfTI.SUPPORTED_EXTENSIONS{e}];
                    fn  =     NIfTI.cleanDotnii(fn);
                    nii =     NIfTI.load(fn, desc);
                    return
                catch ME
                    handexcept(ME);
                end
            end
            vprintf('\n');
            error('mlfourd:malformedFilename', 'NIfTI could not identify the format of %s (%s)', fp, desc);
        end
        function nii  = load_gz(fn, desc)
            import mlfourd.*;
            fn = NIfTI.cleanDotnii(fn);
            gunfiles = NIfTI.gunzip(fn);
            nii = NIfTI.load(gunfiles, desc);
            nii.filepath   = fileparts(nii.filepath);
            nii.filesuffix =          [nii.filesuffix '.gz'];
            NIfTI.cleanDotGunzip(gunfiles);
        end
        function nii  = load_suff(fn, suff, desc)
            %% LOAD_SUFF loads image formats listed in NIfTI.SUPPORTED_EXTENSIONS
            %  Usage:  nii = NIfTI.load_suff(filename[, extension, description])
            %                                ^ fully-qualified filename with extension
            %                                           ^ explicit extension, defaults to '.nii'
            %  See also:  Jimmy Shen's load_untouch_nii
            
            import mlfourd.*;
            p = inputParser;
            addRequired(p, 'fn', @(x) lexist(x, 'file'));
            addOptional(p, 'ext0', '.nii', @(x) any(strcmp(x, NIfTI.SUPPORTED_EXTENSIONS)));
            addOptional(p, 'desc', ['NIfTI.load_suff read ' fn ' on ' datestr(now)], @ischar)
            parse(p, fn, suff, desc);
            
            fn = p.Results.fn;
            fn = NIfTI.cleanDotnii(fn);
            [fpth, fpre, fext] = fileparts(fn);
            try
                switch (fext)
                    case {'.hdr.' '.nii'}
                        assert(lexist(fn, 'file'), sprintf('NIfTI.load_suff:  file not found:  %s', fn));
                        nii = NIfTI(mlniftitools.load_untouch_nii(fn), fpre, p.Results.desc);
                        nii.filepath = fpth;
                        nii.filesuffix = suff;
                    case {'.mgz' '.mgh'}
                        niifile = fullfile(fpth, [fpre '.nii.gz']);
                        mlbash(sprintf('mri_convert %s %s', fn, niifile));
                        nii = NIfTI.load(niifile);
                    otherwise
                        error('mlfourd:unsupportedFiletype', 'NIfTI.load_suff does not support extension %s', fext);
                end
            catch ME
                handexcept(ME);
            end
        end 
    end 
    
    methods (Access = 'protected')
        function this = optimizePrecision(this)
            import mlfourd.*;
            try
                bandwidth = dipmax(this.img_) - dipmin(this.img_);
                if (islogical(this.img_))
                    this.img_ = NIfTI.ensureUint8(this.img_);                    
                    this.hdr.dime.datatype = 2;
                    this.hdr.dime.bitpix   = 8;
                    return
                end
                if (bandwidth < realmax('single')/10)
                    if (bandwidth > 10*realmin('single'))
                        this.img_ = NIfTI.ensureSing(this.img_);
                        this.hdr.dime.datatype = 16;
                        this.hdr.dime.bitpix   = 32;
                        return
                    end
                end
                
                % default double
                                
                this.img_ = NIfTI.ensureDble(this.img_);
                this.hdr.dime.datatype = 64;
                this.hdr.dime.bitpix   = 64;
            catch ME
                warning(ME.message);
            end
        end
        function tf   = fieldsequaln(this, imobj)
            try
                tf   = true;
                flds = fieldnames(this);
                for f = 1:length(flds)
                    if (~any(strcmp(flds{f}, this.ISEQUAL_IGNORES)))
                        tf = tf && isequaln(this.(flds{f}), imobj.(flds{f}));
                        if (~tf); break; end
                    end
                end
            catch ME
                if (mlpipeline.PipelineRegistry.instance.verbosity > 0.98)
                    handwarning(ME); end
                tf = false;
            end
        end
        function fns  = gzip(this)
            fns = gzip([this.fqfileprefix '.nii']);
            delete(    [this.fqfileprefix '.nii']);
        end
    end 
    
end % classdef

