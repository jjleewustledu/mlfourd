classdef AbstractImagingComponent < mlio.AbstractComponentIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI 
	%% ABSTRACTNIFTICOMPONENT is a parallel hierarchy of AbstractNIfTId, intended for composite design patterns. 

	%  $Revision: 2618 $ 
 	%  was created $Date: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractImagingComponent.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: AbstractImagingComponent.m 2618 2013-09-09 04:15:55Z jjlee $ 
    
	properties (Dependent)
        
        % After mlfourd.JimmyShenInterface:  to support struct arguments to NIfTId ctor  
        img
        ext
        filetype   % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr        %     N.B.:  to change the data type, set nii.hdr.dime.datatype,
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
        untouch
        descrip
        mmppix
        pixdim
        
        creationDate 
        datatype
        entropy
        hdxml
        label
        machine
        negentropy        
        orient
        separator
        seriesNumber
        bitpix     
    end 

    methods %% GET; SET each cachedNext directly
        function im = get.img(this)
            im = this.cachedNext.img;
        end
        function im = get.ext(this)
            im = this.cachedNext.ext;
        end
        function im = get.filetype(this)
            im = this.cachedNext.filetype;
        end
        function im = get.hdr(this)
            im = this.cachedNext.hdr;
        end
        function im = get.originalType(this)
            im = this.cachedNext.originalType;
        end
        function im = get.untouch(this)
            im = this.cachedNext.untouch;
        end
        function d  = get.descrip(this)
            d = this.cachedNext.descrip;
        end
        function m  = get.mmppix(this)
            m = this.cachedNext.mmppix;
        end
        function p  = get.pixdim(this)
            p = this.cachedNext.pixdim;
        end 
        
        function c  = get.creationDate(this)
            c = this.cachedNext.creationDate;
        end
        function d  = get.datatype(this)
            d = this.cachedNext.datatype;
        end
        function e  = get.entropy(this)
            e = this.cachedNext.entropy;
        end
        function x  = get.hdxml(this)
            x = this.cachedNext.hdxml;
        end
        function l  = get.label(this)
            l = this.cachedNext.label;
        end   
        function m  = get.machine(this)
            m = this.cachedNext.machine;
        end    
        function e  = get.negentropy(this)
            e = this.cachedNext.negentropy;
        end 
        function o  = get.orient(this)
            o = this.cachedNext.orient;
        end
        function o  = get.separator(this)
            o = this.cachedNext.separator;
        end
        function num = get.seriesNumber(this)
            num = this.cachedNext.seriesNumber;
        end
        function b  = get.bitpix(this)
            b = this.cachedNext.bitpix;
        end 
    end
    
	methods
        function ch  = char(this)
            ch = this.cachedNext.char;
        end
        function d   = double(this)
            d = this.cachedNext.double;
        end
        function d   = duration(this)
            d = this.cachedNext.duration;
        end
        function n   = numel(this)
            n = numel(this.img);
        end
        function o   = ones(this, varargin)
            o = this.cachedNext.ones(varargin{:});
        end
        function rnk = rank(this, varargin)
             rnk = this.cachedNext.rank(varargin{:});
        end
        function nii = scrubNanInf(this)
            nii = this.cachedNext.scrubNanInf;
        end
        function s   = single(this)
            s = this.cachedNext.single;
        end
        function sz  = size(this, varargin)
            sz = this.cachedNext.size(varargin{:});
        end
        function ps  = zeros(this)
            ps = this.cachedNext.zeros;
        end
        function M   = prod(this)
            M = this.cachedNext.prod;
        end
        function M   = sum(this)
            M = this.cachedNext.sum;
        end
        
        function this = prepend_fileprefix(this, s)
            this = this.cachedNext.prepend_fileprefix(s);
        end
        function this = append_fileprefix(this, s)
            this = this.cachedNext.append_fileprefix(s);
        end
        function this = prepend_descrip(this, s)
            this = this.cachedNext.prepend_descrip(s);
        end
        function this = append_descrip(this, s)
            this = this.cachedNext.append_descrip(s);
        end
        
        function        freeview(~)
            if (isa(this.cachedNext, 'mlfourd.INIfTI'))
                this.cachedNext.freeview; end
        end        
        function        fslview(~)
            if (isa(this.cachedNext, 'mlfourd.INIfTI'))
                this.cachedNext.fslview; end
        end
        function m3d  = matrixsize(this)
            m3d = this.cachedNext.matrixsize;
        end
        function f3d  = fov(this)
            f3d = this.cachedNext.fov;
        end
    end 

    %% PROTECTED
    
    properties (Access = 'protected')
        componentCreationDate_
    end
    
    methods (Access = 'protected')
        function this = AbstractImagingComponent(varargin)
            this = this@mlio.AbstractComponentIO(varargin{:});
            this.componentCreationDate_ = datestr(now);
        end % ctor
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

