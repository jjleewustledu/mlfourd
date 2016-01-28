classdef NIfTIdecoratorProperties < mlfourd.NIfTIdecorator
	%% NIFTIDECORATORPROPERTIES  

	%  $Revision$
 	%  was created 11-Jan-2016 13:52:56
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    properties (Dependent)
        
        %% NIfTIIO
        
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp 
        noclobber
        
        %% JimmyShenInterface
        
        ext
        filetype % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr
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
        
        %% New for NIfTIdecoratorProperties
        
        lexistFile
        separator
        stack
    end
  
    methods %% SET/GET
        
        %% NIfTIIO
        
        function this = set.filename(this, fn)
            this.component.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.component.filename;
        end
        function this = set.filepath(this, pth)
            this.component.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.component.filepath;
        end
        function this = set.fileprefix(this, fp)
            this.component.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.component.fileprefix;
        end
        function this = set.filesuffix(this, fs)
            this.component.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.component.filesuffix;
        end
        function this = set.fqfilename(this, fqfn)
            this.component.fqfilename = fqfn; 
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.component.fqfilename;
        end
        function this = set.fqfileprefix(this, fqfp)
            this.component.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.component.fqfileprefix;
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
            this.component.noclobber_ = nc;
        end
        function tf   = get.noclobber(this)
            tf = this.component.noclobber;
        end
        
        %% JimmyShenInterface
        
        function e    = get.ext(this)
            e = this.component.ext;
        end
        function f    = get.filetype(this)
            f = this.component.filetype;
        end
        function this = set.filetype(this, ft)
            this.component.filetype = ft;
        end
        function h    = get.hdr(this)
            h = this.component.hdr;
        end 
        function this = set.img(this, im)
            this.component.img = im;
        end
        function im   = get.img(this)
            im = this.component.img;
        end
        function o    = get.originalType(this)
            o = this.component.originalType;
        end
        function u    = get.untouch(this)
            u = this.component.untouch;
        end        
        
        %% INIfTI
         
        function this = set.bitpix(this, x)
            this.component.bitpix = x;
        end
        function sw   = get.bitpix(this)
            sw = this.component.bitpix;
        end
        function this = set.creationDate(this, x)
            this.component.creationDate = x;
        end
        function sw   = get.creationDate(this)
            sw = this.component.creationDate;
        end
        function this = set.datatype(this, x)
            this.component.datatype = x;
        end
        function sw   = get.datatype(this)
            sw = this.component.datatype;
        end
        function this = set.descrip(this, x)
            this.component.descrip = x;
        end
        function x    = get.descrip(this)
            x = this.component.descrip;
        end
        function this = set.entropy(this, x)
           this.component.entropy = x;
        end
       function sw    = get.entropy(this)
           sw = this.component.entropy;
       end
        function x    = get.hdxml(this)
            x = this.component.hdxml;
        end
        function this = set.label(this, x)
            this.component.label = x;
        end
        function sw   = get.label(this)
            sw = this.component.label;
        end
        function this = set.machine(this, x)
            this.component.machine = x;
        end
        function sw   = get.machine(this)
            sw = this.component.machine;
        end
        function this = set.negentropy(this, x)
            this.component.negentropy = x;
        end
        function sw   = get.negentropy(this)
            sw = this.component.negentropy;
        end        
        function this = set.mmppix(this, m)
            this.component.mmppix = m;
        end
        function m    = get.mmppix(this)
            m = this.component.mmppix;
        end
        function this = set.orient(this, x)
            this.component.orient = x;
        end
        function x    = get.orient(this)
            x = this.component.orient;
        end   
        function this = set.pixdim(this, p)
            this.component.pixdim = p;
        end
        function p    = get.pixdim(this)
            p = this.component.pixdim;
        end   
        function num  = get.seriesNumber(this)
            num = this.component.seriesNumber;
        end
        
        %% New for AbstractNIfTIComponent
        
        function tf   = get.lexistFile(this)
            tf = this.component.lexistFile;
        end
        function s    = get.separator(this)
            s = this.component.separator;
        end
        function this = set.separator(this, s)
            this.component.separator = s;
        end
        function s    = get.stack(this)
            s = this.component.stack;
        end
    end
    
	methods (Access = protected)
 		function this = NIfTIdecoratorProperties(varargin)
 			%% NIFTIDECORATORPROPERTIES
 			%  Usage:  this = NIfTIdecoratorProperties()

 			this = this@mlfourd.NIfTIdecorator(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

