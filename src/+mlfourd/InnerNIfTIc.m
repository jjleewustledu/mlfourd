classdef InnerNIfTIc < mlfourd.NIfTIcIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI & mlpatterns.Composite
	%% INNERNIFTIC  

	%  $Revision$
 	%  was created 15-Jan-2016 03:04:23
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    properties (Dependent)
        
        %% Instantiation of mlfourd.JimmyShenInterface to support struct arguments to NIfTId ctor
        
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
        
        %% Instantiation of mlfourd.INIfTI
        
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
        
        %% New for mlfourd.InnerNIfTIc
        
        separator % for descrip & label properties, not for filesystem behaviors
        stack
    end 

    methods %% GET/SET
        
        %% JimmyShenInterface
        
        function g    = get.ext(this)
            g = this.innerCellComp_.getter('ext');
        end
        function g    = get.filetype(this)
            g = this.innerCellComp_.getter('filetype');
        end
        function this = set.filetype(this, s)
            this = this.innerCellComp_.setter('filetype', s);
        end
        function g    = get.hdr(this)
            g = this.innerCellComp_.getter('hdr');
        end
        function g    = get.img(this)
            g = this.innerCellComp_.getter('img');
        end
        function this = set.img(this, s)
            this = this.innerCellComp_.setter('img', s);
        end
        function g    = get.originalType(this)
            g = this.innerCellComp_.getter('originalType');
        end
        function g    = get.untouch(this)
            g = this.innerCellComp_.getter('untouch');
        end
        
        %% INIfTI  
        
        function g    = get.bitpix(this)
            g = this.innerCellComp_.getter('bitpix');
        end
        function this = set.bitpix(this, s)
            this = this.innerCellComp_.setter('bitpix', s);
        end
        function g    = get.creationDate(this)
            g = this.innerCellComp_.getter('creationDate');
        end
        function g    = get.datatype(this)
            g = this.innerCellComp_.getter('datatype');
        end
        function this = set.datatype(this, s)
            this = this.innerCellComp_.setter('datatype', s);
        end
        function g    = get.descrip(this)
            g = this.innerCellComp_.getter('descrip');
        end
        function this = set.descrip(this, s)
            this = this.innerCellComp_.setter('descrip', s);
        end
        function g    = get.entropy(this)
            g = this.innerCellComp_.getter('entropy');
        end
        function g    = get.hdxml(this)
            g = this.innerCellComp_.getter('hdxml');
        end
        function g    = get.label(this)
            g = this.innerCellComp_.getter('label');
        end
        function this = set.label(this, s)
            this = this.innerCellComp_.setter('label', s);
        end
        function g    = get.machine(this)
            g = this.innerCellComp_.getter('machine');
        end
        function g    = get.mmppix(this)
            g = this.innerCellComp_.getter('mmppix');
        end
        function this = set.mmppix(this, s)
            this = this.innerCellComp_.setter('mmppix', s);
        end
        function g    = get.negentropy(this)
            g = this.innerCellComp_.getter('negentropy');
        end
        function g    = get.orient(this)
            g = this.innerCellComp_.getter('orient');
        end
        function g    = get.pixdim(this)
            g = this.innerCellComp_.getter('pixdim');
        end
        function this = set.pixdim(this, s)
            this = this.innerCellComp_.setter('pixdim', s);
        end
        function g    = get.seriesNumber(this)
            g = this.innerCellComp_.getter('seriesNumber');
        end
        
        %% New for AbstractNIfTId
        
        function g    = get.separator(this)
            g = this.innerCellComp_.getter('separator');
        end
        function this = set.separator(this, s)
            this = this.innerCellComp_.setter('separator', s);
        end
        function g    = get.stack(this)
            g = this.innerCellComp_.getter('stack');
        end
    end
    
	methods        
        
        %% NIfTIIO
        
        function save(this)
            this.fevalNone('save');
        end
        function this = saveas(this, fn)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('saveas', fn);
        end
    
        
        %% INIfTI  
        
        function c = char(this)
            c = this.innerCellComp_.fevalOut('char');
        end
        function this = append_descrip(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('append_descrip', varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('prepend_descrip', varargin{:});
        end
        function d = double(this)
            d = this.innerCellComp_.fevalOut('double');
        end
        function d = duration(this)
            d = this.innerCellComp_.fevalOut('duration');
        end
        function this = append_fileprefix(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('append_fileprefix', varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('prepend_fileprefix', varargin{:});
        end
        function f = fov(this)
            f = this.innerCellComp_.fevalOut('fov');
        end
        function [tf,msg] = isequal(this, obj)
            [tf,msg] = this.innerCellComp_.isequal(obj);
        end
        function m = matrixsize(this)
            m = this.innerCellComp_.fevalOut('matrixsize');
        end
        function o = ones(this)
            o = this.innerCellComp_.fevalOut('ones');
        end
        function r = rank(this)
            r = this.innerCellComp_.fevalOut('rank');
        end
        function this = scrubNanInf(this)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('scrubNanInf');
        end
        function s = single(this)
            s = this.innerCellComp_.fevalOut('single');
        end
        function s = size(this, varargin)
            s = this.innerCellComp_.fevalOut('size', varargin{:});
        end
        function z = zeros(this)
            z = this.innerCellComp_.fevalOut('zeros');
        end
        
        %% New for InnerNIfTIc
        
        function e = fslentropy(this)
            e = this.innerCellComp_.fevalOut('fslentropy');
        end
        function E = fslEntropy(this)
            E = this.innerCellComp_.fevalOut('fslEntropy');
        end
        function freeview(this, varargin)
            first = this.innerCellComp_.get(1);
            fqfns = this.innerCellComp_.fevalOut('fqfilename');
            fqfns = [fqfns{2:end} varargin{:}];
            first.freeview(fqfns{:});
        end
        function fslview(this, varargin)
            first = this.innerCellComp_.get(1);
            fqfns = this.innerCellComp_.fevalOut('fqfilename');
            fqfns = [fqfns{2:end} varargin{:}];
            first.fslview(fqfns{:});
        end
        
        %% mlpatterns.Composite
        
        function this = add(this, obj)
            this.innerCellComp_ = this.innerCellComp_.fevalThis('add', obj);
        end        
        function iter = createIterator(this)
            iter = this.innerCellComp_.fevalOut('createIterator');
        end
        function        disp(this)
            this.innerCellComp_.fevalNone('disp');
        end
        function idx  = find(this, obj)
            idx = this.innerCellComp_.fevalOut('find', obj);
        end
        function obj  = get(this, idx)
            obj = this.innerCellComp_.fevalOut('get', idx);
        end
        function tf   = isempty(this)
            tf = this.innerCellComp_.fevalOut('isempty');
        end
        function len  = length(this)
            len = this.innerCellComp_.fevalOut('length');
        end
        function        rm(this, idx)
            this.innerCellComp_.fevalNone('rm', idx);
        end
        function s    = csize(this)   
            s = this.innerCellComp_.fevalOut('csize');
        end     
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        innerCellComp_ 
    end
    
    methods (Access = protected)
 		function this = InnerNIfTIc(varargin)            
            if (nargin == 1 && isa(varargin{1}, 'mlfourd.InnerNIfTIc'))
                this.innerCellComp_ = varargin{1}.innerCellComp_;
                return
            end
            
            import mlfourd.*;
            ip = inputParser;
            addOptional(ip, 'obj', InnerCellComposite, @(x) isa(x, 'mlpatterns.CellComposite') || iscell(x));
            parse(ip, varargin{:});            
            this.innerCellComp_ = InnerCellComposite(ip.Results.obj);
 		end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

