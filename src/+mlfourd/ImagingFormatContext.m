classdef ImagingFormatContext < handle & mlfourd.JimmyShenInterface & mlfourd.IImagingFormat
	%% IMAGINGFORMATCONTEXT and mlfourd.AbstractInnerImagingFormat together form a state design pattern.  Supported 
    %  states include mlfourd.InnerNIfTI, mlfourdfp.InnerFourdfp, mlsurfer.InnerMGH.  The state is configured by field  
    %  imagingInfo which is an mlfourd.{ImagingInfo,Analyze75Info,NIfTIInfo}, mlfourd.FourdfpInfo, mlfourd.MGHInfo.  
    %  The different available states predominantly manage different imaging formats.  Altering property filesuffix is a
    %  convenient way to change states for formats.
    %
	%  $Revision$
 	%  was created 24-Jul-2018 00:35:24 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%  It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
    
    properties (Constant)
        PREFERRED_EXT = '.nii.gz'
    end
 	
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
        
        ext
        filetype % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr
        img
        originalType
        untouch
        
        bitpix
        creationDate
        datatype
        descrip
        entropy
        hdxml
        label
        machine
        mmppix
        N
        negentropy
        orient % RADIOLOGICAL, NEUROLOGICAL
        originator
        pixdim
        seriesNumber
        
        filesystem
        imagingInfo
        logger
        separator % for descrip & label properties, not for filesystem behaviors
        stack
        stateTypeclass
        viewer
    end
    
    methods (Static)
        function this = fread(varargin)
            ip = inputParser;
            addRequired(ip, 'filename', @isfile)
            addOptional(ip, 'size', [], @isnumeric)
            addOptional(ip, 'precision', 'single', @ischar)
            addParameter(ip, 'hdr', [], @isstruct)
            addParameter(ip, 'format', 'luckett', @ischar) 
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            fid = fopen(ipr.filename, 'r');            
            img = single(fread(fid, ipr.precision));
            fclose(fid);
            
            hk = {348; ''; ''; 0; 0; 'r'; 0};
            hkHeadings = {'sizeof_hdr', 'data_type', 'db_name', 'extents', 'session_error', 'regular', 'dim_info'};
            dime = {[3 48 64 48 1 1 1 1]; ...
                     0; 0 ;0; 0; 16; ...
                     32; 0; [1 3 3 3 1 1 1 1]; 352; 0; ...
                     0; 0; 0; 10; 0; ...
                     0; 0; 0; 3649; 0};
            dimeHeadings = {'dim', ...
                            'intent_p1', 'intent_p2', 'intent_p3', 'intent_code', 'datatype', ...
                            'bitpix', 'slice_start', 'pixdim', 'vox_offset', 'scl_slope', ...
                            'scl_inter', 'slice_end', 'slice_code', 'xyzt_units', 'cal_max', ...
                            'cal_min', 'slice_duration', 'toffset', 'glmax', 'glmin'};
            hist = {''; ''; 0; 1; 0; ...
                    0; 0; -71; -95; -71; ...
                    [3 0 0 -71]; [0 3 0 -95]; [0 0 3 -71]; ''; 'n+1'; ...
                    [72 96 72]};
            histHeadings = {'descrip', 'aux_file', 'qform_code', 'sform_code', 'quatern_b', ...
                            'quatern_c', 'quatern_d', 'qoffset_x', 'qoffset_y', 'qoffset_z', ...
                            'srow_x', 'srow_y', 'srow_z', 'intent_name', 'magic', ... 
                            'originator'};
            extra = { ...
                'DT_FLOAT32'; 'NIFTI_INTENT_NONE'; ''; 'NIFTI_XFORM_SCANNER_ANAT'; 'NIFTI_XFORM_UNKNOWN'; ...
                'NIFTI_UNITS_MM'; 'NIFTI_UNITS_SEC'; 'NIFTI_UNITS_UNKNOWN'; 0; 0; ...
                0; 'NIFTI_SLICE_UNKNOWN'; 0; 0; 0};
            extraHeadings = { ...
                'NIFTI_DATATYPES', 'NIFTI_INTENT_CODES', 'NIFTI_INTENT_NAMES', 'NIFTI_SFORM_CODES', 'NIFTI_QFORM_CODES', ...
                'NIFTI_SPACE_UNIT', 'NIFTI_TIME_UNIT', 'NIFTI_SPECTRAL_UNIT', 'NIFTI_FREQ_DIM', 'NIFTI_PHASE_DIM', ...
                'NIFTI_SLICE_DIM', 'NIFTI_SLICE_ORDER', 'NIFTI_VERSION', 'NIFTI_ONEFILE', 'NIFTI_5TH_DIM'};

            switch numel(img)
                case 48*64*48
                    img = reshape(img, [48 64 48]);
                    ipr.hdr = struct( ...
                        'hk', cell2struct(hk, hkHeadings, 1), ...
                        'dime', cell2struct(dime, dimeHeadings, 1), ...
                        'hist', cell2struct(hist, histHeadings, 1), ...
                        'extra', cell2struct(extra, extraHeadings, 1));
                case 128*128*75
                    img = reshape(img, [128 128 75]);
                case 176*208*176
                    img = reshape(img, [176 208 176]);
                case 256*256*256
                    img = reshape(img, [256 256 256]);
                otherwise
            end

            this = mlfourd.ImagingFormatContext(img);
            [p,f] = myfileparts(ipr.filename);
            switch ipr.format
                case 'nifti'
                    ipr.filename = fullfile(p, [f '.nii.gz']);
                case 'fourdfp'
                    ipr.filename = fullfile(p, [f '.4dfp.hdr']);
                case 'luckett'
                    this.img = flip(this.img, 2);
                    ipr.filename = fullfile(p, [f '.4dfp.hdr']);
                case 'mgz'
                    ipr.filename = fullfile(p, [f '.mgz']);
                otherwise
                    error('mlfourd:ValueError', 'ImagingContext2.fread() does not support format %s', ipr.format)
            end
            this.filename = ipr.filename;
            if ~isempty(ipr.hdr)
                this.hdr = ipr.hdr;
            end
        end
        function [tf,e] = supportedFileformExists(fn)
            %% SUPPORTEDFILEFORMEXISTS searches for an existing filename.  If not found it attempts to find 
            %  the same fileprefix with alternative extension for supported image formats:  drawn from
            %  {mlfourd.FourdfpInfo.SUPPORTED_EXT mlfourd.NIfTIInfo.SUPPORTED_EXT mlfourd.MGHInfo.SUPPORTED_EXT},
            %  respecting their enumerated cardinality.
            %  @param fn is the filename queried.
            %  @return tf := filename or fileprefix with support image format found.
            %  @return e  := found image format expressed as file extension.            
            
            % ff exists
            if (lexist(fn, 'file'))
                tf = true;
                [~,~,e] = myfileparts(fn);
                return
            end
            
            % ff doesn't exist as an explicit file; check if there exists a variation of filesuffix           
            [p,f] = myfileparts(fn);
            e3s = mlfourd.FourdfpInfo.SUPPORTED_EXT;
            for ie = 1:length(e3s)
                if (lexist(fullfile(p, [f e3s{ie}]), 'file'))
                    tf = true;
                    e  = e3s{ie};
                    return
                end
            end
            e1s = mlfourd.NIfTIInfo.SUPPORTED_EXT;
            for ie = 1:length(e1s)
                if (lexist(fullfile(p, [f e1s{ie}]), 'file'))
                    tf = true;
                    e  = e1s{ie};
                    return
                end
            end
            e2s = mlfourd.MGHInfo.SUPPORTED_EXT;
            for ie = 1:length(e2s)
                if (lexist(fullfile(p, [f e2s{ie}]), 'file'))
                    tf = true;
                    e  = e2s{ie};
                    return
                end
            end
            
            % ff and variants don't exist at all on the filesystem
            tf = false;         
            [~,~,e] = myfileparts(fn);
        end
        
        %% For use in static workspaces (e.g., while debugging static functions)
        
        function this = static_fsleyes(varargin)
            this = mlfourd.ImagingFormatContext(varargin{:});
            this.fsleyes;
        end
        function this = static_fslview(varargin)
            this = mlfourd.ImagingFormatContext(varargin{:});
            this.fslview;
        end
        function this = static_freeview(varargin)
            this = mlfourd.ImagingFormatContext(varargin{:});
            this.freeview;
        end
    end
    
	methods 
        
        %% SET/GET
        
        function        set.filename(this, fn)
            this.imagingFormatState_.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.imagingFormatState_.filename;
        end
        function        set.filepath(this, pth)
            this.imagingFormatState_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.imagingFormatState_.filepath;
        end
        function        set.fileprefix(this, fp)
            this.imagingFormatState_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.imagingFormatState_.fileprefix;
        end
        function        set.filesuffix(this, fs)
            this.imagingFormatState_.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.imagingFormatState_.filesuffix;
        end        
        function        set.fqfilename(this, fqfn)
            this.imagingFormatState_.fqfilename = fqfn;
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.imagingFormatState_.fqfilename;
        end
        function        set.fqfileprefix(this, fqfp)
            this.imagingFormatState_.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.imagingFormatState_.fqfileprefix;
        end
        function        set.fqfn(this, f)
            this.fqfilename = f;
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function        set.fqfp(this, f)
            this.fqfileprefix = f;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end        
        function        set.noclobber(this, nc)
            this.imagingFormatState_.noclobber = nc;
        end            
        function nc   = get.noclobber(this)
            nc = this.imagingFormatState_.noclobber;
        end    
        
        function e    = get.ext(this)
            e = this.imagingFormatState_.ext;
        end
        function f    = get.filetype(this)
            f = this.imagingFormatState_.filetype;
        end
        function h    = get.hdr(this)
            h = this.imagingFormatState_.hdr;
        end 
        function        set.hdr(this, s)
            assert(isstruct(s))
            this.imagingFormatState_.hdr = s;
        end        
        function im   = get.img(this)
            im = this.imagingFormatState_.img;
        end        
        function        set.img(this, im)
            %% SET.IMG sets new image state. 
            %  @param im is numeric; it updates datatype, bitpix, dim
            
            this.imagingFormatState_.img = im;
        end
        function o    = get.originalType(this)
            o = this.imagingFormatState_.originalType_;
        end
        function u    = get.untouch(this)
            u = this.imagingFormatState_.untouch;
        end
        
        function bp   = get.bitpix(this) 
            %% BIPPIX returns a datatype code as described by the INIfTI specificaitons
            
            bp = this.imagingFormatState_.bitpix;
        end
        function        set.bitpix(this, bp) 
            this.imagingFormatState_.bitpix = bp;
        end
        function cdat = get.creationDate(this)
            cdat = this.imagingFormatState_.creationDate;
        end
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the INIfTI specificaitons
            
            dt = this.imagingFormatState_.datatype;
        end    
        function        set.datatype(this, dt)
            this.imagingFormatState_.datatype = dt;
        end
        function d    = get.descrip(this)
            d = this.imagingFormatState_.descrip;
        end        
        function        set.descrip(this, s)
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            
            this.imagingFormatState_.descrip = s;
        end   
        function E    = get.entropy(this)
            E = this.imagingFormatState_.entropy;
        end
        function x    = get.hdxml(this)
            %% GET.HDXML writes the xml file if this objects exists on disk
            
            x = this.imagingFormatState_.hdxml;
        end 
        function d    = get.label(this)
            d = this.imagingFormatState_.label;
        end     
        function        set.label(this, s)
            this.imagingFormatState_.label = s;
        end
        function ma   = get.machine(this)
            ma = this.imagingFormatState_.machine;
        end
        function mpp  = get.mmppix(this)
            mpp = this.imagingFormatState_.mmppix;
        end        
        function        set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            this.imagingFormatState_.mmppix = mpp;
        end  
        function g    = get.N(this)
            g = this.imagingFormatState_.N;
        end
        function        set.N(this, s)
            assert(islogical(s))
            this.imagingFormatState_.N = s;
        end
        function E    = get.negentropy(this)
            E = this.imagingFormatState_.negentropy;
        end
        function o    = get.orient(this)
            o = this.imagingFormatState_.orient;
        end
        function o    = get.originator(this)
            o = this.imagingFormatState_.originator;
        end        
        function        set.originator(this, o)
            %% SET.ORIGINATOR sets originator position in mm.
            
            this.imagingFormatState_.originator = o;
        end  
        function pd   = get.pixdim(this)
            pd = this.imagingFormatState_.pixdim;
        end        
        function        set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s.
            
            this.imagingFormatState_.pixdim = pd;
        end  
        function num  = get.seriesNumber(this)
            num = this.imagingFormatState_.seriesNumber;
        end
        
        function fs   = get.filesystem(this)
            fs = mlio.HandleFilesystem.createFromString(this.fqfilename);
        end
        function ii   = get.imagingInfo(this)
            ii = this.imagingFormatState_.imagingInfo;
        end        
        function im   = get.logger(this)
            im = this.imagingFormatState_.logger;
        end
        function s    = get.separator(this)
            s = this.imagingFormatState_.separator;
        end
        function        set.separator(this, s)
            this.imagingFormatState_.separator = s;
        end
        function s    = get.stack(this)
            %% GET.STACK
            %  See also:  doc('dbstack')
            
            s = this.imagingFormatState_.stack;
        end
        function g    = get.stateTypeclass(this)
            g = class(this.imagingFormatState_);
        end
        function v    = get.viewer(this)
            v = this.imagingFormatState_.viewer;
        end
        function        set.viewer(this, v)
            this.imagingFormatState_.viewer = v;
        end    
        
        %%
        
        function        addLog(this, varargin)
            this.imagingFormatState_.addLog(varargin{:});
        end
        function c    = char(this, varargin)
            c = this.imagingFormatState_.char(varargin{:});
        end
        function this = append_descrip(this, varargin)
            this.imagingFormatState_ = this.imagingFormatState_.append_descrip(varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.imagingFormatState_ = this.imagingFormatState_.prepend_descrip(varargin{:});
        end
        function d    = double(this)
            d = this.imagingFormatState_.double;
        end
        function d    = duration(this)
            d = this.imagingFormatState_.duration;
        end
        function this = append_fileprefix(this, varargin)
            this.imagingFormatState_ = this.imagingFormatState_.append_fileprefix(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.imagingFormatState_ = this.imagingFormatState_.prepend_fileprefix(varargin{:});
        end
        function this = ensureDouble(this)
            this.imagingFormatState_ = this.imagingFormatState_.ensureDouble;
        end
        function this = ensureSingle(this)
            this.imagingFormatState_ = this.imagingFormatState_.ensureSingle;
        end
        function this = ensureUint8(this)
            this.imagingFormatState_ = this.imagingFormatState_.ensureUint8;
        end
        function this = ensureInt16(this)
            this.imagingFormatState_ = this.imagingFormatState_.ensureInt16;
        end
        function this = ensureInt32(this)
            this.imagingFormatState_ = this.imagingFormatState_.ensureInt32;
        end
        function this = ensureInt64(this)
            this.imagingFormatState_ = this.imagingFormatState_.ensureInt64;
        end
        function        export(this, varargin)
            %% supports .mat with conventions from Patrick Luckett
            %  @param required fqfilename.
            %  @param ndims is numeric.
            
            ip = inputParser;
            addRequired(ip, 'fqfilename', @ischar)
            addParameter(ip, 'ndims', 2, @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            if ~strcmp(this.stateTypeclass, 'mlfourdfp.InnerFourdfp')
                this.img = flip(this.img, 2);
            end
            switch ipr.ndims
                case 2
                    sz = size(this);
                    if length(sz) < 4
                        sz_ = sz;
                        sz = ones(1,4);
                        sz(1:length(sz_)) = sz_;
                    end
                    img = reshape(this.img, [prod(sz(1:3)) sz(4)]); %#ok<PROPLC>
                otherwise
                    error('mlfourd:RuntimeError', 'ImagingFormatContext.export.ipr.ndims->%g', ipr.ndims)
            end
            [~,~,x] = myfileparts(ipr.fqfilename);
            switch x
                case '.mat'
                    save(ipr.fqfilename, 'img');
                    clear('img')
                otherwise
                    error('mlfourd:RuntimeError', 'ImagingFormatContext.export.x->%s', x)
            end
        end
        function f    = fov(this)
            f = this.imagingFormatState_.fov;
        end
        function        freeview(this, varargin)
            this.imagingFormatState_.freeview(varargin{:});
        end
        function e    = fslentropy(this)
            e = this.imagingFormatState_.fslentropy;
        end
        function E    = fslEntropy(this)
            E = this.imagingFormatState_.fslEntropy;
        end
        function        fsleyes(this, varargin)
            this.imagingFormatState_.fsleyes(varargin{:});
        end
        function        fslview(this, varargin)
            this.imagingFormatState_.fslview(varargin{:});
        end
        function        hist(this, varargin)
            this.imagingFormatState_.hist(varargin{:});
        end      
        function tf   = isempty(this)
            tf = false; %%% ~isfile(this.fqfilename) && isempty(this.imagingFormatState_.img);
        end
        function len  = length(this)
            len = length(this.imagingFormatState_.img);
        end
        function tf   = lexist(this)
            tf = this.imagingFormatState_.lexist;
        end
        function d    = logical(this)
            d = this.imagingFormatState_.logical;
        end
        function m    = matrixsize(this)
            m = this.imagingFormatState_.matrixsize;
        end
        function this = mutateInnerImagingFormatByFilesuffix(this)
            this.imagingFormatState_ = this.imagingFormatState_.mutateInnerImagingFormatByFilesuffix;
        end
        function n    = ndims(this, varargin)
            n = this.imagingFormatState_.ndims(varargin{:});
        end
        function n    = numel(this, varargin)
            n = this.imagingFormatState_.numel(varargin{:});
        end
        function this = optimizePrecision(this)
            this.imagingFormatState_ = this.imagingFormatState_.optimizePrecision();
        end
        function this = prod(this, varargin)
            this.imagingFormatState_ = this.imagingFormatState_.prod(varargin{:});
        end
        function this = reset_scl(this)
            this.imagingFormatState_ = this.imagingFormatState_.reset_scl;
        end
        function r    = rank(this, varargin)
            %% DEPRECATED; use ndims
            
            r = this.ndims(varargin{:});
        end
        function this = roi(this, varargin)
            this = this.zoomed(varargin{:});
        end
        function        save(this)
            this.imagingFormatState_.save;
        end
        function this = saveas(this, fqfn)
            this.imagingFormatState_ = this.imagingFormatState_.saveas(fqfn);
        end
        function this = scrubNanInf(this)
            this.imagingFormatState_ = this.imagingFormatState_.scrubNanInf;
        end
        function s    = single(this)
            s = this.imagingFormatState_.single;
        end
        function s    = size(this, varargin)
            s = this.imagingFormatState_.size(varargin{:});
        end
        function c    = string(this, varargin)
            c = this.imagingFormatState_.string(varargin{:});
        end
        function this = sum(this, varargin)
            this.imagingFormatState_ = this.imagingFormatState_.sum(varargin{:});
        end
        function fqfn = tempFqfilename(this)
            fqfn = this.imagingFormatState_.tempFqfilename;
        end
        function        view(this, varargin)
            %% VIEW 
            %  @return if this.img is vector, plot(this.img, varargin{:});
            %          else launch this.viewer with this.img and varargin.
            
            if (this.ndims < 3 && ...
                numel(this.img) == length(this.img))
                plot(this.img, varargin{:});
                return
            end
            this.imagingFormatState_.viewer = this.viewer;
            this.imagingFormatState_.view(varargin{:});
        end
        function this = zoom(this, varargin)
            this = this.zoomed(varargin{:});
        end
        function this = zoomed(this, varargin)
            this.imagingFormatState_ = this.imagingFormatState_.zoomed(varargin{:});
        end
        
 		function this = ImagingFormatContext(varargin)
 			%% IMAGINGFORMATCONTEXT
 			%  @param obj must satisfy this.assertCtorObj; if char it must satisfy this.supportedFileformExists.
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  Valid param-names:  bitpix, datatype, descrip, ext, filename, filepath, fileprefix, filetype, fqfilename, 
            %  fqfileprefix, hdr, img, label, mmppix, noclobber, pixdim, separator.

            import mlfourd.*;            
            this.imagingFormatState_ = ImagingFormatContext.createInner(varargin{:}); 
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional( ip, 'obj',          [], @ImagingFormatContext.assertCtorObj);
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
            addParameter(ip, 'hist', struct([]), @isstruct);
            addParameter(ip, 'img',          [], @(x) isnumeric(x) || islogical(x));
            addParameter(ip, 'label',        '', @ischar);
            addParameter(ip, 'mmppix',       [], @isnumeric);
            addParameter(ip, 'noclobber',    []);
            addParameter(ip, 'originator',   [], @isnumeric);
            addParameter(ip, 'pixdim',       [], @isnumeric);
            addParameter(ip, 'separator',    '', @ischar);
            addParameter(ip, 'circshiftK', 0,    @isnumeric);                                    % see also mlfourd.ImagingInfo
            addParameter(ip, 'N', mlpipeline.ResourcesRegistry.instance().defaultN, @islogical); % 
            parse(ip, varargin{:});
            obj = ip.Results.obj;
            
            this.imagingFormatState_.originalType_ = class(obj);
            if (isa(obj, 'mlfourd.ImagingFormatContext') || ...
                isa(obj, 'mlfourd.AbstractInnerImagingFormat') || ...
                isa(obj, 'mlfourd.ImagingInfo'))
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (ischar(obj)) % && ImagingFormatContext.supportedFileformExists(obj))
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlio.IOInterface'))
                assert(lexist(obj.fqfilename, 'file'), ...
                    'mlfourd:fileNotFound', 'ImagingFormatContext.ctor could not find %s', obj.fqfilename);
                this = ImagingFormatContext(obj.fqfilename);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isstruct(obj))
                %% base case for recursion using Jimmy Shen's mlniftitools
                this = this.adjustInnerNIfTIWithStruct(ip.Results.obj);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (islogical(obj))
                this = this.adjustInnerNIfTIWithLogical(obj);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isnumeric(obj))
                this = this.adjustInnerNIfTIWithNumeric(obj);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlfourd.INIfTI')) 
                %% legacy support
                if (isa(obj, 'mlfourd.INIfTIdecorator'))
                    obj = obj.component;
                end
                warning('off', 'MATLAB:structOnObject');
                this = this.adjustInnerNIfTIWithStruct(struct(obj));
                this = this.adjustFieldsFromInputParser(ip);
                warning('on', 'MATLAB:structOnObject');
                return
            end
            error('mlfourd:unsupportedParamTypeclass', ...
                'class(ImagingFormatContext.ctor..obj) -> %s', class(obj));
 		end
    end 
    
    %% PROTECTED    
    
    properties (Access = protected)
        imagingFormatState_
    end
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.imagingFormatState_ = copy(this.imagingFormatState_);
        end
    end
    
    %% PRIVATE    
    
    methods (Static, Access = private)
        function        assertCtorObj(obj)
            assert( ...
                isempty(obj) || ...
                isa(obj, 'mlfourd.ImagingFormatContext') || ...
                isa(obj, 'mlfourd.AbstractInnerImagingFormat') || ...
                isa(obj, 'mlfourd.ImagingInfo') || ...
                ischar(obj) ||  ...
                isa(obj, 'mlfourd.INIfTI') || ...
                isa(obj, 'mlio.IOInterface') || ...
                isstruct(obj) || ...
                islogical(obj) || ...
                isnumeric(obj), ...
                'mlfourd:invalidCtorParam', ...
                'ImagingFormatContext.assertCtorObj does not support an obj param with typeclass %s', class(obj));
        end
        function inn  = createInner(varargin)
            import mlfourd.* mlfourdfp.*;
            if (isempty(varargin))
                inn = InnerNIfTI(NIfTIInfo); % trivial
                return
            end
            if (1 == length(varargin))
                inn = ImagingFormatContext.createInner1(varargin{:});
                return
            end
            inn = ImagingFormatContext.createInner2(varargin{:});
        end            
        function inn  = createInner1(obj)
            import mlfourd.* mlfourdfp.* mlsurfer.*;     
            if (isa(obj, 'mlfourd.ImagingFormatContext'))
                inn = copy(obj.imagingFormatState_); % copy ctor
                return
            end
            if (isa(obj, 'mlfourd.AbstractInnerImagingFormat'))
                inn = obj;
                return
            end
            if (isa(obj, 'mlfourd.ImagingInfo'))
                obj = obj.fqfilename;
            end
            if (ischar(obj))
                [~,~,e] = myfileparts(obj);            
                switch (e)
                    case FourdfpInfo.SUPPORTED_EXT
                        inn = InnerFourdfp(FourdfpInfo(obj));
                    case NIfTIInfo.SUPPORTED_EXT
                        inn = InnerNIfTI(NIfTIInfo(obj));
                    case mlfourd.MGHInfo.SUPPORTED_EXT 
                        inn = InnerMGH(MGHInfo(obj));
                    case '.hdr'
                        inn = InnerNIfTI(Analyze75Info(obj));
                    otherwise
                        inn = ImagingFormatContext.createInner([myfileprefix(obj) ImagingFormatContext.PREFERRED_EXT]);
                end
                return
            end            
            
            % trivial
            inn = InnerNIfTI(NIfTIInfo);    
        end
        function inn  = createInner2(varargin)
            import mlfourd.* mlfourdfp.* mlsurfer.*;  
            obj = varargin{1};
            v_  = varargin(2:end);
            if (isa(obj, 'mlfourd.ImagingFormatContext'))
                inn = obj.imagingFormatState_; % not copy ctor
                return
            end
            if (isa(obj, 'mlfourd.AbstractInnerImagingFormat'))
                inn = obj;
                return
            end
            if (isa(obj, 'mlfourd.ImagingInfo'))
                obj = obj.fqfilename;
            end
            if (ischar(obj))
                [~,~,e] = myfileparts(obj);            
                switch (e)
                    case FourdfpInfo.SUPPORTED_EXT
                        inn = InnerFourdfp(FourdfpInfo(obj, v_{:}), v_{:});
                    case NIfTIInfo.SUPPORTED_EXT
                        inn = InnerNIfTI(NIfTIInfo(obj, v_{:}), v_{:});
                    case MGHInfo.SUPPORTED_EXT 
                        inn = InnerMGH(MGHInfo(obj, v_{:}), v_{:});
                    case '.hdr'
                        inn = InnerNIfTI(Analyze75Info(obj, v_{:}), v_{:});
                    otherwise
                        inn = ImagingFormatContext.createInner([myfileprefix(obj) ImagingFormatContext.PREFERRED_EXT], v_{:});
                end
                return
            end
            
            % trivial
            inn = InnerNIfTI(NIfTIInfo);            
        end
    end

    methods (Access = private)
        function this = adjustFieldsFromInputParser(this, ip)
            %% ADJUSTFIELDSFROMINPUTPARSER updates this.imagingFormatState_ with ip.Results from ctor.
            
            for p = 1:length(ip.Parameters)
                if (~ismember(ip.Parameters{p}, ip.UsingDefaults))
                    switch (ip.Parameters{p})
                        case 'circshiftK'
                        case 'descrip'
                            this.imagingFormatState_ = this.imagingFormatState_.append_descrip(ip.Results.descrip);
                        case 'hist'
                            this.imagingFormatState_.hdr.hist = ip.Results.hist;
                        case 'N'
                            this.imagingFormatState_.N = ip.Results.N;
                        case 'obj'
                        otherwise % adjust programmatically
                            this.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                    end
                end
            end
        end
        function this = adjustInnerNIfTIWithLogical(this, img)
            ndims_                                                           = ndims(img);
            this.imagingFormatState_.img_                                    = uint8(img);
            this.imagingFormatState_.imagingInfo.hdr.dime.pixdim(2:ndims_+1) = ones(1,ndims_);
            this.imagingFormatState_.imagingInfo.hdr.dime.dim                = ones(1,8);
            this.imagingFormatState_.imagingInfo.hdr.dime.dim(1)             = ndims_;
            this.imagingFormatState_.imagingInfo.hdr.dime.dim(2:ndims_+1)    = size(img);
            this.imagingFormatState_.imagingInfo.hdr.dime.datatype           = 2;
            this.imagingFormatState_.imagingInfo.hdr.dime.bitpix             = 8;
        end
        function this = adjustInnerNIfTIWithNumeric(this, img)
            ndims_                                                           = ndims(img);
            this.imagingFormatState_.img_                                    = img;
            this.imagingFormatState_.imagingInfo.hdr.dime.pixdim(2:ndims_+1) = ones(1,ndims_);
            this.imagingFormatState_.imagingInfo.hdr.dime.dim                = ones(1,8);
            this.imagingFormatState_.imagingInfo.hdr.dime.dim(1)             = ndims_;
            this.imagingFormatState_.imagingInfo.hdr.dime.dim(2:ndims_+1)    = size(img);
            this.imagingFormatState_.imagingInfo.hdr.dime.datatype           = 64;
            this.imagingFormatState_.imagingInfo.hdr.dime.bitpix             = 64;
        end
        function this = adjustInnerNIfTIWithStruct(this, s)
            % as described by mlniftitools.load_untouch_nii
            this.imagingFormatState_.hdr          = s.hdr;
            this.imagingFormatState_.filetype     = s.filetype;
            this.imagingFormatState_.fqfilename   = s.fileprefix; % Jimmy Shen's fileprefix includes filepath, filesuffix
            % this.imagingFormatState_.machine is set at run-time
            if isfield(s, 'ext')
                this.imagingFormatState_.ext      = s.ext;
            end
            this.imagingFormatState_.img_         = s.img;
            if isfield(s, 'untouch')
                this.imagingFormatState_.untouch  = s.untouch;
            end
        end
    end 
    
    %% HIDDEN
    
    methods (Hidden) 
        function g = getInnerImagingFormat(this)
            %% allows ImagingContext2 to import ImagingContext without accessing the filesystem.
            
            g = this.imagingFormatState_;
        end
        function selectFilesystemFormatTool(~)
            %% accomodates ImagingFormatContext2.
        end
        function selectImagingFormatTool(~)
            %% accomodates ImagingFormatContext2.
        end
        function selectFourdfpTool(~)
            %% accomodates ImagingFormatContext2.
        end
        function selectMghTool(~)
            %% accomodates ImagingFormatContext2.
        end
        function selectNiftiTool(~)
            %% accomodates ImagingFormatContext2.
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

