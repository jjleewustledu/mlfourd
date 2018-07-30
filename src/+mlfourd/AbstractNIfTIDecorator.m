classdef AbstractNIfTIDecorator < mlfourd.INIfTIComponent
	%% ABSTRACTNIFTIDECORATOR  

	%  $Revision$
 	%  was created 24-Jul-2018 01:02:19 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
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
        
        ext
        filetype % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        hdr
        img
        originalType
        untouch
        
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
        
        imagingInfo
        logger
        separator % for descrip & label properties, not for filesystem behaviors
        stack
        viewer
    end
    
	methods 
        
        %% SET/GET
        
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
        function nc   = get.noclobber(this)
            nc = this.component_.noclobber;
        end    
        
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
        function im   = get.img(this)
            im = this.component_.img;
        end        
        function this = set.img(this, im)
            %% SET.IMG sets new image state. 
            %  @param im is numeric; it updates datatype, bitpix, dim
            
            this.component_.img = im;
        end
        function o    = get.originalType(this)
            o = this.component_.originalType_;
        end
        function u    = get.untouch(this)
            u = this.component_.untouch;
        end
        
        function bp   = get.bitpix(this) 
            %% BIPPIX returns a datatype code as described by the NIfTId specificaitons
            
            bp = this.component_.bitpix;
        end
        function this = set.bitpix(this, bp) 
            this.component_.bitpix = bp;
        end
        function cdat = get.creationDate(this)
            cdat = this.component_.creationDate;
        end
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the NIfTId specificaitons
            
            dt = this.component_.datatype;
        end    
        function this = set.datatype(this, dt)
            this.component_.datatype = dt;
        end
        function d    = get.descrip(this)
            d = this.component_.descrip;
        end        
        function this = set.descrip(this, s)
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            
            this.component_.descrip = s;
        end   
        function E    = get.entropy(this)
            E = this.component_.entropy;
        end
        function x    = get.hdxml(this)
            %% GET.HDXML writes the xml file if this objects exists on disk
            
            x = this.component_.hdxml;
        end 
        function d    = get.label(this)
            d = this.component_.label;
        end     
        function this = set.label(this, s)
            this.component_.label = s;
        end
        function ma   = get.machine(this)
            ma = this.component_.machine;
        end
        function mpp  = get.mmppix(this)
            mpp = this.component_.mmppix;
        end        
        function this = set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            this.component_.mmppix = mpp;
        end  
        function E    = get.negentropy(this)
            E = this.component_.negentropy;
        end
        function o    = get.orient(this)
            o = this.component_.orient;
        end
        function pd   = get.pixdim(this)
            pd = this.component_.pixdim;
        end        
        function this = set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s.
            
            this.component_.pixdim = pd;
        end  
        function num  = get.seriesNumber(this)
            num = this.component_.seriesNumber;
        end
        
        function ii   = get.imagingInfo(this)
            ii = this.component_.imagingInfo;
        end
        function im   = get.logger(this)
            im = this.component_.logger;
        end
        function s    = get.separator(this)
            s = this.component_.separator;
        end
        function this = set.separator(this, s)
            this.component_.separator = s;
        end
        function s    = get.stack(this)
            %% GET.STACK
            %  See also:  doc('dbstack')
            
            s = this.component_.stack;
        end
        function v    = get.viewer(this)
            v = this.component_.viewer;
        end
        function this = set.viewer(this, v)
            this.component_.viewer = v;
        end    
        
        %%        
        
        function        addLog(this, varargin)
            this.component_.addLog(varargin{:});
        end
        function c    = char(this)
            c = this.component_.char;
        end
        function this = append_descrip(this, varargin)
            this.component_ = this.component_.append_descrip(varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.component_ = this.component_.prepend_descrip(varargin{:});
        end
        function d    = double(this)
            d = this.component_.double;
        end
        function d    = duration(this)
            d = this.component_.duration;
        end
        function this = append_fileprefix(this, varargin)
            this.component_ = this.component_.append_fileprefix(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.component_ = this.component_.prepend_fileprefix(varargin{:});
        end
        function f    = fov(this)
            f = this.component_.fov;
        end
        function e    = fslentropy(this)
            e = this.component_.fslentropy;
        end
        function E    = fslEntropy(this)
            E = this.component_.fslEntropy;
        end
        function        freeview(this, varargin)
            this.component_.freeview(varargin{:});
        end
        function        fsleyes(this, varargin)
            this.component_.fsleyes(varargin{:});
        end
        function        fslview(this, varargin)
            this.component_.fslview(varargin{:});
        end
        function        hist(this, varargin)
            this.component_.hist(varargin{:});
        end        
        function tf   = lexist(this)
            tf = this.component_.lexist;
        end
        function m    = matrixsize(this)
            m = this.component_.matrixsize;
        end
        function this = prod(this, varargin)
            this.component_ = this.component_.prod(varargin{:});
        end
        function r    = rank(this, varargin)
            r = this.component_.rank(varargin{:});
        end
        function        save(this)
            this.component_.save;
        end
        function this = saveas(this, fqfn)
            this.component_ = this.component_.saveas(fqfn);
        end
        function this = saveasx(this, fqfn, x)
            this.component_ = this.component_.saveasx(fqfn, x);
        end
        function this = scrubNanInf(this)
            this.component_ = this.component_.scrubNanInf;
        end
        function s    = single(this)
            s = this.component_.single;
        end
        function s    = size(this, varargin)
            s = this.component_.size(varargin{:});
        end
        function this = sum(this, varargin)
            this.component_ = this.component_.sum(varargin{:});
        end
        function        view(this, varargin)
            this.component_.viewer = this.viewer;
            this.component_.view(varargin{:});
        end  
		  
 		function this = AbstractNIfTIDecorator(varargin)
 			%% ABSTRACTNIFTIDECORATOR
 			%  @param .

            ip = inputParser;
            AddRequired(ip, 'component', @(x) isa(x, INIfTIComponent));
            parse(ip, varargin{:});
            this.component_ = ip.Results.component;
 		end
    end 
    
    %% PRIVATE
    
	properties (Access = private)
 		component_
 	end


	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

