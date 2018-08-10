classdef ImagingInfo < mlio.AbstractIO
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
	%  $Revision$
 	%  was created 27-Jun-2018 00:57:05 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    properties (Dependent)
        qfac % from this.hdr.dime.pixdim(1)
        qform_code
        raw % : [1×1 struct]
        sform_code
                      
        hdr % after Jimmy Shen's niftitools
        ext
        filetype
        machine
        N
        untouch
    end
    
    methods (Static)
        function X = ensureDatatype(X, dt)
            %  @param X is numeric.
            %  @param dt is char for the datatype; cf. compmlete listing in help('mlfourd.ImagingInfo').
            %  @return X cast as dt.
            
            if (isempty(dt))
                return
            end
            switch (dt)
                case {'uchar' 'uint8' 2}
                    if (~isa(X, 'uint8'))
                        X = uint8(X);
                    end
                case {'int16' 4}
                    if (~isa(X, 'int16'))
                        X = int16(X);
                    end
                case {'int32' 8}
                    if (~isa(X, 'int32'))
                        X = int32(X);
                    end
                case {'single' 'float32' 16}
                    if (~isa(X, 'single'))
                        X = single(X);
                    end
                case {'double' 'float64' 64}
                    if (~isa(X, 'double'))
                        X = double(X);
                    end
                case {'uint16' 512}
                    if (~isa(X, 'uint16'))
                        X = uint16(X);
                    end
                case {'uint32' 768}
                    if (~isa(X, 'uint32'))
                        X = uint32(X);
                    end
                case {'int64' 1024}
                    if (~isa(X, 'int64'))
                        X = int64(X);
                    end
                case {'uint64' 1280}
                    if (~isa(X, 'uint64'))
                        X = uint64(X);
                    end
                otherwise
                    error('mlfourd:unsupportSwitchcase', 'ImagingInfo.ensureDatatype.dt');
            end
        end
        function f = tempFqfilename
            f = tempFqfilename('mlfourd_ImagingInfo.4dfp.hdr');
        end
    end
    
	methods 
        
        %% GET, SET 
        
        function g = get.qfac(this)
            g = this.hdr.dime.pixdim(1);
            if (0 == g)
                g = 1;
            end
        end         
        function g = get.qform_code(this)
            g = this.hdr.hist.qform_code;
        end
        function g = get.raw(this)
            g = this.raw_;
        end
        function g = get.sform_code(this)
            g = this.hdr.hist.sform_code;
        end
        
        function g = get.hdr(this)
            g = this.hdr_;
        end
        function this = set.hdr(this, s)
            assert(isstruct(s));
            this.hdr_ = s;
            this.untouch_ = false;
        end
        function g = get.ext(this)
            g = this.ext_;
        end
        function this = set.ext(this, s)
            this.ext_ = s;
            this.untouch_ = false;
        end
        function g = get.filetype(this)
            g = this.filetype_;
        end
        function this = set.filetype(this, s)
            assert(isnumeric(s));
            this.filetype_ = s;
            this.untouch_ = false;
        end
        function g = get.machine(this)
            g = this.machine_;
            if (isempty(g))
                [~,~,m] = computer;
                if (strcmp(m, 'L'))
                    g = 'ieee-le';
                else
                    g = 'ieee-be';
                end
            end
        end
        function g = get.N(this)
            g = this.N_;
        end        
        function this = set.N(this, s)
            assert(islogical(s));
            this.N_ = s;
        end
        function g = get.untouch(this)
            g = this.untouch_;
        end
        function this = set.untouch(this, s)
            this.untouch_ = logical(s);
        end
        
        %%
        
        function hdr  = adjustHdr(this, hdr)
            if (~isempty(this.datatype_))
                hdr.dime.datatype = this.datatype_;
                hdr.dime.bitpix = this.newBitpix;
            end
            hdr = this.permuteHdr(hdr);
            hdr = this.adjustHistOriginator(hdr);
        end 
        function nii = load_nii(this)
            nii = mlniftitools.load_nii(this.fqfilename);
        end
        function [h,e,f,m] = load_untouch_header_only(this)
            % @return h := hdr
            % @return e := ext
            % @return f := filetype
            % @return m := machine, 'ieee-le'|'ieee-be'
            
            [h,e,f,m] = mlniftitools.load_untouch_header_only(this.fqfilename);
        end
        function s = load_untouch_nii(this)
            % @return s := struct of NIfTI data expected by mlniftitools
            
            s = mlniftitools.load_untouch_nii(this.fqfilename);
        end
        
        function this = ImagingInfo(varargin)
 			%% IMAGINGINFO
 			%  @param filename is required.  For aufbau, the file need not exist on the filesystem.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addOptional( ip, 'filename', this.tempFqfilename, @ischar);
            addParameter(ip, 'circshiftK', 0, @isnumeric);
            addParameter(ip, 'datatype', [], @isnumeric); % 16
            addParameter(ip, 'ext', []);
            addParameter(ip, 'filetype', []);
            addParameter(ip, 'N', true, @islogical);
            addParameter(ip, 'untouch', true, @islogical);
            addParameter(ip, 'hdr', this.initialHdr, @isstruct);
            parse(ip, varargin{:});
            this.fqfilename = strrep(ip.Results.filename, '.4dfp.ifh', '.4dfp.hdr');
            this.circshiftK_ = ip.Results.circshiftK;
            this.N_ = ip.Results.N;
            this.datatype_ = ip.Results.datatype;
            this.ext_ = ip.Results.ext;
            this.filetype_ = ip.Results.filetype;            
 			this.untouch_ = ip.Results.untouch;
            
            this.hdr_ = ip.Results.hdr;
 			this.raw_ = this.initialRaw;   
            this.anaraw_ = this.initialAnaraw;            
        end		  
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        anaraw_   
        circshiftK_
        datatype_
        hdr_
        ext_
        filetype_
        machine_
        N_
        raw_
        untouch_
    end
    
    methods (Access = protected) 
        function hdr  = adjustHistOriginator(this, hdr)
            if (~isprop(hdr, 'originator'))
                hdr.hist.originator = double(hdr.dime.pixdim(2:4)) .* double(hdr.dime.dim(2:4)) / 2;
                return
            end
            if (norm(hdr.hist.originator) < eps)
                hdr.hist.originator = double(hdr.dime.pixdim(2:4)) .* double(hdr.dime.dim(2:4)) / 2;
                return
            end
            if (isa(this, 'mlfourdfp.FourdfpInfo') && this.N) % See also:  nifti_4dfp
                hdr.hist.originator = double(hdr.dime.pixdim(2:4)) .* double(hdr.dime.dim(2:4)) / 2;
                return
            end
        end 
        function araw = initialAnaraw(this)
            assert(~isempty(this.hdr_));
            araw = struct( ...
                'ByteOrder', this.machine, ...
                'Extents', nan, ...
                'ImgDataType', '', ...
                'GlobalMax', this.hdr_.dime.glmax, ...
                'GlobalMin', this.hdr_.dime.glmin, ...
                'OMax', 0, ...
                'Omin', 0, ...
                'SMax', 0, ...
                'SMin', 0);            
        end
        function hdr  = initialHdr(this)
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
                'pixdim', [1 1 1 1 1 1 1 1], ... 
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
                'glmax', 0, ... 
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
            hdr = struct('hk', hk, 'dime', dime, 'hist', hist);
        end
        function raw  = initialRaw(this)
            assert(~isempty(this.hdr_));
            raw = struct( ...
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
        function v    = permuteCircshiftVec(this, v)
            if (0 == this.circshiftK_); return; end
            v(1:3) = circshift(v(1:3), this.circshiftK_);
        end
        function X    = permuteCircshiftX(this, X)
            if (0 == this.circshiftK_); return; end
            X = permute(X, circshift([1 2 3], this.circshiftK_));
        end
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function bp   = newBitpix(this)
            assert(~isempty(this.datatype_));
            switch (this.datatype_)
                case {'uchar' 'uint8' 2}
                    bp = 8;
                case {'int16' 4}
                    bp = 16;
                case {'int32' 8}
                    bp = 32;
                case {'single' 'float32' 16}
                    bp = 32;
                case {'double' 'float64' 64}
                    bp = 64;
                case {'uint16' 512}
                    bp = 16;
                case {'uint32' 768}
                    bp = 32;
                case {'int64' 1024}
                    bp = 64;
                case {'uint64' 1280}
                    bp = 64;
                otherwise
                    error('mlfourd:unsupportSwitchcase', 'ImagingInfo.adjustBitpix.this.datatype_');
            end
        end  
        function hdr  = permuteHdr(this, hdr)
            if (0 == this.circshiftK_); return; end
            hdr.dime.dim(2:4)    = this.permuteCircshiftVec(hdr.dime.dim(2:4));
            hdr.dime.pixdim(2:4) = this.permuteCircshiftVec(hdr.dime.pixdim(2:4));
            if (isfield(hdr.hist, 'originator'))
                hdr.hist.originator = this.permuteCircshiftVec(hdr.hist.originator);
            end
        end        
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

