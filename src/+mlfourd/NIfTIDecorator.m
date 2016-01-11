classdef NIfTIdecorator < mlfourd.INIfTI & mlio.IOInterface
	%% NIFTIDECORATOR maintains an internal component object by composition, 
    %  forwarding most requests to the component.  It retains an interface consistent with the component's interface.
    %  Subclasses may optionally perform additional operations before/after forwarding requests.
    %  Subclasses must overload methods load, clone to ensure that method-returned objects are from the subclass.
    %  KLUDGE:  Matlab checks that dependent properties do not access stored values.  Multiple composed NIfTIdecorator 
    %  objects use recursion on getters, violating this requirement on dependent properties.  Viz.:
    %     
    %      >> nii = NIfTId.load('p7991oc1.nii.gz'); ndec = MaskingNIfTId(nii); ndec.filename
    %     
    %      ans = p7991oc1.nii.gz
    %     
    %      >> nii = NIfTId.load('p7991oc1.nii.gz'); ndec = MaskingNIfTId(MaskingNIfTId(nii)); ndec.filename
    %      In class 'mlfourd.NIfTIdecorator', the get method for Dependent property 'filename' attempts to 
    %      access the stored property value.  Dependent properties don't store a value and can't be accessed
    %      from their get method.
    %     
    %      Error in mlfourd.NIfTIdecorator/get.filename (line 66)
    %                  fn = this.component_.filename;
    %     
    %  Using NIfTIdecorator2/3/4/5 for each decorator subclass is a work-around.
    %  See also:  <a href="matlab:
    %              web('http://www.mathworks.com/help/releases/R2015a/matlab/matlab_oop/how-to-use-properties.html#brh76wy-1_2')">How To Use Properties</a>

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
    
    properties (Dependent)
        
        component
        
        %% IOInterface
        
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp 
        noclobber
        
        %% INIfTI
        
        img
        
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
    end
    
    methods %% Set/Get
        
        function c    = get.component(this)
            c = this.component_;
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
        function this = set.noclobber(this, nc)
            this.component_.noclobber_ = nc;
        end
        function tf   = get.noclobber(this)
            tf = this.component_.noclobber;
        end
        
        %% INIfTI
        
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
    end
    
    methods (Static)
        
        %% IOInterface
        
        function this = load(varargin)
            %% LOAD passes its arguments to NIfTId.load, then keeps the loaded object as an internal component by composition.
            %  Usage:  obj = NIfTIdecorator.load(filename[, description]);
            
            import mlfourd.*;
            this = NIfTIdecorator(NIfTId.load(varargin{:}));
        end
    end

    methods
 		function this = NIfTIdecorator(varargin) 
            %% NIFTIDECORATOR decorates other INIfTI objects, keeping the passed object as an internal component by composition;
            %  it will not act as a copy-ctor, as all passed objects are kept in a hierarchy of components.
            %  Usage:  obj = NIfTIdecorator(INIfTI_object);
            
            p = inputParser;
            addOptional(p, 'cmp', mlfourd.NIfTId, @(x) isa(x, 'mlfourd.INIfTI'));
            parse(p, varargin{:});
            this.component_ = p.Results.cmp;
        end 
        
        %% IOInterface
        
        function        save(this)
            this.component_.save;
        end
        function obj  = saveas(this, fqfn)
            obj = this.clone;
            obj.component_ = this.component_.saveas(fqfn);
        end
        
        %% INIfTI
        
        function obj  = clone(this)
            obj = this;
            obj.component_ = this.component_.clone;
        end   
        function [tf,msg] = isequal(this, niid)
            [tf,msg] = this.isequaln(niid);
        end
        function [tf,msg] = isequaln(this, niid)
            msg = '';
            tf = isa(niid, class(this));
            if (tf)
                [tf,msg] = this.component_.isequaln(niid.component_);
            end
        end
        function this = makeSimilar(this, varargin)
            this.component_ = this.component_.makeSimilar(varargin{:});
        end  
        
        function x    = char(this)
            x = this.component_.char;
        end
        function this = append_descrip(this, s)
            this.component_ = this.component_.append_descrip(s);
        end
        function this = prepend_descrip(this, s)
            this.component_ = this.component_.prepend_descrip(s);
        end
        function x    = double(this)
            x = this.component_.double;
        end
        function x    = duration(this)
            x = this.component_.duration;
        end
        function this = append_fileprefix(this, s)
            this.component_ = this.component_.append_fileprefix(s);
        end
        function this = prepend_fileprefix(this, s)
            this.component_ = this.component_.prepend_fileprefix(s);
        end
        function f    = fov(this) 
            f = this.component_.fov;     
        end
        function m    = matrixsize(this)
            m = this.component_.matrixsize;
        end
        function this = ones(this, varargin)
            this.component_ = this.component_.ones(varargin{:});
        end
        function x    = prod(this)
            x = this.component_.prod;
        end
        function x    = rank(this, varargin)
            x = this.component_.rank(varargin{:});
        end
        function this = scrubNanInf(this)
            this.component_ = this.component_.scrubNanInf;
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
        function this = zeros(this, varargin)
            this.component_ = this.component_.zeros(varargin{:});
        end        
                   
        function        freeview(this, varargin)
            this.component_.freeview(varargin{:});
        end        
        function        fslview(this, varargin)
            this.component_.fslview(varargin{:});
        end
    end 
    
    properties (Access = 'protected')
        component_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

