classdef AbstractNIfTIComponent < mlfourd.AbstractComponent & mlfourd.NIfTIInterface 
	%% ABSTRACTNIFTICOMPONENT is a cousin of AbstractNIfTI, intended for composite design patterns. 
    %  Yet abstract:
    %      properties:  descrip, img, mmppix, pixdim
    %      methods:     makeSimilar, clone

	%  $Revision: 2618 $ 
 	%  was created $Date: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-08 23:15:55 -0500 (Sun, 08 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/AbstractNIfTIComponent.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: AbstractNIfTIComponent.m 2618 2013-09-09 04:15:55Z jjlee $ 
    
	properties (Dependent) 
        bitpix          
        creationDate 
        datatype
        entropy
        hdxml
        label
        machine
        negentropy        
        orient
        seriesNumber
    end 

    methods %% GET/SET
        function b  = get.bitpix(this)
            b = this.cachedNext.bitpix;
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
        function num = get.seriesNumber(this)
            num = this.cachedNext.seriesNumber;
        end
    end
    
	methods
        
        %% Implemented mlfourd.NIfTIInterface methods; mostly delegated to this.cachedNext
        
        function this = imclose(this, varargin)
            this = this.cachedNext.imclose(varargin{:});
        end
        function this = imdilate(this, varargin)
            this = this.cachedNext.imdilate(varargin{:});
        end
        function this = imerode(this, varargin)
            this = this.cachedNext.imerode(varargin{:});
        end
        function this = imopen(this, varargin)
            this = this.cachedNext.imopen(varargin{:});
        end
        function himg = imshow(this, slice, varargin)
            himg = this.cachedNext.imshow(slice, varargin{:});
        end
        function himg = imtool(this, slice, varargin)
            himg = this.cachedNext.imtool(slice, varargin{:});
        end
        function im   = mlimage(this)
            im = this.cachedNext.mlimage;
        end
        function h    = montage(this, varargin)
            h = this.cachedNext.montage(varargin{:});
        end
        function m3d  = matrixsize(this)
            m3d = this.cachedNext.matrixsize;
        end
        function f3d  = fov(this)
            f3d = this.cachedNext.fov;
        end
        
        function ch  = char(this)
            ch = this.cachedNext.char;
        end
        function d   = double(this)
            d = this.cachedNext.double;
        end
        function d   = duration(this)
            d = this.cachedNext.duration;
        end
        function o   = ones(this, varargin)
            o = this.cachedNext.ones(varargin{:});
        end
        function M   = prod(this)
            M = this.cachedNext.prod;
        end
        function ps  = prodSize(this)
            ps = this.cachedNext.prodSize;
        end
        function rnk = rank(this, varargin)
             rnk = this.cachedNext.rank(varargin{:});
        end
        function nii  = scrubNanInf(this)
            nii = this.cachedNext.scrubNanInf;
        end
        function s   = single(this)
            s = this.cachedNext.single;
        end
        function sz  = size(this, varargin)
            sz = this.cachedNext.size(varargin{:});
        end
        function M   = sum(this)
            M = this.cachedNext.sum;
        end
        function z   = zeros(this, varargin)
            z = this.cachedNext.zeros(varargin{:});
        end
        
        function this = forceDouble(this)
            this.cachedNext = this.cachedNext.forceDouble;
        end
        function this = forceSingle(this)
            this.cachedNext = this.cachedNext.forceSingle;
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
        
        %% Implemented mlanalysis.NumericalInterface
        
        function c    = bsxfun(this, pfun, b)
            c = this.cachedNext.bsxfun(pfun, b);
        end
        function c    = plus(this, b)
             c = this.cachedNext.plus(b);
        end
        function c    = minus(this, b)
             c = this.cachedNext.minus(b);
        end
        function c    = times(this, b)
             c = this.cachedNext.times(b);
        end
        function c    = rdivide(this, b)
             c = this.cachedNext.rdivide(b);
        end
        function c    = ldivide(this, b)
             c = this.cachedNext.ldivide(b);
        end
        function c    = power(this, b)
             c = this.cachedNext.power(b);
        end
        function c    = max(this, b)
             c = this.cachedNext.max(b);
        end
        function c    = min(this, b)
             c = this.cachedNext.min(b);
        end
        function c    = rem(this, b) % remainder after division
             c = this.cachedNext.rem(b);
        end
        function c    = mod(this, b)
             c = this.cachedNext.mod(b);
        end
        
        function c    = eq(this, b)
             c = this.cachedNext.eq(b);
        end
        function c    = ne(this, b)
             c = this.cachedNext.ne(b);
        end
        function c    = lt(this, b)
             c = this.cachedNext.lt(b);
        end
        function c    = le(this, b)
             c = this.cachedNext.le(b);
        end
        function c    = gt(this, b)
             c = this.cachedNext.gt(b);
        end
        function c    = ge(this, b)
             c = this.cachedNext.ge(b);
        end
        function this = and(this, b)
            this = this.cachedNext.(b);
        end
        function this = or(this, b)
            this = this.cachedNext.(b);
        end
        function this = xor(this, b)
            this = this.cachedNext.(b);
        end
        function this = not(this, b)
            this = this.cachedNext.(b);
        end
        
        function this = norm(this)
            this = this.cachedNext.norm;
        end
        function this = abs(this)
            this = this.cachedNext.abs;
        end
        function c    = atan2(this, b)
            c = this.cachedNext.atan2(b);
        end
        function c    = hypot(this, b)
            c = this.cachedNext.hypot(b);
        end
        function M    = diff(this)
            M = this.cachedNext.diff(b);
        end
        
        %% Implemented mlanalysis.DipInterface
        
        function di   = dip_image(this)
            di = this.cachedNext.dip_image;
        end
        function h    = dipshow(this)
            h = this.cachedNext.dipshow;
        end
        function mxi  = dipmax(this)
            mxi = this.cachedNext.dipmax;
        end
        function m    = dipmean(this)
            m = this.cachedNext.dipmean;
        end
        function m    = dipmedian(this)
            m = this.cachedNext.dipmedian;
        end
        function mni  = dipmin(this)
            mni = this.cachedNext.dipmin;
        end
        function prd  = dipprod(this)
            prd = this.cachedNext.dipprod;
        end
        function s    = dipstd(this)
            s = this.cachedNext.dipstd;
        end
        function sm   = dipsum(this)
            sm = this.cachedNext.dipsum;
        end
    end 

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = AbstractNIfTIComponent(varargin)
            this = this@mlfourd.AbstractComponent(varargin{:});
            this.creationDate_ = datestr(now);
        end % ctor
    end 
    
    %% PRIVATE 
    
    properties (Access = 'private')
        creationDate_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

