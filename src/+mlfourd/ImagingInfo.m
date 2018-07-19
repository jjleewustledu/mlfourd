classdef ImagingInfo < mlio.AbstractIO
	%% IMAGINGINFO 
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
        raw % : [1×1 struct]
                      
        hdr % after Jimmy Shen's niftitools
        ext
        filetype
        machine
        N
        untouch
    end
    
    methods (Static)
        function X = ensureDatatype(X, dt)
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
    end
    
	methods 
        
        %% GET, SET 
        
        function g = get.raw(this)
            g = this.raw_;
        end        
        function g = get.hdr(this)
            g = this.hdr_;
        end
        function g = get.ext(this)
            g = this.ext_;
        end
        function g = get.filetype(this)
            g = this.filetype_;
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
        
        %%
        
        function this = ImagingInfo(varargin)
 			%% IMAGINGINFO
 			%  @param filename is required.
            
            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, 'filename', @ischar);
            addParameter(ip, 'circshiftK', 0, @isnumeric);
            addParameter(ip, 'N', true, @islogical);
            addParameter(ip, 'datatype', 16, @isnumeric);
            parse(ip, varargin{:});
            this.fqfilename = ip.Results.filename;
            this.circshiftK_ = ip.Results.circshiftK;
            this.N_ = ip.Results.N;
            this.datatype_ = ip.Results.datatype;
 			this.raw_ = this.initialRaw;
            this.anaraw_ = this.initialAnaraw;                 
        end		  
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        anaraw_   
        bitpix_
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
        function hdr  = adjustHdr(this, hdr)
            if (~isempty(this.datatype_))
                hdr.dime.datatype = this.datatype_;
                hdr.dime.bitpix = this.newBitpix;
            end
            hdr = this.permuteHdr(hdr);
            hdr = this.adjustHistOriginator(hdr);
        end  
        function v    = permuteVec1to3(this, v)
            if (0 == this.circshiftK_); return; end
            v(1:3) = circshift(v(1:3), this.circshiftK_);
        end
        function X    = permuteX(this, X)
            if (0 == this.circshiftK_); return; end
            X = permute(X, circshift([1 2 3], this.circshiftK_));
        end
    end
    
    methods (Access = private)
        function hdr  = adjustHistOriginator(this, hdr)
            if (this.N) % See also:  nifti_4dfp
                hdr.hist.originator = double(hdr.dime.pixdim(2:4)) .* double(hdr.dime.dim(2:4)) / 2;
            end
        end 
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
            hdr.dime.dim(2:4)    = this.permuteVec1to3(hdr.dime.dim(2:4));
            hdr.dime.pixdim(2:4) = this.permuteVec1to3(hdr.dime.pixdim(2:4));
            if (isfield(hdr.hist, 'originator'))
                hdr.hist.originator = this.permuteVec1to3(hdr.hist.originator);
            end
        end
        function raw  = initialAnaraw(~)
            raw = struct( ...
                'ByteOrder', 'ieee-le', ...
                'Extents', nan, ...
                'ImgDataType', '', ...
                'GlobalMax', 0, ...
                'GlobalMin', 0, ...
                'OMax', 0, ...
                'Omin', 0, ...
                'SMax', 0, ...
                'SMin', 0);            
        end
        function raw  = initialRaw(~)
            raw = struct( ...
                'sizeof_hdr', 348, ...
                  'dim_info', ' ', ...
                       'dim', [2 1 1 1 1 1 1 1], ...
                 'intent_p1', 0, ...
                 'intent_p2', 0, ...
                 'intent_p3', 0, ...
               'intent_code', 0, ...
                  'datatype', 2, ...
                    'bitpix', 8, ...
               'slice_start', 0, ...
                    'pixdim', [1 1 1 1 1 1 1 1], ...
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
                   'descrip', '', ...
                  'aux_file', '', ...
                'qform_code', 1, ...
                'sform_code', 1, ...
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
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

