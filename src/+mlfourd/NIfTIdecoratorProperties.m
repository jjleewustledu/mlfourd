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
        
        %%
        
        imgrec
        logger
        separator
        stack
        viewer
    end
  
    methods 
        
        %% SET/GET
        
        % NIfTIIO        
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
            this.component_.noclobber = nc;
        end
        function tf   = get.noclobber(this)
            tf = this.component_.noclobber;
        end
        
        % JimmyShenInterface        
        function e    = get.ext(this)
            e = this.component_.ext;
        end
        function f    = get.filetype(this)
            f = this.component_.filetype;
        end
        function this = set.filetype(this, ft)
            this.component_.filetype = ft;
        end
        function h    = get.hdr(this)
            h = this.component_.hdr;
        end 
        function this = set.img(this, im)
            this.component_.img = im;
        end
        function im   = get.img(this)
            im = this.component_.img;
        end
        function o    = get.originalType(this)
            o = this.component_.originalType;
        end
        function u    = get.untouch(this)
            u = this.component_.untouch;
        end        
        
        % INIfTI         
        function this = set.bitpix(this, x)
            this.component_.bitpix = x;
        end
        function sw   = get.bitpix(this)
            sw = this.component_.bitpix;
        end
        function this = set.creationDate(this, x)
            this.component_.creationDate = x;
        end
        function sw   = get.creationDate(this)
            sw = this.component_.creationDate;
        end
        function this = set.datatype(this, x)
            this.component_.datatype = x;
        end
        function sw   = get.datatype(this)
            sw = this.component_.datatype;
        end
        function this = set.descrip(this, x)
            this.component_.descrip = x;
        end
        function x    = get.descrip(this)
            x = this.component_.descrip;
        end
        function this = set.entropy(this, x)
           this.component_.entropy = x;
        end
       function sw    = get.entropy(this)
           sw = this.component_.entropy;
       end
        function x    = get.hdxml(this)
            x = this.component_.hdxml;
        end
        function this = set.label(this, x)
            this.component_.label = x;
        end
        function sw   = get.label(this)
            sw = this.component_.label;
        end
        function this = set.machine(this, x)
            this.component_.machine = x;
        end
        function sw   = get.machine(this)
            sw = this.component_.machine;
        end
        function this = set.negentropy(this, x)
            this.component_.negentropy = x;
        end
        function sw   = get.negentropy(this)
            sw = this.component_.negentropy;
        end        
        function this = set.mmppix(this, m)
            this.component_.mmppix = m;
        end
        function m    = get.mmppix(this)
            m = this.component_.mmppix;
        end
        function this = set.orient(this, x)
            this.component_.orient = x;
        end
        function x    = get.orient(this)
            x = this.component_.orient;
        end   
        function this = set.pixdim(this, p)
            this.component_.pixdim = p;
        end
        function p    = get.pixdim(this)
            p = this.component_.pixdim;
        end   
        function num  = get.seriesNumber(this)
            num = this.component_.seriesNumber;
        end
        
        %    
        function g    = get.imgrec(this)
            g = this.component_.imgrec;
        end 
        function g    = get.logger(this)
            g = this.component_.logger;
        end
        function s    = get.separator(this)
            s = this.component_.separator;
        end
        function this = set.separator(this, s)
            this.component_.separator = s;
        end
        function s    = get.stack(this)
            s = this.component_.stack;
        end
        function s    = get.viewer(this)
            s = this.component_.viewer;
        end
        function this = set.viewer(this, s)
            this.component_.viewer = s;
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

