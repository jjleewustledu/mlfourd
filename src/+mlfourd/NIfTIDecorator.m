classdef NIfTIDecorator < mlfourd.NIfTIInterface
	%% NIFTIDECORATOR maintains a reference to a component object (NIfTIInterface & IOInterface),
    %  forwarding requests to the component object.   
    %  Maintains an interface consistent with the component's interface.
    %  Subclasses may optionally perform additional operations before/after forwarding requests.

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 
    properties (Dependent)
        component
        creationDate
        descrip
        entropy   
        hdxml    
        label
        machine
        negentropy
        orient
        seriesNumber  
           
        noclobber
        
        %% VoxelInterface
        
        bitpix
        datatype
        img
        mmppix
        pixdim
        
        %% IOInterface
        
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp          
    end
    
    methods %% Set/Get
        
        %% VoxelInterface
        
        function this = set.bitpix(this, x)
            this.component_.bitpix = x;
        end
        function sw = get.bitpix(this)
            sw = this.component_.bitpix;
        end
        function this = set.img(this, im)
            this.component_.img = im;
        end
        function im   = get.img(this)
            im = this.component_.img;
        end
        function this = set.datatype(this, x)
            this.component_.datatype = x;
        end
        function sw = get.datatype(this)
            sw = this.component_.datatype;
        end
        function this = set.mmppix(this, m)
            this.component_.mmppix = m;
        end
        function m    = get.mmppix(this)
            m = this.component_.mmppix;
        end
        function this = set.pixdim(this, p)
            this.component_.pixdim = p;
        end
        function p    = get.pixdim(this)
            p = this.component_.pixdim;
        end        
        
        %% IOInterface
        
        function this = set.filename(this, fn)
            this.component_.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.component_.filename;
        end
        function this = set.filepath(this, pth)
            this.component_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.component_.filepath;
        end
        function this = set.fileprefix(this, fp)
            this.component_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.component_.fileprefix;
        end
        function this = set.filesuffix(this, fs)
            this.component_.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.component_.filesuffix;
        end
        function this = set.fqfilename(this, fqfn)
            this.component_.fqfilename = fqfn; 
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.component_.fqfilename;
        end
        function this = set.fqfileprefix(this, fqfp)
            this.component_.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.component_.fqfileprefix;
        end
        function this = set.fqfn(this, f)
            this.fqfilename = f;
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function this = set.fqfp(this, f)
            this.fqfileprefix = f;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end
        
        %% NIfTIInterface
        
        function c    = get.component(this)
            c = this.component_;
        end
        function this = set.descrip(this, x)
            this.component_.descrip = x;
        end
        function x    = get.descrip(this)
            x = this.component_.descrip;
        end
        function this = set.orient(this, x)
            this.component_.orient = x;
        end
        function x    = get.orient(this)
            x = this.component_.orient;
        end        
        
        function x    = get.hdxml(this)
            x = this.component_.hdxml;
        end
        function x    = get.seriesNumber(this)
            x = this.component_.seriesNumber;
        end        
        
        function this = set.creationDate(this, x)
            this.component_.creationDate = x;
        end
        function sw = get.creationDate(this)
            sw = this.component_.creationDate;
        end
        function this = set.entropy(this, x)
            this.component_.entropy = x;
        end
        function sw = get.entropy(this)
            sw = this.component_.entropy;
        end
        function this = set.label(this, x)
            this.component_.label = x;
        end
        function sw = get.label(this)
            sw = this.component_.label;
        end
        function this = set.machine(this, x)
            this.component_.machine = x;
        end
        function sw = get.machine(this)
            sw = this.component_.machine;
        end
        function this = set.negentropy(this, x)
            this.component_.negentropy = x;
        end
        function sw = get.negentropy(this)
            sw = this.component_.negentropy;
        end
        
        %% ?
        
        function this = set.noclobber(this, nc)
            this.component_.noclobber_ = nc;
        end
        function tf   = get.noclobber(this)
            tf = this.component_.noclobber;
        end
    end
    
    methods (Static)
        function this = load(fileprefix, varargin)
            import mlfourd.*;
            this = NIfTIDecorator(NIfTI.load(fileprefix, varargin{:}));
        end
    end

    methods
 		function this = NIfTIDecorator(varargin) 
            p = inputParser;
            addOptional(p, 'cmp', mlfourd.NIfTI, @(x) isa(x, 'mlfourd.NIfTIInterface'));
            parse(p, varargin{:});
            cmp = p.Results.cmp;
            if (isa(cmp, 'mlfourd.NIfTI'))
                this.component_ = cmp;
                return
            end
            this.component_ = cmp.component_; % copy ctor 
        end 
        
        %% NIfTIInterface
        
        function this = imclose(this, varargin)
            this = mlfourd.NIfTIDecorator(this.component_.imclose(varargin{:}));
        end
        function this = imdilate(this, varargin)
            this = mlfourd.NIfTIDecorator(this.component_.imdilate(varargin{:}));
        end
        function this = imerode(this, varargin)
            this = mlfourd.NIfTIDecorator(this.component_.imerode(varargin{:}));
        end
        function this = imopen(this, varargin)
            this = mlfourd.NIfTIDecorator(this.component_.imopen(varargin{:}));
        end
        function himg = imshow(this, slice, varargin)
            himg = this.component_.imshow(slice, varargin{:});
        end
        function himg = imtool(this, slice, varargin)
            himg = this.component_.imtool(slice, varargin{:});
        end
        function im   = mlimage(this)
            im = this.component_.mlimage;
        end
        function h    = montage(this, varargin)
            h = this.component_.montage(varargin{:});
        end
        function x    = matrixsize(this)
            x = this.component_.matrixsize;
        end
        function x    = fov(this)
            x = this.component_.fov;
        end
        
        function x    = char(this)
            x = this.component_.char;
        end
        function x    = double(this)
            x = this.component_.double;
        end
        function x    = duration(this)
            x = this.component_.duration;
        end
        function x    = ones(this, varargin)
            x = this.component_.ones(varargin{:});
        end
        function x    = prod(this)
            x = this.component_.prod;
        end
        function x    = prodSize(this)
            x = this.component_.prodSize;
        end
        function x    = rank(this, varargin)
            x = this.component_.rank(varargin{:});
        end
        function this = scrubNanInf(this)
            this = mlfourd.NIfTIDecorator(this.component_.scrubNanInf);
        end
        function x    = single(this)
            x = this.component_.single;
        end
        function x    = size(this, varargin)
            x = this.component_.size(varargin{:});
        end
        function x    = sum(this)
            x = this.component_.sum;
        end
        function x    = zeros(this, varargin)
            x = this.component_.zeros(varargin{:});
        end
        
        function this = forceDouble(this)
            this = mlfourd.NIfTIDecorator(this.component_.forceDouble);
        end
        function this = forceSingle(this)
            this = mlfourd.NIfTIDecorator(this.component_.forceSingle);
        end
        function this = prepend_fileprefix(this, s)
            this = mlfourd.NIfTIDecorator(this.component_.prepend_fileprefix(s));
        end
        function this = append_fileprefix(this, s)
            this = mlfourd.NIfTIDecorator(this.component_.append_fileprefix(s));
        end
        function this = prepend_descrip(this, s)
            this = mlfourd.NIfTIDecorator(this.component_.prepend_descrip(s));
        end
        function this = append_descrip(this, s)
            this = mlfourd.NIfTIDecorator(this.component_.append_descrip(s));
        end
        
        function obj = makeSimilar(this, varargin)
            obj = mlfourd.NIfTIDecorator(this.component_.makeSimilar(varargin{:}));
        end
        function obj = clone(this)
            obj = mlfourd.NIfTIDecorator(this);
        end
        
        %% IOInterface
        
        function        save(this)
            this.component_.save;
        end
        function this = saveas(this, fqfn)
            this = mlfourd.NIfTIDecorator(this.component_.saveas(fqfn));
        end
        
        %% NumericalInterface
        
        function x = bsxfun(this, pfun, b)
            x = this.component_.bsxfun(pfun, b);
        end
        function x = plus(this, b)
            x = this.component_.plus(b);
        end
        function x = minus(this, b)
            x = this.component_.minus(b);
        end
        function x = times(this, b)
            x = this.component_.times(b);
        end
        function x = rdivide(this, b)
            x = this.component_.rdivide(b);
        end
        function x = ldivide(this, b)
            x = this.component_.ldivide(b);
        end
        function x = power(this, b)
            x = this.component_.power(b);
        end
        function x = max(this, b)
            x = this.component_.max(b);
        end
        function x = min(this, b)
            x = this.component_.min(b);
        end
        function x = rem(this, b)
            x = this.component_.rem(b);
        end
        function x = mod(this, b)
            x = this.component_.mod(b);
        end
        
        function x    = eq(this, b)
            x = this.component_.eq(b);
        end
        function x    = ne(this, b)
            x = this.component_.ne(b);
        end
        function x    = lt(this, b)
            x = this.component_.lt(b);
        end
        function x    = le(this, b)
            x = this.component_.le(b);
        end
        function x    = gt(this, b)
            x = this.component_.gt(b);
        end
        function x    = ge(this, b)
            x = this.component_.ge(b);
        end
        function this = and(this, b)
            this = mlfourd.NIfTIDecorator(this.component_.and(b));
        end
        function this = or(this, b)
            this = mlfourd.NIfTIDecorator(this.component_.or(b));
        end
        function this = xor(this, b)
            this = mlfourd.NIfTIDecorator(this.component_.xor(b));
        end
        function this = not(this)
            this = mlfourd.NIfTIDecorator(this.component_.not);
        end
        
        function this = norm(this)
            this = mlfourd.NIfTIDecorator(this.component_.norm);
        end
        function this = abs(this)
            this = mlfourd.NIfTIDecorator(this.component_.abs);
        end
        function x    = atan2(this, b)
            x = this.component_.atan2(b);
        end
        function x    = hypot(this, b)
            x = this.component_.hypot(b);
        end
        function x    = diff(this)
            x = this.component_.diff;
        end
        
        %% DipInterface 
        
        function x = dip_image(this)
            x = this.component_.dip_image;
        end
        function x = dipshow(this, varargin)
            x = this.component_.dipshow(varargin{:});
        end
        function x = dipmax(this)
            x = this.component_.dipmax;
        end
        function x = dipmean(this)
            x = this.component_.dipmean;
        end
        function x = dipmedian(this)
            x = this.component_.dipmedian;
        end
        function x = dipmin(this)
            x = this.component_.dipmin;
        end
        function x = dipprod(this)
            x = this.component_.dipprod;
        end
        function x = dipstd(this)
            x = this.component_.dipstd;
        end
        function x = dipsum(this)
            x = this.component_.dipsum;
        end        
    end 

    properties (Access = 'protected')
        component_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

