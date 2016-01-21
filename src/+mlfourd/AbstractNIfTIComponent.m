classdef AbstractNIfTIComponent < mlfourd.NIfTIIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI & mlpatterns.Composite
	%% ABSTRACTNIFTICOMPONENT  
    %  yet abstract:  load, save, saveas

	%  $Revision$
 	%  was created 20-Jan-2016 00:28:23
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
        
        %% New for AbstractNIfTIComponent
        
        separator % for descrip & label properties, not for filesystem behaviors
        stack
    end
    
    methods %% SET/GET
        
        %% NIfTIIO
        
        function this = set.filename(this, fn)
            this.innerNIfTI_.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.innerNIfTI_.filename;
        end
        function this = set.filepath(this, pth)
            this.innerNIfTI_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.innerNIfTI_.filepath;
        end
        function this = set.fileprefix(this, fp)
            this.innerNIfTI_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.innerNIfTI_.fileprefix;
        end
        function this = set.filesuffix(this, fs)
            this.innerNIfTI_.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.innerNIfTI_.filesuffix;
        end        
        function this = set.fqfilename(this, fqfn)
            this.innerNIfTI_.fqfilename = fqfn;
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.innerNIfTI_.fqfilename;
        end
        function this = set.fqfileprefix(this, fqfp)
            this.innerNIfTI_.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.innerNIfTI_.fqfileprefix;
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
            this.innerNIfTI_.noclobber = nc;
        end            
        function nc   = get.noclobber(this)
            nc = this.innerNIfTI_.noclobber;
        end    
        
        %% JimmyShenInterface
        
        function e    = get.ext(this)
            e = this.innerNIfTI_.ext;
        end
        function f    = get.filetype(this)
            f = this.innerNIfTI_.filetype;
        end
        function this = set.filetype(this, ft)
            this.innerNIfTI_.filetype = ft;
        end
        function h    = get.hdr(this)
            h = this.innerNIfTI_.hdr;
        end 
        function im   = get.img(this)
            im = this.innerNIfTI_.img;
        end        
        function this = set.img(this, im)
            %% SET.IMG sets new image state. 
            %  @param im is numeric; it updates datatype, bitpix, dim
            
            this.innerNIfTI_.img = im;
        end
        function o    = get.originalType(this)
            o = this.innerNIfTI_.originalType_;
        end
        function u    = get.untouch(this)
            u = this.innerNIfTI_.untouch;
        end
        
        %% INIfTI  
        
        function bp   = get.bitpix(this) 
            %% BIPPIX returns a datatype code as described by the NIfTId specificaitons
            
            bp = this.innerNIfTI_.bitpix;
        end
        function this = set.bitpix(this, bp) 
            this.innerNIfTI_.bitpix = bp;
        end
        function cdat = get.creationDate(this)
            cdat = this.innerNIfTI_.creationDate;
        end
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the NIfTId specificaitons
            
            dt = this.innerNIfTI_.datatype;
        end    
        function this = set.datatype(this, dt)
            this.innerNIfTI_.datatype = dt;
        end
        function d    = get.descrip(this)
            d = this.innerNIfTI_.descrip;
        end        
        function this = set.descrip(this, s)
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            
            this.innerNIfTI_.descrip = s;
        end   
        function E    = get.entropy(this)
            E = this.innerNIfTI_.entropy;
        end
        function x    = get.hdxml(this)
            %% GET.HDXML writes the xml file if this objects exists on disk
            
            x = this.innerNIfTI_.hdxml;
        end 
        function d    = get.label(this)
            d = this.innerNIfTI_.label;
        end     
        function this = set.label(this, s)
            this.innerNIfTI_.label = s;
        end
        function ma   = get.machine(this)
            ma = this.innerNIfTI_.machine;
        end
        function mpp  = get.mmppix(this)
            mpp = this.innerNIfTI_.mmppix;
        end        
        function this = set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            this.innerNIfTI_.mmppix = mpp;
        end  
        function E    = get.negentropy(this)
            E = this.innerNIfTI_.negentropy;
        end
        function o    = get.orient(this)
            o = this.innerNIfTI_.orient;
        end
        function pd   = get.pixdim(this)
            pd = this.innerNIfTI_.pixdim;
        end        
        function this = set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s.
            
            this.innerNIfTI_.pixdim = pd;
        end  
        function num  = get.seriesNumber(this)
            num = this.innerNIfTI_.seriesNumber;
        end
        
        %% New for AbstractNIfTIComponent
        
        function s    = get.separator(this)
            s = this.innerNIfTI_.separator;
        end
        function this = set.separator(this, s)
            this.innerNIfTI_.separator = s;
        end
        function s    = get.stack(this)
            %% GET.STACK
            %  See also:  doc('dbstack')
            
            s = this.innerNIfTI_.stack;
        end
    end
    
	methods
        
        %% NIfTIIO
        
        function        save(this)
            this.innerNIfTI_.save;
        end
        function this = saveas(this, fqfn)
            this.innerNIfTI_ = this.innerNIfTI_.saveas(fqfn);
        end
        function this = saveasx(this, fqfn, x)
            this.innerNIfTI_ = this.innerNIfTI_.saveasx(fqfn, x);
        end
        
        %% INIfTI  
        
        function c = char(this)
            c = this.innerNIfTI_.char;
        end
        function this = append_descrip(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.append_descrip(varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.prepend_descrip(varargin{:});
        end
        function d = double(this)
            d = this.innerNIfTI_.double;
        end
        function d = duration(this)
            d = this.innerNIfTI_.duration;
        end
        function this = append_fileprefix(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.append_fileprefix(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.prepend_fileprefix(varargin{:});
        end
        function f = fov(this)
            f = this.innerNIfTI_.fov;
        end
%         function [tf,msg] = isequal(this, obj)
%             [tf,msg] = this.innerNIfTI_.isequal(obj);
%         end
%         function [tf,msg] = isequaln(this, obj)            
%             [tf,msg] = this.innerNIfTI_.isequaln(obj);
%         end
        function m = matrixsize(this)
            m = this.innerNIfTI_.matrixsize;
        end
        function o = ones(this)
            o = this.innerNIfTI_.ones;
        end
        function this = prod(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.prod(varargin{:});
        end
        function r = rank(this, varargin)
            r = this.innerNIfTI_.rank(varargin{:});
        end
        function this = scrubNanInf(this)
            this.innerNIfTI_ = this.innerNIfTI_.scrubNanInf;
        end
        function s = single(this)
            s = this.innerNIfTI_.single;
        end
        function s = size(this, varargin)
            s = this.innerNIfTI_.size(varargin{:});
        end
        function this = sum(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.sum(varargin{:});
        end
        function z = zeros(this)
            z = this.innerNIfTI_.zeros;
        end
        
        %% New for AbstractNIfTIComponent
        
        function e = fslentropy(this)
            e = this.innerNIfTI_.fslentropy;
        end
        function E = fslEntropy(this)
            E = this.innerNIfTI_.fslEntropy;
        end
        function freeview(this, varargin)
            this.innerNIfTI_.freeview(varargin{:});
        end
        function fslview(this, varargin)
            this.innerNIfTI_.fslview(varargin{:});
        end
        function this = optimizePrecision(this)
            this.innerNIfTI_ = this.innerNIfTI_.optimizePrecision;
        end
        
        %% mlpatterns.Composite
        
        function this = add(this, varargin)
            this = this.innerNIfTI_.add(varargin{:});
        end        
        function iter = createIterator(this)
            iter = this.innerNIfTI_.createIterator;
        end
%         function        disp(this)
%             this.innerNIfTI_.disp;
%         end
        function idx  = find(this, obj)
            idx = this.innerNIfTI_.find(obj);
        end
        function obj  = get(this, idx)
            obj = this.innerNIfTI_.get(idx);
        end
        function tf   = isempty(this)
            tf = this.innerNIfTI_.isempty;
        end
        function len  = length(this)
            len = this.innerNIfTI_.length;
        end
        function        rm(this, idx)
            this.innerNIfTI_.rm(idx);
        end
        function s    = csize(this)   
            s = this.innerNIfTI_.csize;
        end     
    end
    
    %% PROTECTED
    
    methods (Access = protected)
 		function this = AbstractNIfTIComponent(inner)
            assert(isa(inner, 'mlfourd.NIfTIIO') && ...
                   isa(inner, 'mlfourd.JimmyShenInterface') && ...
                   isa(inner, 'mlfourd.INIfTI'));
            this.innerNIfTI_ = inner;
 		end
    end 
    
    properties (Access = protected)
        innerNIfTI_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

