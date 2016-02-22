classdef InnerNIfTId < mlfourd.NIfTIdIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI
	%% INNERNIFTID 
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
    
    properties (Constant)
        DESC_LEN_LIM = 1024*1024; % limit to #char of desc; accumulate extended descriptions with LoggingNIfTId
    end
    
    properties (Dependent)
        
        %% NIfTIIO
        
        noclobber
        
        %% JimmyShenInterface to support struct arguments to NIfTId ctor
        
        ext        %   Legacy variable for mlfourd.JimmyShenInterface
        filetype   %   0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr        %   Tip: to change the data type, set nii.hdr.dime.datatype and nii.hdr.dime.bitpix to:
                   %     0 None                     (Unknown bit per voxel)  % DT_NONE, DT_UNKNOWN 
                   %     1 Binary                        (ubit1, bitpix=1)   % DT_BINARY 
                   %     2 Unsigned char        (uchar or uint8, bitpix=8)   % DT_UINT8, NIFTI_TYPE_UINT8 
                   %     4 Signed short                  (int16, bitpix=16)  % DT_INT16, NIFTI_TYPE_INT16 
                   %     8 Signed integer                (int32, bitpix=32)  % DT_INT32, NIFTI_TYPE_INT32 
                   %    16 Floating point    (single or float32, bitpix=32)  % DT_FLOAT32, NIFTI_TYPE_FLOAT32 
                   %    32 Complex, 2 float32      (Use float32, bitpix=64)  % DT_COMPLEX64, NIFTI_TYPE_COMPLEX64
                   %    64 Double precision  (double or float64, bitpix=64)  % DT_FLOAT64, NIFTI_TYPE_FLOAT64 
                   %   128 uint RGB                  (Use uint8, bitpix=24)  % DT_RGB24, NIFTI_TYPE_RGB24 
                   %   256 Signed char           (schar or int8, bitpix=8)   % DT_INT8, NIFTI_TYPE_INT8 
                   %   511 Single RGB              (Use float32, bitpix=96)  % DT_RGB96, NIFTI_TYPE_RGB96
                   %   512 Unsigned short               (uint16, bitpix=16)  % DT_UNINT16, NIFTI_TYPE_UNINT16 
                   %   768 Unsigned integer             (uint32, bitpix=32)  % DT_UNINT32, NIFTI_TYPE_UNINT32 
                   %  1024 Signed long long              (int64, bitpix=64)  % DT_INT64, NIFTI_TYPE_INT64
                   %  1280 Unsigned long long           (uint64, bitpix=64)  % DT_UINT64, NIFTI_TYPE_UINT64 
                   %  1536 Long double, float128   (Unsupported, bitpix=128) % DT_FLOAT128, NIFTI_TYPE_FLOAT128 
                   %  1792 Complex128, 2 float64   (Use float64, bitpix=128) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
                   %  2048 Complex256, 2 float128  (Unsupported, bitpix=256) % DT_COMPLEX128, NIFTI_TYPE_COMPLEX128 
        img
        originalType
        untouch
        
        %% INIfTI
        
        bitpix
        creationDate
        datatype
        descrip
        entropy
        hdxml
        label
        machine
        mmppix
        negentropy
        orient
        pixdim
        seriesNumber
        
        %% New for InnerNIfTId
        
        lexistFile
        logger
        separator % for descrip & label properties, not for filesystem behaviors
        stack
    end 

 	methods %% GET/SET
        
        %% NIfTIIO
        
        function tf   = get.noclobber(this)
            tf = this.noclobber_;
        end
        function this = set.noclobber(this, nc)
            nc = logical(nc);
            this.untouch_ = false;
            this.noclobber_ = nc;
            this.logger_.noclobber = nc;
        end
        
        %% JimmyShenInterface
        
        function e    = get.ext(this)
            e = this.ext_;
        end
        function f    = get.filetype(this)
            f = this.filetype_;
        end
        function this = set.filetype(this, ft)
            switch (ft)
                case 0
                    this.filetype_ = ft;
                    this.filesuffix = '.hdr';
                    this.untouch_ = false;
                case 1
                    this.filetype_ = ft;
                    this.filesuffix = '.hdr';
                    this.untouch_ = false;
                case 2
                    this.filetype_ = ft;
                    this.filesuffix = '.nii.gz';
                    this.untouch_ = false;
                otherwise
                    error('mlfourd:unsupportedParamValue', 'InnerNIfTId.set.filetype.ft->%g', ft);
            end
        end
        function h    = get.hdr(this)
            h = this.hdr_;
        end 
        function im   = get.img(this)
            im = this.img_;
        end        
        function this = set.img(this, im)
            %% SET.IMG sets new image state. 
            %  @param im is the incoming imaging array; converted to single if data bandwidth is appropriate.
            %  @return updates img, datatype, bitpix, dim.
            
            this.img_                         = im;
            this                              = this.optimizePrecision;
            this.hdr_.dime.dim                = ones(1,8);
            this.hdr_.dime.dim(1)             = this.rank;
            this.hdr_.dime.dim(2:this.rank+1) = this.size;
            
            this.untouch_ = false;
            this.stack_ = [{dbstack} this.stack_];
        end
        function o    = get.originalType(this)
            o = this.originalType_;
        end
        function u    = get.untouch(this)
            u = logical(this.untouch_);
        end
        
        %% INIfTI
        
        function bp   = get.bitpix(this) 
            %% BITPIX returns a datatype code as described by the INIfTI specifications
            
            switch (class(this.img_))
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
                    error('mlfourd:unknownSwitchCase', ...
                          'InnerNIfTId.get.bitpix could not recognize the class(img)->%s', class(this.img_));
            end
        end
        function this = set.bitpix(this, bp)
            assert(isnumeric(bp));
            if (bp >= 64)
                this = this.ensureDouble; 
            else
                this = this.ensureSingle; 
            end
            this.untouch_ = false;
        end
        function cdat = get.creationDate(this)
            cdat = this.creationDate_;
        end
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the INIfTI specificaitons
            
            switch (class(this.img_))
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
                    error('mlfourd:unknownSwitchCase', ...
                          'InnerNIfTId.get.datatype could not recognize the class(img)->%s', class(this.img_));
            end
        end
        function this = set.datatype(this, dt)
            if (ischar(dt))
                switch (strtrim(dt))
                    case {'uchar', 'uint8', 'int16',  'int32', 'int', 'single', 'float32', 'float', ...
                          'schar',          'uint16', 'uint32'}
                        this = this.ensureSingle;
                    case {'int64', 'uint64' 'double', 'float64'}
                        this = this.ensureDouble;
                    otherwise
                        error('mlfourd:unknownSwitchCase', ...
                              'InnerNIfTId.set.datatype could not recognize dt->%s', strtrim(dt));
                end
            elseif (isnumeric(dt))
                if (dt < 64)
                    this = this.ensureSingle;
                else
                    this = this.ensureDouble;
                end
            else
                error('mlfourd:unsupportedDatatype', 'InnerNIfTId.set.datatype does not support class(dt)->%s', class(dt));
            end            
            this.untouch_ = false;
        end
        function d    = get.descrip(this)
            d = this.hdr_.hist.descrip;
        end        
        function this = set.descrip(this, s)
            %% SET.DESCRIP
            %  @param s:  do not add separators such as ";" or ","
            
            assert(ischar(s));
            this.hdr_.hist.descrip = this.adjustDescrip(s);
            this.untouch_ = false;
        end   
        function E    = get.entropy(this)
            if (isempty(this.img_))
                E = nan;
            else
                E = entropy(double(this.img_));
            end
        end
        function x    = get.hdxml(this)
            %% GET.HDXML writes the xml file if this objects exists on disk
            
            if (~lexist(this.fqfilename, 'file'))
                x = '';
                return
            end
            [~,x] = mlbash(['fslhd -x ' this.fqfileprefix]);
            x = strtrim(regexprep(x, 'sform_ijk matrix', 'sform_ijk_matrix'));
        end 
        function d    = get.label(this)
            if (isempty(this.label_))
                [~,this.label_] = fileparts(this.fileprefix);
            end
            d = this.label_;
        end     
        function this = set.label(this, s)
            assert(ischar(s));
            this.label_ = strtrim(s);            
            this.untouch_ = false;
        end
        function ma   = get.machine(this) %#ok<MANU>
            ma.arch = computer('arch');
            [~,ma.maxsize ,ma.endian] = computer;
        end
        function mpp  = get.mmppix(this)
            mpp = this.hdr_.dime.pixdim(2:this.rank+1);
        end        
        function this = set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            %assert(all(this.rank == length(mpp)));
            this.hdr_.dime.pixdim(2:length(mpp)+1) = mpp;
            this.untouch_ = false;
        end  
        function E    = get.negentropy(this)
            E = -this.entropy;
        end
        function o    = get.orient(this)
            if (~isempty(this.orient_))
                o = this.orient_;
                return
            end
            if (lexist(this.fqfilename, 'file'))
                [~, o] = mlbash(['fslorient -getorient ' this.fqfileprefix]);
                o = strtrim(o);
                return
            end
            o = '';
        end
        function pd   = get.pixdim(this)
            pd = this.mmppix;
        end        
        function this = set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s.
            
            this.mmppix = pd;
        end  
        function num  = get.seriesNumber(this)
            num = mlchoosers.FilenameFilters.getSeriesNumber(this.fileprefix);
        end
        
        %% New for InnerNIfTId
        
        function tf   = get.lexistFile(this)
            tf = lexist(this.fqfilename, 'file');
        end
        function s    = get.logger(this)
            s = this.logger_;
        end
        function s    = get.separator(this)
            s = this.separator_;
        end
        function this = set.separator(this, s)
            if (ischar(s))
                this.separator_ = s;
                this.untouch_ = false;
            end
        end
        function s    = get.stack(this)
            %% GET.STACK
            %  See also:  doc('dbstack')
            
            s = this.stack_;
        end
    end
       
    methods
        
        %% NIfTIIO
        
        function        save(this)
            %% SAVE supports extensions 
            %  mlfourd.JimmyShenInterface.SUPPORTED_EXT and mlsurfer.SurferRegistry.SUPPORTED_EXT,
            %  defaulting to this.FILETYPE_EXT if needed. 
            %  If this.noclobber == true,  it will never overwrite files.
            %  If this.noclobber == false, it may overwrite files. 
            %  If this.untouch   == true,  it will never overwrite files.
            %  If this.untouch   == false, it may saving imaging data with modified state.
            %  @return saves this NIfTId to this.fqfilename.  
            %  @throws mlfourd.IOError:noclobberPreventedSaving, mlfourd:IOError:untouchPreventedSaving, 
            %  mlfourd.IOError:unsupportedFilesuffix, mfiles:unixException, MATLAB:assertion:failed            
            
            this.save_nii;
            this.saveLogger;
        end 
        function this = saveas(this, fn)
            %% SAVEAS
            %  @param fn updates internal filename
            %  @return this updates internal filename; sets this.untouch to false; serializes object to filename
            %  See also:  mlfourd.InnerNIfTId.save
            
            [p,f,e] = myfileparts(fn);
            if (isempty(e))
                e = this.FILETYPE_EXT;
            end
            this.fqfilename = fullfile(p, [f e]);
            this.untouch_ = false;
            this.save;
        end
        function        saveLogger(this)
            if (~isempty(this.logger_))
                this.logger_.fqfileprefix = this.fqfileprefix;
                this.logger_.save;
            end
        end
        
        %% INIfTI
        
        function this = append_descrip(this, varargin) 
            %% APPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with this.separator and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.descrip = sprintf('%s%s %s', this.descrip, this.separator, astring);
            this.addLog(astring);
            this.untouch_ = false;
        end  
        function this = prepend_descrip(this, varargin) 
            %% PREPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with prepended string and this.separator.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.descrip = sprintf('%s%s %s', astring, this.separator, this.descrip);
            this.addLog(astring);
            this.untouch_ = false;
        end
        function d    = double(this)
            if (~isa(this.img_, 'double'))
                d = double(this.img_);
            else 
                d = this.img_;
            end
        end        
        function d    = duration(this)
            if (this.rank > 3)
                d = this.size(4)*this.mmppix(4);
            else
                d = 1;
            end
        end   
        function this = append_fileprefix(this, varargin)
            %% APPEND_FILEPREFIX
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates fileprefix with this.separator and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', this.fileprefix, astring);
            this.addLog('append_fileprefix:  %s', astring);
            this.untouch_ = false;
        end   
        function this = prepend_fileprefix(this, varargin)
            %% PREPEND_FILEPREFIX
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates fileprefix with prepended string and this.separator.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', astring, this.fileprefix);
            this.addLog('prepend_fileprefix:  %s', astring);
            this.untouch_ = false;
        end             
        function f3d  = fov(this)
            f3d = this.mmppix .* this.matrixsize;
        end   
        function m3d  = matrixsize(this)
            m3d = [this.size(1) this.size(2) this.size(3)];
        end   
        function this = prod(this, varargin)
            %% PROD overloads prod for INIfTI
            
            this.img = prod(this.img_, varargin{:});
            this = this.append_fileprefix('_prod');
            this = this.append_descrip('prod');
        end
        function rnk  = rank(this, img)
            %% RANK squeezes this.img before reporting rank of this.img or passed img
            
            if (nargin < 2)
                img = this.img_; end
            rnk = size(size(img),2);
        end
        function this = scrubNanInf(this, varargin)
            p = inputParser;
            addOptional(p, 'obj', this.img_, @isnumeric);
            parse(p, varargin{:});
            img__ = double(p.Results.obj);
            
            if (all(isfinite(img__(:))))
                return; end
            switch (this.rank(img__))
                case 1
                    img__ = this.scrub1D(img__);
                case 2
                    img__ = this.scrub2D(img__);
                case 3
                    img__ = this.scrub3D(img__);
                case 4
                    img__ = this.scrub4D(img__);
                otherwise
                    error('mlfourd:unsupportedParamValue', ...
                          'InnerNIfTId.scrubNanInf:  this.rank(img) -> %i', this.rank(img__));
            end            
            this.img = img__;
        end
        function s    = single(this)
            if (~isa(this.img, 'single'))
                s = single(this.img_);
            else 
                s = this.img_;
            end
        end   
        function sz   = size(this, varargin)
            %% SIZE overloads Matlab's size
            
            if (nargin > 1)
                sz = size(this.img_, varargin{:});
            else
                sz = size(this.img_);
            end
        end
        function this = sum(this, varargin)
            %% SUM overloads sum for INIfTI
            
            this.img = sum(this.img_, varargin{:});
        end    
        
        %% New for InnerNIfTId
        
        function        addLog(this, varargin)
            %% ADDLOG
            %  @param lg is a textual log entry; it is entered into an internal logger which is a handle.
            
            if (isempty(this.logger_))
                return
            end
            this.logger_.add(varargin{:});
        end
        function e    = fslentropy(this)
            if (~lexist(this.fqfilename, 'file'))
                e = nan;
                return
            end
            [~,e] = mlbash(sprintf('fslstats %s -e', this.fqfileprefix));
            e = str2double(e);
        end
        function E    = fslEntropy(this)
            if (~lexist(this.fqfilename, 'file'))
                E = nan;
                return
            end
            [~,E] = mlbash(sprintf('fslstats %s -E', this.fqfileprefix));
            E = str2double(E);
        end 
        function        view(this, varargin)
            this.freeview(varargin{:});
        end
        function        freeview(this, varargin)
            %% FREEVIEW
            %  @param [filename[, ...]]
            
            this.launchExternalViewer('freeview', varargin{:});
        end
        function        fslview(this, varargin)
            %% FSLVIEW
            %  @param [filename[, ...]]
            
            this.launchExternalViewer('fslview', varargin{:});
        end   

        %% mlpatterns.Composite
        
        function this = add(~, ~) %#ok<STOUT>
            error('mlfourd:notImplemented', 'InnerNIfTId.add should not be called');
        end        
        function iter = createIterator(~) %#ok<STOUT>
            error('mlfourd:notImplemented', 'InnerNIfTId.createIterator should not be called');
        end
        function idx  = find(this, obj)
            if (this.isequal(obj))
                idx = 1;
                return
            end
            idx = [];
        end
        function obj  = get(this, idx)
            if (idx == 1)
                obj = this;
                return
            end
            obj = [];
        end
        function tf   = isempty(this)
            tf = isempty(this.img);
        end
        function len  = length(~)
            len = 1;
        end
        function        rm(~, ~)
            error('mlfourd:notImplemented', 'InnerNIfTId.rm should not be called');
        end
        function s    = csize(~)
            s = [1 1];
        end    
        
        %% Ctor
        
        function this = InnerNIfTId
            
            %% from Trio mpr & ep2d read by mlniftitools.load_untouch_nii
            
            this.fileprefix = sprintf('instance_%s_%s', strrep(class(this), '.', '_'), datestr(now, 30));
            this.filesuffix = this.FILETYPE_EXT;
            hk   = struct( ...
                'sizeof_hdr', 348, ...
                'data_type', '', ...
                'db_name', '', ...
                'extents', 0, ...
                'session_error', 0, ...
                'regular', 'r', ...
                'dim_info', 0);
            dime = struct( ...
                'dim', [4 0 0 0 0 1 1 1], ...
                'intent_p1', 0, ... 
                'intent_p2', 0, ... 
                'intent_p3', 0, ... 
                'intent_code', 0, ... 
                'datatype', 64, ... 
                'bitpix', 64, ... 
                'slice_start', 0, ... 
                'pixdim', [1 1 1 1 1 0 0 0], ... 
                'vox_offset', 352, ... 
                'scl_slope', 1, ... 
                'scl_inter', 0, ... 
                'slice_end', 0, ... 
                'slice_code', 0, ... 
                'xyzt_units', 10, ... 
                'cal_max', 0, ... 
                'cal_min', 0, ... 
                'slice_duration', 0, ... 
                'toffset', 0, ... 
                'glmax', 1621, ... 
                'glmin', 0);
            hist = struct( ...
                'descrip', sprintf('instance of %s', class(this)), ...
                'aux_file', '', ...
                'qform_code', 1, ...
                'sform_code', 1, ...
                'quatern_b', 0, ...
                'quatern_c', 0, ...
                'quatern_d', 0, ...
                'qoffset_x', 0, ...
                'qoffset_y', 0, ...
                'qoffset_z', 0, ...
                'srow_x', [1 0 0 0], ...
                'srow_y', [0 1 0 0], ...
                'srow_z', [0 0 1 0], ...
                'intent_name', '', ...
                'magic', 'n+1');
            this.hdr_ = struct('hk', hk, 'dime', dime, 'hist', hist);
            
            %% etc.
            
            this.creationDate_ = datestr(now);
            this.originalType_ = class(this);
            this.stack_ = {this.descrip};
        end        
    end
    
    %% HIDDEN
    
    properties %(Hidden)
        filepath_   = '';
        fileprefix_ = '';
        filesuffix_ = '';
        noclobber_  = true;
        
        creationDate_
        ext_ = []
        filetype_ = 2
        hdr_
        img_ = []
        label_
        logger_
        orient_ = ''
        originalType_
        separator_ = ';'
        stack_   
        untouch_ = true     
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function d    = adjustDescrip(this, d)
            d = strtrim(d);
            if (length(d) > this.DESC_LEN_LIM)
                len2 = floor((this.DESC_LEN_LIM - 5)/2);
                d    = [d(1:len2) ' ... ' d(end-len2+1:end)]; 
            end
        end
        function this = ensureDouble(this)
            this.hdr_.dime.datatype = 64;
            this.hdr_.dime.bitpix   = 64;
            if (isa(this.img_, 'double'))
                return
            end
            this.img_ = double(this.img_);
        end 
        function this = ensureExtension(this)
            if (isempty(this.filesuffix))
                this.filesuffix = this.FILETYPE_EXT;
            end
            assert(lstrfind(this.filesuffix, mlfourd.JimmyShenInterface.SUPPORTED_EXT) ||  ...
                   lstrfind(this.filesuffix, mlsurfer.SurferRegistry.SUPPORTED_EXT));
        end
        function this = ensureSingle(this)
            this.hdr_.dime.datatype = 16;
            this.hdr_.dime.bitpix   = 32;
            if (isa(this.img_, 'single'))
                return
            end
            this.img_ = single(this.img_);
        end 
        function this = ensureUint8(this)
            this.hdr_.dime.datatype = 2;
            this.hdr_.dime.bitpix   = 8;
            if (isa(this.img_, 'uint8'))
                return
            end
            this.img_ = uint8(this.img_);
        end
        function fqfn = fqfilenameNiiGz(this)
            if (~strcmp(this.filesuffix, this.FILETYPE_EXT))
                fqfn = [this.fqfileprefix this.FILETYPE_EXT];
                return
            end
            fqfn = this.fqfilename;
        end
        function tf   = hasJimmyShenExtension(this)
            tf = lstrfind(this.filesuffix, mlfourd.JimmyShenInterface.SUPPORTED_EXT);
        end
        function        launchExternalViewer(this, app, varargin)
            assert(ischar(app));
            fqfn = this.tempFqfilename;
            if (isempty(varargin))
                cmdline = sprintf('%s %s',    app, fqfn);
            else
                cmdline = sprintf('%s %s %s', app, fqfn, imaging2str(varargin{:}));
            end    
            s = 0; r = '';
            try
                this.saveas(fqfn);
                [s,r] = mlbash(cmdline);
                deleteExisting(fqfn);
            catch ME
                handexcept(ME, 'mlfourd:viewerError', ...
                    'InnerNIfTId.launchExternalViewer called mlbash with %s; \nit returned s->%i, r->%s', cmdline, s, r);
            end
        end
        function this = optimizePrecision(this)
            try
                if (isempty(this.img_))
                    this = this.ensureDouble;
                    return
                end
                if (islogical(this.img_)) % ensures numerical operations on this.img_
                    this = this.ensureUint8;
                    return
                end
                if (isa(this.img_, 'double'))
                    this = this.ensureDouble; % ensures bitpix, datatype
                    if (isempty(this.img_(this.img_ ~= 0)))
                        return
                    end
                    if ((dipmin(abs(this.img_(this.img_ ~= 0))) >= eps('single')) && ...
                        (dipmax(abs(this.img_(this.img_ ~= 0))) <= realmax('single')))
                        this = this.ensureSingle;
                        return
                    end
                end
            catch ME
                handerror(ME);
            end
        end
        function        save_nii(this)
            if (isempty(this.img))
                error('mlfourd:saveError', ...
                    'InnerNIfTId.save_nii:  mlnifittools.save_[untouch]_nii will throw MATLAB:badsubscript');
            end
            this = this.ensureExtension;
            if (this.noclobber && lexist(this.fqfilename, 'file'))
                error('mlfourd:IOError:noclobberPreventedSaving', ...
                      'NIfTId.save_nii.noclobber->%i and fqfilename->%s already exists; data not saved', this.noclobber, this.fqfilename);
            end
            if (this.untouch)
                this.save_untouch_nii;
                return
            end
            this = this.optimizePrecision;
            try
                if (this.hasJimmyShenExtension) 
                    warning('off', 'MATLAB:structOnObject');
                    mlniftitools.save_nii(struct(this), this.fqfilename);
                    warning('on', 'MATLAB:structOnObject');
                    return
                end
                warning('off', 'MATLAB:structOnObject');
                mlniftitools.save_nii(struct(this), this.fqfilenameNiiGz);            
                mlbash(sprintf('mri_convert %s %s', this.fqfilenameNiiGz, this.fqfilename));
                deleteExisting(this.fqfilenameNiiGz);
                warning('on', 'MATLAB:structOnObject');
            catch ME
                handerror(ME, ...
                    'mlfourd:IOError', ...
                    'InnerNIfTId.save_nii failed to save %s', this.fqfilename);
            end
        end
        function        save_untouch_nii(this)
            assert(this.untouch);            
            if (lexist(this.fqfilename, 'file'))
                error('mlfourd:IOError:untouchPreventedSaving', ...
                      'NIfTId.save_untouch_nii.untouch->%i and fqfilename->%s already exists; data not saved', this.untouch, this.fqfilename);
            end             
            this = this.optimizePrecision;
            try
                if (this.hasJimmyShenExtension) 
                    warning('off', 'MATLAB:structOnObject');
                    mlniftitools.save_untouch_nii(struct(this), this.fqfilename);
                    warning('on', 'MATLAB:structOnObject');
                    return
                end
                warning('off', 'MATLAB:structOnObject');
                mlniftitools.save_untouch_nii(struct(this), this.fqfilenameNiiGz);            
                mlbash(sprintf('mri_convert %s %s', this.fqfilenameNiiGz, this.fqfilename));
                deleteExisting(this.fqfilenameNiiGz);
                warning('on', 'MATLAB:structOnObject');
            catch ME
                handerror(ME, ...
                    'mlfourd:IOError', ...
                    'InnerNIfTId.save_untouch_nii failed to save %s', this.fqfilename);
            end
        end
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
        function fn   = tempFqfilename(this)
            fn = sprintf('%s_%s%s', this.fqfileprefix, datestr(now, 30), this.FILETYPE_EXT);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
    
 end 
