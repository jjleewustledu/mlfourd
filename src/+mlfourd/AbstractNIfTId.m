classdef AbstractNIfTId < mlio.AbstractIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI
	%% ABSTRACTNIFTID 
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
    
    properties (Constant)
        DESC_LEN_LIM = 1024*1024; % limit to #char of desc; accumulate extended descriptions with LoggingNIfTId
        LOAD_UNTOUCHED = true
        OPTIMIZED_PRECISION = false
    end
    
    properties (Dependent)
        
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
        
        %% New for AbstractNIfTId
        
        separator % for descrip & label properties, not for filesystem behaviors
        stack
    end 

 	methods %% SET/GET 
        
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
                    error('mlfourd:unsupportedParamValue', 'AbstractNIfTId.set.filetype.ft->%g', ft);
            end
        end
        function h    = get.hdr(this)
            h = this.hdr_;
            if (~isfield(h.hist, 'originator') || ...
                 isempty(h.hist.originator))                
                h.hist.originator = zeros(1,3); % KLUDGE for mlniftitools.save_nii_hdr line28
            end
        end 
        function im   = get.img(this)
            im = this.img_;
        end        
        function this = set.img(this, im)
            %% SET.IMG sets new image state. 
            %  updates datatype, bitpix, dim
            
            import mlfourd.*;
            if (islogical(im)); im = double(im); end
            assert(isnumeric(im));
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
            %% BIPPIX returns a datatype code as described by the NIfTId specificaitons
            
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
                          'NIfTId.get.bitpix could not recognize the class(img)->%s', class(this.img_));
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
            %% DATATYPE returns a datatype code as described by the NIfTId specificaitons
            
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
                          'NIfTId.get.datatype could not recognize the class(img)->%s', class(this.img_));
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
                              'NIfTId.set.datatype could not recognize dt->%s', strtrim(dt));
                end
            elseif (isnumeric(dt))
                if (dt < 64)
                    this = this.ensureSingle;
                else
                    this = this.ensureDouble;
                end
            else
                error('mlfourd:unsupportedDatatype', 'NIfTId.set.datatype does not support class(dt)->%s', class(dt));
            end            
            this.untouch_ = false;
        end
        function d    = get.descrip(this)
            d = this.hdr_.hist.descrip;
        end        
        function this = set.descrip(this, s)
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            
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
            if (exist(this.fqfilename, 'file'))
                [~, o] = mlbash(['fslorient -getorient ' this.fqfileprefix]);
            else
                o = '';
            end
            o = strtrim(o);
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
        
        %% New for AbstractNIfTId
        
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
        
        %% INIfTI  
        
        function ch   = char(this)
            ch = this.fqfilename;
        end 
        function this = append_descrip(this, varargin) 
            %% APPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with this.separator and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                argin = sprintf(varargin{:});
            else
                argin = varargin{:};
            end
            this.descrip = sprintf('%s%s %s', this.descrip, this.separator, argin);
            this.untouch_ = false;
        end  
        function this = prepend_descrip(this, varargin) 
            %% PREPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with prepended string and this.separator.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                argin = sprintf(varargin{:});
            else
                argin = varargin{:};
            end
            this.descrip = sprintf('%s%s %s', argin, this.separator, this.descrip);
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
                argin = sprintf(varargin{:});
            else
                argin = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', this.fileprefix, argin);
            this.untouch_ = false;
        end   
        function this = prepend_fileprefix(this, varargin)
            %% PREPEND_FILEPREFIX
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates fileprefix with prepended string and this.separator.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                argin = sprintf(varargin{:});
            else
                argin = varargin{:};
            end
            this.fileprefix = sprintf('%s%s', argin, this.fileprefix);
            this.untouch_ = false;
        end             
        function f3d  = fov(this)
            f3d = this.mmppix .* this.matrixsize;
        end   
        function m3d  = matrixsize(this)
            m3d = [this.size(1) this.size(2) this.size(3)];
        end
        function N    = numel(this)
            N = numel(this.img);
        end     
        function o    = ones(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', 'ones', @ischar);
            addOptional(p, 'fp',   [this.fileprefix '_ones'], @ischar);
            parse(p, varargin{:});
            o = this.makeSimilar('img', ones(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
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
                          'AbstractNIfTId.scrubNanInf:  this.rank(img) -> %i', this.rank(img__));
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
        function z    = zeros(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', 'zeros', @ischar);
            addOptional(p, 'fp',   [this.fileprefix '_zeros'],     @ischar);
            parse(p, varargin{:});
            z = this.makeSimilar('img', zeros(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end     
        
        %% New for AbstractNIfTId
        
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
        function        freeview(this, varargin)
            %% FREEVIEW
            %  Usage:  this.freeview([additional_filename, ...])
            
            this.launchExternalViewer('freeview', varargin{:});
        end
        function        fslview(this, varargin)
            %% FSLVIEW
            %  Usage:  this.fslview([additional_filename, ...])
            
            this.launchExternalViewer('fslview', varargin{:});
        end   
    end
    
    %% PROTECTED 

    properties (Access = protected)
        creationDate_
        ext_ = []
        filetype_ = 2
        hdr_
        img_ = []
        label_
        originalType_
        separator_ = ';'
        stack_
        untouch_ = true        
    end      
    
    methods (Access = protected)
        function this = AbstractNIfTId
            
            %% from Trio mpr & ep2d read by mlniftitools.load_untouch_nii
            
            this.fileprefix = ['instance_' strrep(class(this), '.', '_')];
            this.filesuffix = mlfourd.NIfTIInfo.NIFTI_EXT;
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
        
        function this = ensureDouble(this)
            if (isa(this.img_, 'double'))
                return
            end
            this.img_ = double(this.img_);
            this.hdr_.dime.datatype = 64;
            this.hdr_.dime.bitpix   = 64;
        end 
        function this = ensureSingle(this)
            if (isa(this.img_, 'single'))
                return
            end
            this.img_ = single(this.img_);
            this.hdr_.dime.datatype = 16;
            this.hdr_.dime.bitpix   = 32;
        end 
        function this = ensureUint8(this)
            if (isa(this.img_, 'uint8'))
                return
            end
            this.img_ = uint8(this.img_);
            this.hdr_.dime.datatype = 2;
            this.hdr_.dime.bitpix   = 8;
        end
        function this = optimizePrecision(this)
            if (~this.OPTIMIZED_PRECISION); return; end
            try
                import mlfourd.*;
                if (islogical(this.img_)) % ensures numerical operations on this.img_
                    this = this.ensureUint8;
                    return
                end
                if (dipmax(this.img_) <  realmax('single') && ...
                    dipmin(this.img_) > -realmax('single') && ...
                    dipmin(abs(this.img_)) > eps('single'))
                    this = this.ensureSingle;
                    return
                end                              
                this = this.ensureDouble;
            catch ME
                warning(ME);
            end
        end
    end 
    
    %% PRIVATE
    
    methods (Access = private)
        function d  = adjustDescrip(this, d)
            d = strtrim(d);
            if (length(d) > this.DESC_LEN_LIM)
                len2 = floor((this.DESC_LEN_LIM - 5)/2);
                d    = [d(1:len2) ' ... ' d(end-len2+1:end)]; 
            end
        end
        function      launchExternalViewer(this, app, varargin)
            assert(ischar(app));
            try
                fqfn = this.tempFqfilename;
                this.saveas(fqfn);
                s = 0; r = '';
                if (~isempty(varargin))
                    [s,r] = mlbash(sprintf('%s %s %s', app, fqfn, cell2str(varargin, 'AsRow', true)));
                else
                    [s,r] = mlbash(sprintf('%s %s',    app, fqfn));
                end
                deleteExisting(fqfn);
            catch ME
                handexcept(ME, 'mlfourd:viewerError', 'AbstractNIfTId.launchExternalViewer:  s->%i, r->%s', s, r);
            end
        end
        function im = scrub1D(this, im)
            assert(isnumeric(im));
            for x = 1:this.size(1)
                if (~isfinite(im(x)))
                    im(x) = 0; end
            end
        end
        function im = scrub2D(this, im)
            assert(isnumeric(im));
            for y = 1:this.size(2)
                for x = 1:this.size(1)
                    if (~isfinite(im(x,y)))
                        im(x,y) = 0; end
                end
            end
        end
        function im = scrub3D(this, im)
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
        function im = scrub4D(this, im)
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
        function fn = tempFqfilename(this)
            fn = sprintf('%s_%s%s', this.fqfileprefix, datestr(now, 30), mlfourd.NIfTIInfo.NIFTI_EXT);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
    
 end 
