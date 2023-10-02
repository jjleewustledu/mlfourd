classdef ImagingInfo < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlio.IOInterface
	%% IMAGINGINFO manages metadata and header information for imaging.  Internally, it uses NIfTI conventions.
    %  See also https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
    %
    %     DATATYPE                                BITPIX       IMGDATATYPE
    %     --------                                ------       -----------
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
    %
	%  Created 27-Jun-2018 00:57:05 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%  Developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	    
    methods (Static)
        function this = createFromFilename(fn, varargin)
            import mlfourd.*

            [~,~,x] = myfileparts(fn);
            hf = mlio.HandleFilesystem.createFromString(fn);
            switch char(x)
                case '.mat'
                    this = ImagingInfo(hf, varargin{:});
                case {'.nii' '.nii.gz'}
                    this = NIfTIInfo(hf, varargin{:});
                case {'.4dfp.hdr' '.4dfp.img'}
                    this = FourdfpInfo(hf, varargin{:});
                case {'.mgz' '.mgh'}
                    this = MGHInfo(hf, varargin{:});
                otherwise
                    this = ImagingInfo(hf, varargin{:});
            end
        end
        function this = createFromFilesystem(fs, varargin)
            import mlfourd.*

            switch fs.filesuffix
                case '.mat'
                    this = ImagingInfo(fs, varargin{:});
                case {'.nii' '.nii.gz'}
                    this = NIfTIInfo(fs, varargin{:});
                case {'.4dfp.hdr' '.4dfp.img'}
                    this = FourdfpInfo(fs, varargin{:});
                case {'.mgz' '.mgh'}
                    this = MGHInfo(fs, varargin{:});
                otherwise
                    this = ImagingInfo(fs, varargin{:});
            end
        end
        function bp = datatype2bitpix(dt)
            switch dt
                case {'uint8' 'uchar' 2}
                    bp = 8;
                case {'int16' 'short' 4}
                    bp = 16;
                case {'int32' 8}
                    bp = 32;
                case {'single' 'float32' 16}
                    bp = 32;
                case {'complex64' 32}
                    bp = 64;
                case {'double' 'float64' 64}
                    bp = 64;
                case {'int8' 'schar' 256}
                    bp = 8;
                case {'uint16' 'ushort' 512}
                    bp = 16;
                case {'uint32' 768}
                    bp = 32;
                case {'int64' 'long' 1024}
                    bp = 64;
                case {'uint64' 'ulong' 1280}
                    bp = 64;
                case {'complex' 'complex128' 1792}
                    bp = 128;
                otherwise
                    error('mlfourd:ValueError', 'ImagingInfo.datatype2bitpix.this.datatype_->%s', string(dt));
            end
        end 
        function e = defaultFilesuffix()
            e =  mlfourd.NIfTIInfo.FILETYPE_EXT;
        end
        function X = ensureDatatype(X, dt)
            %  @param X is numeric | text.
            %  @param dt is char for the datatype; cf. compmlete listing in help('mlfourd.ImagingInfo').
            %  @return X cast as dt.
            
            if isempty(dt)
                return
            end
            switch (dt)
                case {'uint8' 'uchar' 2}
                    if ~isa(X, 'uint8')
                        X = uint8(X);
                    end
                case {'int16' 'short' 4}
                    if ~isa(X, 'int16')
                        X = int16(X);
                    end
                case {'int32' 8}
                    if ~isa(X, 'int32')
                        X = int32(X);
                    end
                case {'single' 'float32' 16}
                    if ~isa(X, 'single')
                        X = single(X);
                    end
                case {'double' 'float64' 64}
                    if ~isa(X, 'double')
                        X = double(X);
                    end
                case {'int8' 'schar' 256}
                    if ~isa(X, 'int8')
                        X = int8(X);
                    end
                case {'uint16' 'ushort' 512}
                    if ~isa(X, 'uint16')
                        X = uint16(X);
                    end
                case {'uint32' 768}
                    if ~isa(X, 'uint32')
                        X = uint32(X);
                    end
                case {'int64' 'long' 1024}
                    if ~isa(X, 'int64')
                        X = int64(X);
                    end
                case {'uint64' 'ulong' 1280}
                    if ~isa(X, 'uint64')
                        X = uint64(X);
                    end
                case {'complex' 'complex128' 1792}
                    reX = real(X);
                    imX = imag(X);
                    if ~isa(reX, 'double')
                        reX = double(reX);
                    end
                    if ~isa(imX, 'double')
                        imX = double(imX);
                    end
                    X = complex(reX, imX);
                otherwise
                    error('mlfourd:ValueError', 'ImagingInfo.ensureDatatype.dt->%s', dt);
            end
        end
        function dt = img2datatype(img)
            if ~isreal(img)
                dt = 1792;
                return
            end
            switch class(img)
                case 'logical'
                    dt = 2;
                case 'uint8'
                    dt = 2;
                case 'int16'
                    dt = 4;
                case 'int32'
                    dt = 8;
                case 'single'
                    dt = 16;
                case 'double' % includes complex
                    dt = 64;
                case 'int8'
                    dt = 256;
                case 'uint16'
                    dt = 512;
                case 'uint32'
                    dt = 768;
                case 'int64'
                    dt = 1024;
                case 'uint64'
                    dt = 1280;
                otherwise
                    error('mlfourd:ValueError', 'ImagingInfo.img2datatype.this.datatype_->%s', class(img));
            end
        end
        function f = tempFqfilename
            f = tempFqfilename(['mlfourd_ImagingInfo' mlfourd.ImagingInfo.defaultFilesuffix]);
        end
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

        anaraw
        ext
        filesystem % get/set handle, not copy, from external filesystem 
        filetype
        hdr % subset of mlfourd.JimmyShenInterface
        json_metadata
        json_metadata_filesuffix
        machine
        N % keeps track of the option "-N" used by nifti_4dfp
        orient % external representation from fslorient:  RADIOLOGICAL | NEUROLOGICAL
        original
        qfac % internal representation from this.hdr.dime.pixdim(1)
        qform_code
        raw % : [1×1 struct]
        sform_code                      
        untouch
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
        
        function g = get.anaraw(this)
            g = this.anarawLocal();
        end
        function g = get.ext(this)
            g = this.ext_;
        end
        function     set.ext(this, s)
            this.ext_ = s;
            this.untouch_ = [];
        end
        function     set.filesystem(this, s)
            assert(isa(s, 'mlio.HandleFilesystem'))
            this.filesystem_ = s;
        end
        function g = get.filesystem(this)
            g = copy(this.filesystem_);
        end
        function g = get.filetype(this)
            g = this.filetype_;
        end
        function     set.filetype(this, s)
            assert(isnumeric(s));
            this.filetype_ = s;
            this.untouch_ = [];
        end
        function g = get.hdr(this)
            g = this.hdr_;
        end
        function     set.hdr(this, s)
            assert(isstruct(s));
            this.hdr_ = s;
            this.untouch_ = [];
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
        function g = get.N(this)
            g = this.N_;
        end        
        function     set.N(this, s)
            assert(islogical(s));
            this.N_ = s;
        end
        function o = get.orient(this)
            if this.qfac == -1
                o = 'RADIOLOGICAL';
                return
            end
            if this.qfac == 1
                o = 'NEUROLOGICAL';
                return
            end
            o = '';
        end 
        
        function g = get.original(this)
            g = this.original_;
        end
        function g = get.qfac(this)
            g = this.hdr.dime.pixdim(1);
        end         
        function g = get.qform_code(this)
            g = this.hdr.hist.qform_code;
        end        
        function g = get.raw(this)
            assert(~isempty(this.hdr_));
            g = struct( ...
                'sizeof_hdr', this.hdr_.hk.sizeof_hdr, ...
                  'dim_info', this.hdr_.hk.dim_info, ...
                       'dim', this.hdr_.dime.dim, ...
                 'intent_p1', this.hdr_.dime.intent_p1, ...
                 'intent_p2', this.hdr_.dime.intent_p2, ...
                 'intent_p3', this.hdr_.dime.intent_p3, ...
               'intent_code', this.hdr_.dime.intent_code, ...
                  'datatype', this.hdr_.dime.datatype, ...
                    'bitpix', this.hdr_.dime.bitpix, ...
               'slice_start', this.hdr_.dime.slice_start, ...
                    'pixdim', this.hdr_.dime.pixdim, ...
                'vox_offset', this.hdr_.dime.vox_offset, ...
                 'scl_slope', this.hdr_.dime.scl_slope, ...
                 'scl_inter', this.hdr_.dime.scl_inter, ...
                 'slice_end', this.hdr_.dime.slice_end, ...
                'slice_code', this.hdr_.dime.slice_code, ...
                'xyzt_units', this.hdr_.dime.xyzt_units, ...
                   'cal_max', this.hdr_.dime.cal_max, ...
                   'cal_min', this.hdr_.dime.cal_min, ...
            'slice_duration', this.hdr_.dime.slice_duration, ...
                   'toffset', this.hdr_.dime.toffset, ...
                   'descrip', this.hdr_.hist.descrip, ...
                  'aux_file', this.hdr_.hist.aux_file, ...
                'qform_code', this.hdr_.hist.qform_code, ...
                'sform_code', this.hdr_.hist.sform_code, ...
                 'quatern_b', this.hdr_.hist.quatern_b, ...
                 'quatern_c', this.hdr_.hist.quatern_c, ...
                 'quatern_d', this.hdr_.hist.quatern_d, ...
                 'qoffset_x', this.hdr_.hist.qoffset_x, ...
                 'qoffset_y', this.hdr_.hist.qoffset_y, ...
                 'qoffset_z', this.hdr_.hist.qoffset_z, ...
                    'srow_x', this.hdr_.hist.srow_x, ...
                    'srow_y', this.hdr_.hist.srow_y, ...
                    'srow_z', this.hdr_.hist.srow_z, ...
               'intent_name', this.hdr_.hist.intent_name, ...
                     'magic', this.hdr_.hist.magic);             
        end
        function g = get.sform_code(this)
            g = this.hdr.hist.sform_code;
        end        
        function g = get.untouch(this)
            g = this.untouch_;
        end
        function     set.untouch(this, s)
            this.untouch_ = double(s);
        end
        
        %%
        
        function addJsonMetadata(this, varargin)
            for v = asrow(varargin)
                if isstruct(v{1})
                    astruct = v{1};
                    for f = asrow(fields(astruct))
                        afield = f{1};
                        this.json_metadata_.(afield) = astruct.(afield);
                    end
                end
            end
        end
        function hdr = adjustHdr(this, hdr)
            %% adjusts defects in hdr arising from 4dfp or insufficiency of mlniftitools

            % ensures consistency with originator created by nifti_4dfp.            
            if ~isfield(hdr.hist, 'originator') || ...
                norm(hdr.hist.originator) < eps || ...
                (isa(this, 'mlfourd.FourdfpInfo') && this.N)
                xdims_ = min(3, hdr.dime.dim(1)); % space only
                ori_ = double(hdr.dime.pixdim(2:1+xdims_)) .* ...
                       double(hdr.dime.dim(2:1+xdims_) - 1)/2;
                hdr.hist.originator = zeros(1, 3);
                hdr.hist.originator(1:xdims_) = ori_;
            end

            % manage qform_code for scanner and sform_code for atlas
            if hdr.hist.qform_code == 0 && hdr.hist.sform_code == 0
                hdr.hist.sform_code = 1;
            end

            % manage 4dfp problems with
            % srow_x: [0 0 0 0]
            % srow_y: [0 0 0 0]
            % srow_z: [0 0 0 0]
            if all([0 0 0 0] == hdr.hist.srow_x) || ...
               all([0 0 0 0] == hdr.hist.srow_y) || ...
               all([0 0 0 0] == hdr.hist.srow_z)

                hdr.hist.qform_code = 0;
                hdr.hist.sform_code = 1;

                hdr.dime.xyzt_units = 2+8; % mm, sec; see also mlniftitools.extra_nii_hdr

                % for compliance with NIfTI format
                % +x = Right; -y = Posterior; -z = Inferior
                
                                        % a = 0.5  * sqrt(1 + trace(R));
                hdr.hist.quatern_b = 0; % 0.25 * (R(3,2) - R(2,3)) / a;
                hdr.hist.quatern_c = 1; % 0.25 * (R(1,3) - R(3,1)) / a;
                hdr.hist.quatern_d = 0; % 0.25 * (R(2,1) - R(1,2)) / a;
            
                hdr.hist.qoffset_x =  hdr.hist.originator(1);
                hdr.hist.qoffset_y = -hdr.hist.originator(2);
                hdr.hist.qoffset_z = -hdr.hist.originator(3);            

                srow = [[-hdr.dime.pixdim(2) 0 0  hdr.hist.originator(1)]; ...
                        [ 0 hdr.dime.pixdim(3) 0 -hdr.hist.originator(2)]; ...
                        [ 0 0 hdr.dime.pixdim(4) -hdr.hist.originator(3)]];
                hdr.hist.srow_x = srow(1,:);
                hdr.hist.srow_y = srow(2,:);
                hdr.hist.srow_z = srow(3,:);
            end
        end         
        function this = append_descrip(this, varargin) 
            %% APPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with separator_ and appended string.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            if isempty(this.hdr_.hist.descrip)
                this.hdr_.hist.descrip = astring;
            else
                this.hdr_.hist.descrip = sprintf('%s%s %s', this.hdr_.hist.descrip, this.separator_, astring);
            end
        end
        function c = char(this)
            c = char(this.filesystem_);
        end
        
        function nii  = ensureLoadingOrientation(~, nii)
            %% stub for symmetric implemntations with subclasses
            if nii.hdr.hist.sform_code > 0
                S = [nii.hdr.hist.srow_x; nii.hdr.hist.srow_y; nii.hdr.hist.srow_z];
                S = abs(S);
                S = S(:, 1:3);
                assert(trace(S) > sum(S(~eye(3))), ...
                    'ensureLoadingOrientation: S->%s; try using fslreorient2std beforehand', mat2str(S));
            end
        end
        function nii  = ensureSavingOrientation(~, nii)
            %% stub for symmetric implemntations with subclasses
        end
        function tf = isanalyze(this)
            tf =       isfield(this.hdr_.hk,   'hkey_un0');
            tf = tf && isfield(this.hdr_.dime, 'vox_units');
            tf = tf && isfield(this.hdr_.dime, 'cal_units');
            tf = tf && isfield(this.hdr_.dime, 'unused1');
            tf = tf && isfield(this.hdr_.dime, 'dim_un0');
            tf = tf && isfield(this.hdr_.dime, 'roi_scale');
            tf = tf && isfield(this.hdr_.dime, 'funused1');
            tf = tf && isfield(this.hdr_.dime, 'funused2');
            tf = tf && isfield(this.hdr_.dime, 'compressed');
            tf = tf && isfield(this.hdr_.dime, 'verified');
            tf = tf && isfield(this.hdr_.hist, 'orient');
            tf = tf && isfield(this.hdr_.hist, 'generated');
            tf = tf && isfield(this.hdr_.hist, 'scannum');
            tf = tf && isfield(this.hdr_.hist, 'patient_id');
            tf = tf && isfield(this.hdr_.hist, 'exp_date');
            tf = tf && isfield(this.hdr_.hist, 'exp_time');
            tf = tf && isfield(this.hdr_.hist, 'hist_un0');
            tf = tf && isfield(this.hdr_.hist, 'views');
            tf = tf && isfield(this.hdr_.hist, 'vols_added');
            tf = tf && isfield(this.hdr_.hist, 'start_field');
            tf = tf && isfield(this.hdr_.hist, 'field_skip');
            tf = tf && isfield(this.hdr_.hist, 'omax');
            tf = tf && isfield(this.hdr_.hist, 'omin');
            tf = tf && isfield(this.hdr_.hist, 'smax');
            tf = tf && isfield(this.hdr_.hist, 'smin');
        end
        function tf = isnifti(this)
            tf =       isfield(this.hdr_.hk,   'dim_info');
            tf = tf && isfield(this.hdr_.dime, 'intent_p1');
            tf = tf && isfield(this.hdr_.dime, 'intent_p2');
            tf = tf && isfield(this.hdr_.dime, 'intent_p3');
            tf = tf && isfield(this.hdr_.dime, 'intent_code');
            tf = tf && isfield(this.hdr_.dime, 'slice_start');
            tf = tf && isfield(this.hdr_.dime, 'scl_slope');
            tf = tf && isfield(this.hdr_.dime, 'scl_inter');
            tf = tf && isfield(this.hdr_.dime, 'slice_end');
            tf = tf && isfield(this.hdr_.dime, 'slice_code');
            tf = tf && isfield(this.hdr_.dime, 'xyzt_units');
            tf = tf && isfield(this.hdr_.dime, 'slice_duration');
            tf = tf && isfield(this.hdr_.dime, 'toffset');
            tf = tf && isfield(this.hdr_.hist, 'qform_code');
            tf = tf && isfield(this.hdr_.hist, 'sform_code');
            tf = tf && isfield(this.hdr_.hist, 'quatern_b');
            tf = tf && isfield(this.hdr_.hist, 'quatern_c');
            tf = tf && isfield(this.hdr_.hist, 'quatern_d');
            tf = tf && isfield(this.hdr_.hist, 'qoffset_x');
            tf = tf && isfield(this.hdr_.hist, 'qoffset_y');
            tf = tf && isfield(this.hdr_.hist, 'qoffset_z');
            tf = tf && isfield(this.hdr_.hist, 'srow_x');
            tf = tf && isfield(this.hdr_.hist, 'srow_y');
            tf = tf && isfield(this.hdr_.hist, 'srow_z');
            tf = tf && isfield(this.hdr_.hist, 'intent_name');
            tf = tf && isfield(this.hdr_.hist, 'magic');
        end
        function nii = load_nii(this, varargin)
            %  Load NIFTI or ANALYZE dataset. Support both *.nii and *.hdr/*.img
            %  file extension. If file extension is not provided, *.hdr/*.img will
            %  be used as default.
            %
            %  A subset of NIFTI transform is included. For non-orthogonal rotation,
            %  shearing etc., please use 'reslice_nii.m' to reslice the NIFTI file.
            %  It will not cause negative effect, as long as you remember not to do
            %  slice time correction after reslicing the NIFTI file. Output variable
            %  nii will be in RAS orientation, i.e. X axis from Left to Right,
            %  Y axis from Posterior to Anterior, and Z axis from Inferior to
            %  Superior.
            %  
            %  Usage: nii = load_nii(filename, [img_idx], [dim5_idx], [dim6_idx], ...
            %			[dim7_idx], [old_RGB], [tolerance], [preferredForm])
            %  
            %  filename  - 	NIFTI or ANALYZE file name.
            %  
            %  img_idx (optional)  -  a numerical array of 4th dimension indices,
            %	which is the indices of image scan volume. The number of images
            %	scan volumes can be obtained from get_nii_frame.m, or simply
            %	hdr.dime.dim(5). Only the specified volumes will be loaded. 
            %	All available image volumes will be loaded, if it is default or
            %	empty.
            %
            %  dim5_idx (optional)  -  a numerical array of 5th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  dim6_idx (optional)  -  a numerical array of 6th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  dim7_idx (optional)  -  a numerical array of 7th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  old_RGB (optional)  -  a scale number to tell difference of new RGB24
            %	from old RGB24. New RGB24 uses RGB triple sequentially for each
            %	voxel, like [R1 G1 B1 R2 G2 B2 ...]. Analyze 6.0 from AnalyzeDirect
            %	uses old RGB24, in a way like [R1 R2 ... G1 G2 ... B1 B2 ...] for
            %	each slices. If the image that you view is garbled, try to set 
            %	old_RGB variable to 1 and try again, because it could be in
            %	old RGB24. It will be set to 0, if it is default or empty.
            %
            %  tolerance (optional) - distortion allowed in the loaded image for any
            %	non-orthogonal rotation or shearing of NIfTI affine matrix. If 
            %	you set 'tolerance' to 0, it means that you do not allow any 
            %	distortion. If you set 'tolerance' to 1, it means that you do 
            %	not care any distortion. The image will fail to be loaded if it
            %	can not be tolerated. The tolerance will be set to 0.1 (10%), if
            %	it is default or empty.
            %
            %  preferredForm (optional)  -  selects which transformation from voxels
            %	to RAS coordinates; values are s,q,S,Q.  Lower case s,q indicate
            %	"prefer sform or qform, but use others if preferred not present". 
            %	Upper case indicate the program is forced to use the specificied
            %	tranform or fail loading.  'preferredForm' will be 's', if it is
            %	default or empty.	- Jeff Gunter
            %
            %  Returned values:
            %  
            %  nii structure:
            %
            %	hdr -		struct with NIFTI header fields.
            %
            %	filetype -	Analyze format .hdr/.img (0); 
            %			NIFTI .hdr/.img (1);
            %			NIFTI .nii (2)
            %
            %	fileprefix - 	NIFTI filename without extension.
            %
            %	machine - 	machine string variable.
            %
            %	img - 		3D (or 4D) matrix of NIFTI data.
            %
            %	original -	the original header before any affine transform.
            %  
            %  Part of this file is copied and modified from:
            %  http://www.mathworks.com/matlabcentral/fileexchange/1878-mri-analyze-tools
            %  
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %  
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)

            try
                nii = mlfourd.JimmyShen.load_nii(this.fqfilename, varargin{:});
            catch ME
                try
                    if strcmp(ME.identifier, 'mlfourd:JimmyShen:RuntimeError') && ...
                        contains(ME.message, 'Non-orthogonal rotation or shearing found inside the affine matrix')
                        fqfn_ = strcat(tempname, this.filesuffix);
                        mlfourd.JimmyShen.reslice_nii(this.fqfilename, fqfn_);                    
                        nii = mlfourd.JimmyShen.load_nii(fqfn_, varargin{:});
                        deleteExisting(fqfn_)
                        this.fileprefix = strcat(this.fileprefix, '_reslice');
                    end
                catch ME2
                    warning('mlfourd:RuntimeWarning', 'ImagingInfo.load_nii() or JimmyShen.load_nii() failed')
                    handexcept(ME2)
                end
            end
            nii = this.ensureLoadingOrientation(nii);
            nii.img = this.ensureDatatype(nii.img, this.datatype_);
            nii.hdr = mlniftitools.extra_nii_hdr(nii.hdr);
            nii.hdr = this.adjustHdr(nii.hdr);
            this.hdr_ = nii.hdr;
            this.filetype_ = nii.filetype;
            this.machine_ = nii.machine;
            this.original_ = nii.original;
            this.hdr.extra = nii.hdr.extra;
            this.ext_ = [];
            this.untouch_ = [];
            try
                x = this.json_metadata_filesuffix;
                this.json_metadata_ = jsondecodefile(strcat(this.fqfileprefix, x));
            catch %#ok<CTCH> 
            end
        end        
        function [h,e,f,m] = load_untouch_header_only(this)
            %  Load NIfTI / Analyze header without applying any appropriate affine
            %  geometric transform or voxel intensity scaling. It is equivalent to
            %  hdr field when using load_untouch_nii to load dataset. Support both
            %  *.nii and *.hdr file extension. If file extension is not provided,
            %  *.hdr will be used as default.
            %  
            %  Usage: [header, ext, filetype, machine] = load_untouch_header_only(filename)
            %  
            %  filename - NIfTI / Analyze file name.
            %  
            %  Returned values:
            %  
            %  header - struct with NIfTI / Analyze header fields.
            %  
            %  ext - NIfTI extension if it is not empty.
            %  
            %  filetype	- 0 for Analyze format (*.hdr/*.img);
            %		  1 for NIFTI format in 2 files (*.hdr/*.img);
            %		  2 for NIFTI format in 1 file (*.nii).
            %  
            %  machine    - a string, see below for details. The default here is 'ieee-le'.
            %
            %    'native'      or 'n' - local machine format - the default
            %    'ieee-le'     or 'l' - IEEE floating point with little-endian
            %                           byte ordering
            %    'ieee-be'     or 'b' - IEEE floating point with big-endian
            %                           byte ordering
            %    'vaxd'        or 'd' - VAX D floating point and VAX ordering
            %    'vaxg'        or 'g' - VAX G floating point and VAX ordering
            %    'cray'        or 'c' - Cray floating point with big-endian
            %                           byte ordering
            %    'ieee-le.l64' or 'a' - IEEE floating point with little-endian
            %                           byte ordering and 64 bit long data type
            %    'ieee-be.l64' or 's' - IEEE floating point with big-endian byte
            %                           ordering and 64 bit long data type.
            %
            %  Part of this file is copied and modified from:
            %  http://www.mathworks.com/matlabcentral/fileexchange/1878-mri-analyze-tools
            %
            %  NIFTI data format can be found on: http://nifti.nimh.nih.gov
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %            
            %  @return h := hdr
            %  @return e := ext
            %  @return f := filetype
            %  @return m := machine, 'ieee-le'|'ieee-be'
            
            [h,e,f,m] = mlniftitools.load_untouch_header_only(this.fqfilename);
            h = this.adjustHdr(h);
            this.filetype_ = f;
            this.machine_ = m;
            this.ext_ = e;
            this.untouch_ = 1;
            try
                x = this.json_metadata_filesuffix;
                this.json_metadata_ = jsondecodefile(strcat(this.fqfileprefix, x));
            catch %#ok<CTCH>
            end
        end
        function nii = load_untouch_nii(this, varargin)
            %  Load NIFTI or ANALYZE dataset, but not applying any appropriate affine
            %  geometric transform or voxel intensity scaling.
            %
            %  Although according to NIFTI website, all those header information are
            %  supposed to be applied to the loaded NIFTI image, there are some
            %  situations that people do want to leave the original NIFTI header and
            %  data untouched. They will probably just use MATLAB to do certain image
            %  processing regardless of image orientation, and to save data back with
            %  the same NIfTI header.
            %
            %  Since this program is only served for those situations, please use it
            %  together with "save_untouch_nii.m", and do not use "save_nii.m" or
            %  "view_nii.m" for the data that is loaded by "load_untouch_nii.m". For
            %  normal situation, you should use "load_nii.m" instead.
            %  
            %  Usage: nii = load_untouch_nii(filename, [img_idx], [dim5_idx], [dim6_idx], ...
            %			[dim7_idx], [old_RGB], [slice_idx])
            %  
            %  filename  - 	NIFTI or ANALYZE file name.
            %  
            %  img_idx (optional)  -  a numerical array of image volume indices.
            %	Only the specified volumes will be loaded. All available image
            %	volumes will be loaded, if it is default or empty.
            %
            %	The number of images scans can be obtained from get_nii_frame.m,
            %	or simply: hdr.dime.dim(5).
            %
            %  dim5_idx (optional)  -  a numerical array of 5th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  dim6_idx (optional)  -  a numerical array of 6th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  dim7_idx (optional)  -  a numerical array of 7th dimension indices.
            %	Only the specified range will be loaded. All available range
            %	will be loaded, if it is default or empty.
            %
            %  old_RGB (optional)  -  a scale number to tell difference of new RGB24
            %	from old RGB24. New RGB24 uses RGB triple sequentially for each
            %	voxel, like [R1 G1 B1 R2 G2 B2 ...]. Analyze 6.0 from AnalyzeDirect
            %	uses old RGB24, in a way like [R1 R2 ... G1 G2 ... B1 B2 ...] for
            %	each slices. If the image that you view is garbled, try to set 
            %	old_RGB variable to 1 and try again, because it could be in
            %	old RGB24. It will be set to 0, if it is default or empty.
            %
            %  slice_idx (optional)  -  a numerical array of image slice indices.
            %	Only the specified slices will be loaded. All available image
            %	slices will be loaded, if it is default or empty.
            %
            %  Returned values:
            %  
            %  nii structure:
            %
            %	hdr -		struct with NIFTI header fields.
            %
            %	filetype -	Analyze format .hdr/.img (0); 
            %			NIFTI .hdr/.img (1);
            %			NIFTI .nii (2)
            %
            %	fileprefix - 	NIFTI filename without extension.
            %
            %	machine - 	machine string variable.
            %
            %	img - 		3D (or 4D) matrix of NIFTI data.
            %
            %  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
            %            
            % @return s := struct of NIfTI data expected by mlniftitools
            
            nii = mlniftitools.load_untouch_nii(this.fqfilename, varargin{:});
            nii = this.ensureLoadingOrientation(nii);
            nii.img = this.ensureDatatype(nii.img, this.datatype_);
            nii.hdr = this.adjustHdr(nii.hdr);
            this.hdr_ = nii.hdr;
            this.filetype_ = nii.filetype;
            this.machine_ = nii.machine;
            this.original_ = [];
            this.ext_ = nii.ext;
            this.untouch_ = nii.untouch;
            try
                x = this.json_metadata_filesuffix;
                this.json_metadata_ = jsondecodefile(strcat(this.fqfileprefix, x));
            catch %#ok<CTCH>
            end
        end  
        function this = prepend_descrip(this, varargin) 
            %% PREPEND_DESCRIP
            %  @param [varargin] may be a single string or args to sprintf.
            %  @return this updates descrip with prepended string and separator_.
            %  @throws MATLAB:printf:invalidInputType
            
            if (nargin > 2)
                astring = sprintf(varargin{:});
            else
                astring = varargin{:};
            end
            if isempty(this.hdr_.hist.descrip)
                this.hdr_.hist.descrip = astring;
            else
                this.hdr_.hist.descrip = sprintf('%s%s %s', astring, this.separator_, this.hdr_.hist.descrip);
            end
        end  
        function this = reset_scl(this)
            this.hdr_.dime.scl_slope = 1;
            this.hdr_.dime.scl_inter = 0;
        end
        function s = string(this, varargin)
            s = string(this.filesystem_, varargin{:});
        end
        function this = zoomed(this, rmin, rsize)
            shift = this.AffMats*[rmin(1:3) 0]';
            
            this.hdr.hist.srow_x(4) = this.hdr.hist.srow_x(4) + shift(1);
            this.hdr.hist.srow_y(4) = this.hdr.hist.srow_y(4) + shift(2);
            this.hdr.hist.srow_z(4) = this.hdr.hist.srow_z(4) + shift(3);
            this.hdr.hist.originator(1:3) = this.hdr.hist.originator(1:3) - rmin(1:3);
            this.hdr.hist.originator(1) = this.hdr.hist.originator(1) - 72; %% KLUDGE

            this.hdr.dime.dim(2:4) = rsize;
        end 
        function xyz = AffineMethod3(this, ijk)
            % AFFINEMETHOD3 (used when sform_code > 0):
            % -----------------------------------------
            % The (x,y,z) coordinates are given by a general affine transformation
            % of the (i,j,k) indexes:
            % 
            %   x = srow_x[0] * i + srow_x[1] * j + srow_x[2] * k + srow_x[3]
            %   y = srow_y[0] * i + srow_y[1] * j + srow_y[2] * k + srow_y[3]
            %   z = srow_z[0] * i + srow_z[1] * j + srow_z[2] * k + srow_z[3]
            % 
            % The srow_* vectors are in the NIFTI_1 header.  Note that no use is
            % made of pixdim[] in this method.
            %
            %    See also https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
            %
            %    @param  ijk := voxel indices
            %    @return xyz := Cartesian position
            
            assert(this.sform_code > 0, ...
                'mlfourd:unexpectedInternalParam', 'AbstractNIfTIInfo.RMatrixMethod3.sform_code->%i', this.sform_code);
            
            xyz = this.AffMats * [ensureColVector(ijk); 1];
        end
        function A = AffMats(this)
            A      = zeros(3, 4);
            A(1,:) = this.hdr.hist.srow_x;
            A(2,:) = this.hdr.hist.srow_y;
            A(3,:) = this.hdr.hist.srow_z;
        end
        function R = RMatq(this)
            a = 0;
            b = this.hdr.hist.quatern_b;
            c = this.hdr.hist.quatern_c;
            d = this.hdr.hist.quatern_d;
            R = [ (2*a^2 - 1 + 2*b^2) (2*b*c - 2*d*a)     (2*b*d + 2*c*a); ...
                  (2*b*c + 2*d*a)     (2*a^2 - 1 + 2*c^2) (2*c*d - 2*b*a); ...
                  (2*b*d - 2*c*a)     (2*c*d + 2*b*a)     (2*a^2 - 1 + 2*d^2) ];
        end
        function xyz = RMatrixMethod2(this, ijk)
            %%   RMATRIXMETHOD2 (used when qform_code > 0, which should be the "normal" case):
            %    -----------------------------------------------------------------------------
            %    The (x,y,z) coordinates are given by the pixdim[] scales, a rotation
            %    matrix, and a shift.  This method is intended to represent
            %    "scanner-anatomical" coordinates, which are often embedded in the
            %    image header (e.g., DICOM fields (0020,0032), (0020,0037), (0028,0030),
            %    and (0018,0050)), and represent the nominal orientation and location of
            %    the data.  This method can also be used to represent "aligned"
            %    coordinates, which would typically result from some post-acquisition
            %    alignment of the volume to a standard orientation (e.g., the same
            %    subject on another day, or a rigid rotation to true anatomical
            %    orientation from the tilted position of the subject in the scanner).
            %    The formula for (x,y,z) in terms of header parameters and (i,j,k) is:
            % 
            %      [ x ]   [ R11 R12 R13 ] [       pixdim[1] * i ]   [ qoffset_x ]
            %      [ y ] = [ R21 R22 R23 ] [       pixdim[2]   j ] + [ qoffset_y ]
            %      [ z ]   [ R31 R32 R33 ] [ qfac  pixdim[3] * k ]   [ qoffset_z ]            
            % 
            %    The qoffset_* shifts are in the NIFTI-1 header.  Note that the center
            %    of the (i,j,k)=(0,0,0) voxel (first value in the dataset array) is
            %    just (x,y,z)=(qoffset_x,qoffset_y,qoffset_z).
            % 
            %    The rotation matrix R is calculated from the quatern_* parameters.
            %    This calculation is described below.
            % 
            %    The scaling factor qfac is either 1 or -1.  The rotation matrix R
            %    defined by the quaternion parameters is "proper" (has determinant 1).
            %    This may not fit the needs of the data; for example, if the image
            %    grid is
            %      i increases from Left-to-Right
            %      j increases from Anterior-to-Posterior
            %      k increases from Inferior-to-Superior
            %    Then (i,j,k) is a left-handed triple.  In this example, if qfac=1,
            %    the R matrix would have to be
            % 
            %      [  1   0   0 ]
            %      [  0  -1   0 ]  which is "improper" (determinant = -1).
            %      [  0   0   1 ]
            % 
            %    <b>If we set qfac=-1, then the R matrix would be<\b>
            % 
            %      [  1   0   0 ]
            %      [  0  -1   0 ]  which is proper.
            %      [  0   0  -1 ]
            % 
            %    This R matrix is represented by quaternion [a,b,c,d] = [0,1,0,0]
            %    (which encodes a 180 degree rotation about the x-axis).    
            %
            %    See also https://nifti.nimh.nih.gov/nifti-1/documentation/nifti1fields/nifti1fields_pages/qsform.html
            %
            %    @param  ijk := voxel indices
            %    @return xyz := Cartesian position
            
            assert(this.qform_code > 0, ...
                'mlfourd:unexpectedInternalParam', 'AbstractNIfTIInfo.RMatrixMethod3.qform_code->%i', this.qform_code);
            assert(abs(this.qfac) == 1, ...
                'mlfourd:unexpectedInternalParam', 'AbstractNIfTIInfo.RMatrixMethod3.qfac->%i', this.qfac);
            
            i   = ijk(1);
            j   = ijk(2);
            k   = ijk(3);
            d   = this.hdr.dime;
            h   = this.hdr.hist;
            xyz = this.RMatq * [d.pixdim(2)*i d.pixdim(3)*j d.pixdim(4)*k*this.qfac]' + ...
                               [h.qoffset_x   h.qoffset_y   h.qoffset_z  ]';
            
        end

        function this = ImagingInfo(varargin)
 			%% IMAGINGINFO provides points of entry for building info and hdr objects
            %  Args:
 			%      filesystem_ (text|mlio.HandleFilesystem):  
            %          If text, ImagingInfo creates isolated filesystem_ information.
            %          If mlio.HandleFilesystem, ImagingInfo will reference the handle for filesystem_ information,
            %          allowing for external modification for synchronization.
            %          For aufbau, the file need not exist on the filesystem.
            %      datatype (scalar): sepcified by mlniftitools.
            %      ext (struct): sepcified by mlniftitools.
            %      filetype (scalar): sepcified by mlniftitools.
            %      N (logical): 
            %      separator (text): separates annotations
            %      untouch (logical): sepcified by mlniftitools.
            %      hdr (struct): sepcified by mlniftitools.
            %      original (struct): specified by mlniftitools.
            %      json_metadata (struct): read from filesystem by ImagingInfo hierarchy.
            %      json_metadata_filesuffix (text): for reading from filesystem by ImagingInfo hierarchy.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            rregistry = mlpipeline.ResourcesRegistry.instance();
            addOptional( ip, 'filesystem', mlio.HandleFilesystem(), @(x) istext(x) || isa(x, 'mlio.HandleFilesystem'));
            addParameter(ip, 'datatype', [], @isscalar); % 16
            addParameter(ip, 'ext', []);
            addParameter(ip, 'filetype', []);
            addParameter(ip, 'N', rregistry.defaultN, @islogical);
            addParameter(ip, 'separator', ';', @istext)
            addParameter(ip, 'untouch', [], @isnumeric);
            addParameter(ip, 'hdr', this.initialHdr, @isstruct);
            addParameter(ip, 'original', []);
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
            this = this.adjustFilesuffix4dfp;
            this.datatype_ = ipr.datatype;
            this.ext_ = ipr.ext;
            this.filetype_ = ipr.filetype;   
            this.N_ = ipr.N;   
            this.separator_ = ipr.separator;      
 			this.untouch_ = ipr.untouch;            
            this.hdr_ = ipr.hdr;
            this.original_ = ipr.original;
            this.json_metadata_filesuffix_ = ipr.json_metadata_filesuffix;
            this.json_metadata_ = ipr.json_metadata;
            if isempty(this.json_metadata_)
                try
                    this.json_metadata_ = jsondecodefile( ...
                        strcat(this.fqfileprefix, this.json_metadata_filesuffix_));
                catch %#ok<CTCH>
                end
            end
        end		  
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        datatype_
        ext_
        filesystem_
        filetype_
        hdr_
        json_metadata_
        json_metadata_filesuffix_
        machine_
        N_
        original_
        separator_
        untouch_
    end
    
    methods (Access = protected) 
        function a = anarawLocal(this)
            assert(~isempty(this.hdr_));
            a = struct( ...
                'ByteOrder', this.machine, ...
                'Extents', this.hdr_.hk.extents, ...
                'ImgDataType', this.hdr_.hk.data_type, ...
                'GlobalMax', this.hdr_.dime.glmax, ...
                'GlobalMin', this.hdr_.dime.glmin, ...
                'OMax', 0, ...
                'Omin', 0, ...
                'SMax', 0, ...
                'SMin', 0); 
        end
        function that = copyElement(this)
            that = copyElement@matlab.mixin.Copyable(this);
            that.filesystem_ = copy(this.filesystem_);
        end
        function hdr = initialHdr(~)
            hk   = struct( ...
                'sizeof_hdr', 348, ...
                'data_type', '', ...
                'db_name', '', ...
                'extents', 0, ...
                'session_error', 0, ...
                'regular', 'r', ...
                'dim_info', 0);
            dime = struct( ...
                'dim', [2 1 1 1 1 1 1 1], ...
                'intent_p1', 0, ... 
                'intent_p2', 0, ... 
                'intent_p3', 0, ... 
                'intent_code', 0, ... 
                'datatype', 64, ... 
                'bitpix', 64, ... 
                'slice_start', 0, ... 
                'pixdim', [-1 1 1 1 1 1 1 1], ... 
                'vox_offset', 352, ... 
                'scl_slope', 0, ... 
                'scl_inter', 0, ... 
                'slice_end', 0, ... 
                'slice_code', 0, ... 
                'xyzt_units', 10, ... 
                'cal_max', 0, ... 
                'cal_min', 0, ... 
                'slice_duration', 0, ... 
                'toffset', 0, ... 
                'glmax', 0, ... 
                'glmin', 0);
            hist = struct( ...
                'descrip', 'ImagingInfo.initialHdr', ...
                'aux_file', '', ...
                'qform_code', 0, ...
                'sform_code', 0, ...
                'quatern_b', 0, ...
                'quatern_c', 0, ...
                'quatern_d', 0, ...
                'qoffset_x', 0, ...
                'qoffset_y', 0, ...
                'qoffset_z', 0, ...
                'srow_x', [0 0 0 0], ...
                'srow_y', [0 0 0 0], ...
                'srow_z', [0 0 0 0], ...
                'intent_name', '', ...
                'magic', 'n+1');
            hdr = struct('hk', hk, 'dime', dime, 'hist', hist);
        end
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function this = adjustFilesuffix4dfp(this)
            if contains(this.filesuffix, '.4dfp')
                this.filesuffix = '.4dfp.hdr';
            end
        end   
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

