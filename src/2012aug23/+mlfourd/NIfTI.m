classdef NIfTI < mlfourd.AbstractImage
    %% NIFTI accepts Jimmy Sheng's NIfTI-structs or image arrays.   Ctor w/o args is also allowed.
    %  A minimal NIfTI has hdr.dime.pixdim, hdr.hist.descrip, fileprefix & img
    %  Usage:  nii = NIfTI([in , fileprefix, descrip])
    %                      ^ ctor w/o args required by Matlab
    %                       ^ numeric arrays, NIfTI struct, NIfTI object
    %  Created by John Lee on 2009-9-3.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to bug.jjlee.wustl.edu@gmail.com.

    properties (Constant)
        FILETYPE        =  'NIFTI_GZ';
        FILETYPE_EXT    =  '.nii.gz';
        NIFTI_SUBCLASS  = {'mlfourd.NIfTI' 'mlfourd.NiiBrowser' 'mlfourd.NIfTI_mask'}
       %MD5_REGEX       = ')\s+=\s+(?<hash>\w+)';
    end
    
    properties
        filetype   = 2;  % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        separator  = '; '; % for comments, not filesystem
        rescaling  = '';
        fileprefix
        filepath
    end
       
    properties (Dependent)
        img
        descrip
        datatype
        bitpix
        hdxml
        mmppix
        orient
        pixdim
    end  
 
    properties (SetAccess = 'protected')
        originalType
        hdr     
        ext
        
        %% N.B.:  to change the data type, set nii.hdr.dime.datatype,
 	    %         and nii.hdr.dime.bitpix to:
        %
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
    end
    
    methods (Static)
        
        function nii  = load(fn, desc)
            %% LOAD is a NIfTI factory that loads filename fn
            %  See also:   Jimmy Shen's load_untouch_nii, load_ext, load_nii_gz
            
            import mlfourd.* mlfsl.*;
            switch (nargin)
                case 1
                    desc = ['NIfTI.load read ' fn ' on ' datestr(now)];
                case 2
                otherwise
                    error('mlfourd:NotImplemented', ['NIfTI.load.nargin->' num2str(nargin)]);
            end
            assert(ischar(fn));
            assert(ischar(desc));
            [fpth, fpre, fext] = fileparts(fn); 
            if (~isempty(fext))
                if (strcmp(fext, '.gz'))
                    nii = NIfTI.load_nii_gz(fn, desc); 
                else
                    nii = NIfTI.load_ext(fn, fext, desc); 
                end
            else
                try
                    nii = NIfTI.load_nii_gz([fn '.nii.gz'], desc); 
                catch ME 
                    try
                        nii = NIfTI.load_ext([fn '.nii'], '.nii', desc);  
                    catch ME1 
                        ME1 = addCause(ME, ME1);
                        try
                            nii          = NIfTI(load_untouch_nii(fn), fpre, desc);
                            nii.filepath = fpth;
                        catch ME2 
                            ME2 = addCause(ME1, ME2);
                            handexcept(ME2, 'mlfourd:IOError', 'NIfTI.load');
                        end
                    end
                end
            end
        end % static load
        function nii  = load_hdr(varargin)
            nii              = mlfourd.NIfTI.load(varargin{:});
            %nii.img_internal = NaN;
        end % static load_hdr
        function nii  = load_ext(fn, ext0, desc)
            %% LOAD_EXT loads NIfTI (*.nii) or Analyze (*.hdr)
            %  See also:  Jimmy Shen's load_untouch_nii
            
            import mlfourd.*;
            switch (nargin)
                case 1
                    ext0 = '.nii';
                    desc = ['NIfTI.load_ext read ' fn ' on ' datestr(now)];
                case 2
                    desc = ['NIfTI.load_ext read ' fn ' on ' datestr(now)];
                case 3
                otherwise
                    error('mlfourd:NotImplemented', ['NIfTI.load_ext.nargin->' num2str(nargin)]);
            end
            assert(ischar(fn));
            assert(ischar(desc));
            [fpth, fpre, fext] = fileparts(fn);
            assert(strcmp(ext0, fext));
            try
                nii          = mlfourd.NIfTI(load_untouch_nii(fn), fpre, desc);
                nii.filepath = fpth;
            catch ME
                handexcept(ME, 'mlfourd:IOError', ['NIfTI.load_' fext]);
            end
        end % static load_ext 
        function nii  = load_nii_gz(fn, desc)
            
            %% LOAD_NII_GZ gunzips a file, loads it & deletes intermediary files
            %  See also:  load_ext
            import mlfourd.*;
            switch (nargin)
                case 1
                    desc = ['NIfTI.load_nii_gz read ' fn ' on ' datestr(now)];
                case 2
                otherwise
                    error('mlfourd:NotImplemented', ['NIfTI.load_nii_gz.nargin->' num2str(nargin)]);
            end
            assert(ischar(fn));
            assert(ischar(desc));
            [fpth, f, e] = fileparts(fn);
            assert(strcmp('.gz', e));
            [~, ~, e] = fileparts(f);
            assert(strcmp('.nii', e));
            try
                fns          = gunzip(fn, getenv('TMPDIR')); % gunzip returns *.nii in fns{1}
                nii          = mlfourd.NIfTI.load_ext(fns{1}, '.nii', desc);
                nii.filepath = fpth;
                delete(fns{1});
            catch ME 
                handexcept(ME, 'mlfourd:IOError', 'NIfTI.load_nii_gz');
            end
        end % static load_nii_gz
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
            
            % Self-Consistency Checks =======================================================================
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
                obj.img      = NIfTI.ensureDble(obj.img);
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
        function obj  = ensureSing(obj, nosqz)
            
            %% ENSURESING tries to return a single-precision array for the passed object
            %  Usage: obj1 = mlfourd.NIfTI.ensureSing(obj, nosqz)
            %         ^ is guaranteed to be single (all overloaded single(...) calls applied, else error)
            %           obj1, obj may be char, NIfTI, struct or numeric
            %                                              ^ don't squeeze out singleton dims
            import mlfourd.*;
            if (~exist('nosqz','var')); nosqz = false; end
            switch (class(obj))
                case 'char'
                    obj = filename(obj, NIfTI.FILETYPE_EXT);
                    obj = NIfTI.load(obj);
                    obj = single(obj.img);
                case {'mlfourd.ImageInterface' 'struct'}
                    obj = single(obj.img);
                case numeric_types
                    obj = single(obj);
                otherwise
                        error('mlfourd:UnsupportedTypeErr', ...
                             ['NIfTI.ensureDble received obj with unsupported type: ' class(obj)]);
            end
            if (~nosqz); obj = squeeze(obj); end
        end % static ensureSing
        function obj  = ensureDble(obj, nosqz)
            
            %% ENSUREDBLE tries to return a double-precision array for the passed object
            %  Usage: obj1 = mlfourd.NIfTI.ensureDble(obj, nosqz)
            %         ^ is guaranteed to be double
            %           obj1, obj may be char, NIfTI, struct or numeric
            %                                              ^ don't squeeze out singleton dims
            import mlfourd.*;
            if (~exist('nosqz','var')); nosqz = false; end
            switch (class(obj))
                case 'char'
                    obj = filename(obj, NIfTI.FILETYPE_EXT);
                    obj = NIfTI.load(obj);
                    obj = double(obj.img);
                case {'mlfourd.ImageInterface' 'struct'}
                    obj = double(obj.img);
                case numeric_types
                    obj = double(obj);
                otherwise
                        error('mlfourd:UnsupportedTypeErr', ...
                             ['NIfTI.ensureDble received obj with unsupported type: ' class(obj)]);
            end
            if (~nosqz); obj = squeeze(obj); end
        end % static ensureDble              
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
    end % static methods
    
    methods
        
        function this = NIfTI(datobj, fprefix, desc, pixdim)
            
            %% NIFTI is a copy ctor & also accepts Jimmy Sheng's NIfTI-structs or image arrays.
            %  A minimal NIfTI has hdr.dime.pixdim, hdr.hist.descrip, fileprefix & img
            %  Usage:  nii = NIfTI([object, fileprefix, descrip, pixdim])
            %                      ^ ctor w/o args required by Matlab
            %                       ^ numeric arrays, NIfTI struct, NIfTI object
            %                               ^           ^ strings
            %                                                    ^ row vector of mm/pixel, length matched to
            %                                                      data object
            this = this@mlfourd.AbstractImage;
            import mlfourd.*;
            
            %% Defaults
            
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
                            this.img = double(datobj);
                            this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                        case horzcat(this.NIFTI_SUBCLASS, {'struct'})
                            this.img        = datobj.img;
                            this.hdr        = datobj.hdr;
                            this.fileprefix = datobj.fileprefix;
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
                            this.img        = double(datobj);
                            this.fileprefix = fprefix;
                            this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                        case horzcat(this.NIFTI_SUBCLASS, 'struct')
                            this.img        = datobj.img;
                            this.hdr        = datobj.hdr;
                            this.fileprefix = fprefix;
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
                            this.img        = double(datobj);
                            this.fileprefix = fprefix;
                            this.descrip    = desc;
                            this.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
                        case horzcat(this.NIFTI_SUBCLASS, 'struct')
                            this.img        = datobj.img;
                            this.hdr        = datobj.hdr;
                            this.fileprefix = fprefix;
                            this.descrip    = desc;
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
                            this.img        = double(datobj);
                            this.fileprefix = fprefix;
                            this.descrip    = desc;
                            this.pixdim     = pixdim;
                        case horzcat(this.NIFTI_SUBCLASS, 'struct')
                            this.img        = datobj.img;
                            this.hdr        = datobj.hdr;
                            this.fileprefix = fprefix;
                            this.descrip    = desc;
                            this.pixdim     = pixdim;
                        otherwise
                            error('mlfourd:NotImplemented', ['NIfTI could not recognize datob with class->' class(datobj)]);
                    end
                otherwise
                    error('mlfourd:InputParamErr', ['NIfTI could not process ' num2str(nargin) ' input args']);
            end
            
            %% Manage structs and NIfTIs (copy ctors)
            
            if (nargin > 0 && ...
               (isstruct(datobj) || isa(datobj, 'mlfourd.ImageInterface')))
                                            obj_fields = fieldnames(datobj);
                if (    strcmp('filetype',  obj_fields)); this.filetype  = datobj.filetype;  end
                if (    strcmp('separator', obj_fields)); this.separator = datobj.separator; end
                if (    strcmp('ext',       obj_fields)); this.ext       = datobj.ext;       end
                if (    strcmp('untouch',   obj_fields)); this.untouch   = datobj.untouch;   end
                if (any(strcmp('descrip',   obj_fields)) && nargin > 2)
                                                          this.descrip   = datobj.descrip;   
                end
            end
        end % NIfTI ctor

        %% Getters, setters and close relatives
        function bp   = get.bitpix(this)
            
            %% BIPPIX returns a datatype code as described by the NIfTI specificaitons
            switch (class(this.img))
                case {'uchar', 'uint8'};    bp = 8;
                case  'int16';              bp = 16;
                case  'int32';              bp = 32;
                case {'single', 'float32'}; bp = 32;
                case {'double', 'float64'}; bp = 64;
                case  'schar';              bp = 8;
                case  'uint16';             bp = 16;
                case  'uint32';             bp = 32;
                case  'int64';              bp = 64;
                case  'uint64';             bp = 64;
                otherwise
                    throw(MException('mlfourd:UnknownParamType', ...
                        ['NIfTI.get.bitpix:  class(img) -> ' class(this.img)]));
            end
        end        
        function this = set.bitpix(this, bp)
            
            assert(isnumeric(bp));
            if (bp >= 64)
                this = this.forceDouble; 
            else
                this = this.forceSingle; 
            end
        end        
        function dt   = get.datatype(this)
            
            %% DATATYPE returns a datatype code as described by the NIfTI specificaitons
            %
            switch (class(this.img))
                case {'uchar', 'uint8'};    dt = 2;
                case  'int16';              dt = 4;
                case  'int32';              dt = 8;
                case {'single', 'float32'}; dt = 16;
                case {'double', 'float64'}; dt = 64;
                case  'schar';              dt = 256;
                case  'uint16';             dt = 512;
                case  'uint32';             dt = 768;
                case  'int64';              dt = 1024;
                case  'uint64';             dt = 1280;
                otherwise
                    throw(MException('mlfourd:UnknownParamType', ...
                        ['NIfTI.get.datatype:  class(img) -> ' class(this.img)]));
            end
        end         
        function this = set.datatype(this, dt)
            
            if (ischar(dt))
                switch (strtrim(dt))
                    case {'uchar', 'uint8', 'int16',  'int32', 'int', 'single', 'float32', 'float', ...
                          'schar',          'uint16', 'uint32'}
                        this = this.forceSingle;
                    case {'int64', 'uint64' 'double', 'float64'}
                        this = this.forceDouble;
                    otherwise
                        throw(MException('mlfourd:UnknownParamType', ...
                            ['NIfTI.set.datatype:  class(img) -> ' class(this.img)]));
                end
            elseif (isnumeric(dt))
                if (dt < 64)
                    this = this.forceSingle;
                else
                    this = this.forceDouble;
                end
            else
                paramError('UnsupportedType for NIfTI.set.datatype.dt', class(dt));
            end
        end           
        function d    = get.descrip(this)
            d = this.hdr.hist.descrip;
        end        
        function this = set.descrip(this, s)
            
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            assert(ischar(s));
            this.hdr.hist.descrip = strtrim(s);
            this.untouch = 0;
        end        
        function this = prepend_descrip(this, s)
            
            %% PREPEND_DESCRIP
            %  do not add separators such as ";" or ","
            assert(ischar(s));
            this.hdr.hist.descrip = [s this.separator this.hdr.hist.descrip];
        end        
        function this = append_descrip(this, s)
            
            %% APPEND_DESCRIP
            %  do not add separators such as ";" or ","
            assert(ischar(s));
            this.hdr.hist.descrip = [this.hdr.hist.descrip this.separator s];
        end    
        function this = set.filepath(this, pth)
            if (lexist(pth, 'dir'))
                this.filepath = pth;
            else
                if (~isempty(pth))
                    warning('mlfourd:IOError', 'NIfTI.set.filepath could not find %s; substituting %s', pth, pwd);
                end
                this.filepath = pwd;
            end
        end
        function this = set.fileprefix(this, fp)
            assert(ischar(fp));
            fp  = strtrim(fp);
            dot = strfind(fp, this.FILETYPE_EXT);
            if (~isempty(dot))
                fp  = fp(1:dot(1)); 
            end
            [~,this.fileprefix,~] = fileparts(fp);
        end 
        function this = set.filetype(this, ft)
            
            %% SET.FILETYPE
            %  0 -> Analyze format .hdr/.img
            %  1 -> NIFTI .hdr/.img
            %  2 -> NIFTI .nii
            assert(isnumeric(ft));
            this.filetype = ft;
        end                 
        function x    = get.hdxml(this)
            
            %% GET.HDXML writes the xml file if this objects exists on disk
            if (exist(this.fqfn, 'file'))
                %if (~lexist([this.fqfp '.xml'], 'file'))
                %         mlbash(['fslhd -x ' this.fqfp ' > ' this.fqfp '.xml']);
                %end
                [~, x] = mlbash(['fslhd -x ' this.fqfp]);
                    x  = regexprep(x, 'sform_ijk matrix', 'sform_ijk_matrix');
            else
                x = '';
            end
            
        end
        function im   = get.img(this)
            if (isnan(this.img_internal))
                this = mlfourd.NIfTI.load(this.fqfilename);
            end
            im = this.img_internal;
        end        
        function this = set.img(this, image)
            %% SET.IMG selects single or double representations, sets new state
            %  updates datatype, bitpix, dim
            %  Usages:  dip_image
            
            import mlfourd.*;
            %  following is very expensive per the profiler for large images, ~200s            
            image                            = this.ensureNumericImage(image);
            this.img_internal                = image;
            this                             = this.optimizeImgPrecision(image);
            this.hdr.dime.dim                = zeros(1,8);
            this.hdr.dime.dim(1)             = this.rank;
            this.hdr.dime.dim(2:this.rank+1) = this.size;
            this.untouch = 0;
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
        function o    = get.orient(this)
            if (exist(this.fqfn, 'file'))                
                [~, o] = mlbash(['fslorient -getorient ' this.fqfp]);
            else
                o = '';
            end
        end
        
        %% Member functions, mostly involving numeric array img        
        function this = forceDouble(this)
            this.img_internal = mlfourd.NIfTI.ensureDble(this.img_internal);
            this.hdr.dime.datatype = 64;
            this.hdr.dime.bitpix   = 64;
        end % forceDouble        
        function this = forceSingle(this)
            this.img_internal = mlfourd.NIfTI.ensureSing(this.img_internal);
            this.hdr.dime.datatype = 16;
            this.hdr.dime.bitpix   = 32;
        end % forceSingle       
        function n1   = makeSimilar(this, img, desc, fpre, pdim)            
            %% MAKESIMILAR returns a similar NIfTI object
            %  n  = NIfTI(...)
            %  n1 = n.makeSimilar(this, img[, desc, fpre[, pdim]])
            %                           ^ image array or NIfTI
            %                                 ^ appended to last desc
            %                                       ^ fileprefix
            %                                              ^ pixdim
            
            import mlfourd.*;
            LLIM = 128;         % limit to #char of desc to use for default fileprefix
            n1   = NIfTI(this); % copy-ctor may not be necessary
            img  = this.ensureNumericImage(img);
            switch (nargin)
                case 2
                    n1.img        = img;
                    if (length(n1.descrip) > LLIM); n1.descrip = n1.descrip(1:LLIM); end
                    n1            = n1.prepend_descrip('similar to'); 
                    n1.fileprefix = this.fileprefix;
                case 3
                    n1.img        = img;
                    if (length(desc) > LLIM); desc = desc(1:LLIM); end 
                    n1            = n1.append_descrip(strtrim(desc)); 
                    n1.fileprefix = this.fileprefix;
                case 4
                    n1.img        = img;
                    n1            = n1.append_descrip(strtrim(desc)); 
                    if ('_' == fpre(1))
                        n1.fileprefix = [this.fileprefix fpre];
                    elseif ('_' == fpre(end))
                        n1.fileprefix = [fpre this.fileprefix];
                    else
                        n1.fileprefix = fpre;
                    end
                case 5
                    n1.img        = img;
                    n1            = n1.append_descrip(strtrim(desc));  
                    n1.fileprefix = fpre;
                    assert(isnumeric(pdim));   
                    assert(n1.rank == length(pdim));
                    n1.hdr.dime.pixdim(2:n1.rank+1) = pdim;
                otherwise
                    throw(MException('mlfourd:MethodSignatureErr', ...
                                    ['narg -> ' num2str(narg)]));
            end
            
        end % makeSimilar        
        function this = resetOriginator(this)
            this.hdr.hist.originator = [256 0 0]; % kludge, http://www.rotman-baycrest.on.ca/~jimmy/NIfTI/FAQ.htm
        end
        
        %% Overloaded methods        
        function        save(this)
            %% SAVE saves this NIfTI to this.fileprefix with extension .nii, then compresses with gzip
            
            import mlfourd.*;
            if (this.noclobber && lexist(this.fqfn, 'file'))
                error('mlfourd:IOErr', 'AbstractImage.save.fqfn->%s already exists; stopping...%s', this.fqfn);
            end
            warning('off');  %#ok<WNOFF>
            if (this.untouch)
                save_untouch_nii(struct(this), [this.fqfp '.nii']);
            else
                save_nii(        struct(this), [this.fqfp '.nii']);
            end
            warning('on'); %#ok<WNON>
            
            gzip(  [this.fqfp '.nii']);
            delete([this.fqfp '.nii']);
            if (this.forceRadiologic)
                mlbash(['fslorient -forceradiological ' this.fqfp]);
            end
        end % save        
        function this = saveas(this, fname)
            %% SAVEAS replaces this.filename, then saves the file if this.noclobber is not true
            
            assert( logical( ischar( fname)) && ...
                    logical(~isempty(fname)), ...
                   'NIfTI..saveas requires a well-formed filename, but received->%s...', char(fname));
            [p,f,~]         = fileparts(fname);
            this.filepath   = p;
            this.fileprefix = f;
            this.save;
        end % saveas  
        function tf   = isequal(this, nii)            
            tf = isa(nii, class(this));
            if (tf)
                tf = this.fieldsequal(nii);
            end
        end
    end % methods
   
    %% PRIVATE
    
    methods (Access = 'private')
        function this = optimizeImgPrecision(this, image)
            
            import mlfourd.*;
            if (isa(image, 'mlfourd.ImageInterface')); image = image.img; end
            if (islogical(image)); image = single(image); end
            bandwidth = dipmax(image) - dipmin(image);
            if (bandwidth > realmax('single') || bandwidth < 1/realmax('single'))
                this.img_internal = NIfTI.ensureDble(image);
                this.hdr.dime.datatype = 64;
                this.hdr.dime.bitpix   = 64;
            else
                this.img_internal = NIfTI.ensureSing(image);
                this.hdr.dime.datatype = 16;
                this.hdr.dime.datatyp  = 32;
            end
        end
    end % protected methods
end % classdef

