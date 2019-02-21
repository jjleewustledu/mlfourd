classdef (Abstract) AbstractNIfTIComponent < mlfourd.RootNIfTIComponent & mlfourd.NIfTIIO & mlfourd.JimmyShenInterface & mlfourd.INIfTI
	%% ABSTRACTNIFTICOMPONENT supports a composite design pattern using InnerNIfTI, InnerNIfTIc and common interface
    %  INIfTI.  See also concrete implementations mlfourd.NIfTId and mlfourd.NIfTIc.
    %  See also:  mlfourdfp.InnerFourdfp and mlsurfer.InnerMGH.

	%  $Revision$
 	%  was created 20-Jan-2016 00:28:23
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 
    properties (Constant)
        EQUALN_IGNORES = ...
            {'bitpix' 'creationDate' 'datatype' 'descrip' 'glmax' 'hdr' 'hdxml' 'imagingInfo' 'imgrec' 'label' 'logger' 'orient' 'originalType' 'regular' 'stack' 'untouch'}
    end
    
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
        imgrec
        logger
        separator % for descrip & label properties, not for filesystem behaviors
        stack
        viewer
    end
    
    methods 
        
        %% SET/GET
        
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
        
        function e    = get.ext(this)
            e = this.innerNIfTI_.ext;
        end
        function f    = get.filetype(this)
            f = this.innerNIfTI_.filetype;
        end
        function this = set.filetype(this, ft)
            this.innerNIfTI_.imagingInfo.filetype = ft;
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
        
        function ii   = get.imagingInfo(this)
            ii = this.innerNIfTI_.imagingInfo;
        end
        function g    = get.imgrec(this)
            if (~isprop(this.innerNIfTI_, 'imgrec'))
                g = [];
                return
            end
            g = this.innerNIfTI_.imgrec;
        end
        function g    = get.logger(this)
            g = this.innerNIfTI_.logger;
        end
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
        function v    = get.viewer(this)
            v = this.innerNIfTI_.viewer;
        end
        function this = set.viewer(this, v)
            this.innerNIfTI_.viewer = v;
        end         
                
        %% mlpatterns.Composite, an interface
        
        function this = add(~, ~) %#ok<STOUT>
            error('mlfourd:notImplemented', 'AbstractNIfTIComponent.add should not be called');
        end        
        function iter = createIterator(~) %#ok<STOUT>
            error('mlfourd:notImplemented', 'AbstractNIfTIComponent.createIterator should not be called');
        end
        function idx  = find(this, obj)
            if (this.isequal(obj))
                idx = 1;
                return
            end
            idx = [];
        end
        function obj  = get(this, idx)
            if (idx == 1)
                obj = this;
                return
            end
            obj = [];
        end
        function tf   = isempty(this)
            tf = isempty(this.img);
        end
        function len  = length(~)
            len = 1;
        end
        function        rm(~, ~)
            error('mlfourd:notImplemented', 'AbstractNIfTIComponent.rm should not be called');
        end
        function s    = csize(~)
            s = [1 1];
        end   
        
        %% INIfTI
        
        function        addImgrec(this, varargin)
            if (~ismethod(this.innerNIfTI_, 'addImgrec'))
                return
            end
            this.innerNIfTI_.addImgrec(varargin{:});
        end
        function        addLog(this, varargin)
            if (~ismethod(this.innerNIfTI_, 'addLog'))
                return
            end
            this.innerNIfTI_.addLog(varargin{:});
        end   
        function this = append_descrip(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.append_descrip(varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.prepend_descrip(varargin{:});
        end
        function d    = double(this)
            d = this.innerNIfTI_.double;
        end
        function d    = duration(this)
            d = this.innerNIfTI_.duration;
        end
        function this = append_fileprefix(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.append_fileprefix(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.prepend_fileprefix(varargin{:});
        end
        function f    = fov(this)
            f = this.innerNIfTI_.fov;
        end
        function        freeview(this, varargin)
            this.innerNIfTI_.freeview(varargin{:});
        end
        function e    = fslentropy(this)
            e = this.innerNIfTI_.fslentropy;
        end
        function E    = fslEntropy(this)
            E = this.innerNIfTI_.fslEntropy;
        end
        function        fsleyes(this, varargin)
            this.innerNIfTI_.fsleyes(varargin{:});
        end
        function        fslview(this, varargin)
            this.innerNIfTI_.fslview(varargin{:});
        end
        function        hist(this, varargin)
            this.innerNIfTI_.hist(varargin{:});
        end        
        function m    = matrixsize(this)
            m = this.innerNIfTI_.matrixsize;
        end
        function this = prod(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.prod(varargin{:});
        end
        function r    = rank(this, varargin)
            r = this.innerNIfTI_.rank(varargin{:});
        end
        function        save(this)
            this.innerNIfTI_.save;
        end
        function this = saveas(this, fqfn)
            this.innerNIfTI_ = this.innerNIfTI_.saveas(fqfn);
        end
        function this = scrubNanInf(this)
            this.innerNIfTI_ = this.innerNIfTI_.scrubNanInf;
        end
        function s    = single(this)
            s = this.innerNIfTI_.single;
        end
        function s    = size(this, varargin)
            s = this.innerNIfTI_.size(varargin{:});
        end
        function this = sum(this, varargin)
            this.innerNIfTI_ = this.innerNIfTI_.sum(varargin{:});
        end
        function fqfn = tempFqfilename(this)
            fqfn = this.innerNIfTI_.tempFqfilename;
        end
        function        view(this, varargin)
            this.innerNIfTI_.viewer = this.viewer;
            this.innerNIfTI_.view(varargin{:});
        end
        
        %% 
        
        function c    = char(this)
            c = this.innerNIfTI_.char;
        end
        function f    = false(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', 'false', @ischar);
            addOptional(p, 'fp',   [this.fileprefix '_false'], @ischar);
            parse(p, varargin{:});
            f = this.makeSimilar('img', false(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end  
        function tf   = isequal(this, obj)
            tf = this.isequaln(obj);
        end
        function tf   = isequaln(this, obj)
            tf = this.classesequal(obj);
            if (tf)
                tf = this.fieldsequaln(obj);
                if (tf)
                    tf = this.hdrsequaln(obj);
                end
            end
        end 
        function tf   = isscalar(this)
            tf = isscalar(this.img);
        end
        function tf   = isvector(this)
            tf = isvector(this.img);
        end   
        function tf   = lexist(this)
            tf = lexist(this.innerNIfTI_.fqfilename);
        end   
        function niid = makeSimilar(this, varargin)
            %% MAKESIMILAR 
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niid copy-construction with niid.descrip appended with 'made similar'.
            %  See also:  mlfourd.NIfTId.NIfTId
    
            niid = mlfourd.NIfTId(this, varargin{:});
            niid.addLog('made similar');
        end
        function o    = nan(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', 'nan', @ischar);
            addOptional(p, 'fp',   [this.fileprefix '_nan'], @ischar);
            parse(p, varargin{:});
            o = this.makeSimilar('img', nan(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end
        function o    = ones(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', 'ones', @ischar);
            addOptional(p, 'fp',   [this.fileprefix '_ones'], @ischar);
            parse(p, varargin{:});
            o = this.makeSimilar('img', ones(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end
        function t    = true(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', 'true', @ischar);
            addOptional(p, 'fp',   [this.fileprefix '_true'], @ischar);
            parse(p, varargin{:});
            t = this.makeSimilar('img', true(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end
        function z    = zeros(this, varargin)
            p = inputParser;
            addOptional(p, 'desc', 'zeros', @ischar);
            addOptional(p, 'fp',   [this.fileprefix '_zeros'],     @ischar);
            parse(p, varargin{:});
            z = this.makeSimilar('img', zeros(this.size), 'descrip', p.Results.desc, 'fileprefix', p.Results.fp);
        end   
    end
    
    %% PROTECTED
    
    methods (Access = protected)
        function [tf,msg] = classesequal(this, c)
            tf  = true; 
            msg = '';
            if (~isa(c, class(this)))
                tf  = false;
                msg = sprintf('AbstractNIfTIComponent.classesequal:  class(this)-> %s but class(compared)->%s', class(this), class(c));
                warning('mlfourd:mismatchedClass', msg); %#ok<SPWRN>
            end
        end
        function [tf,msg] = fieldsequaln(this, obj)
            [tf,msg] = mlfourd.AbstractNIfTIComponent.checkFields( ...
                this, obj, @(x) lstrfind(x, this.EQUALN_IGNORES));
        end
        function [tf,msg] = hdrsequaln(this, obj)
            tf = true; 
            msg = '';
            if (isempty(this.hdr) && isempty(obj.hdr)); return; end
            import mlfourd.*;
            [tf,msg] = AbstractNIfTIComponent.checkFields( ...
                this.hdr.hk, obj.hdr.hk,  @(x) lstrfind(x, this.EQUALN_IGNORES));
            if (tf)
                [tf,msg] = AbstractNIfTIComponent.checkFields( ...
                    this.hdr.dime, obj.hdr.dime, @(x) lstrfind(x, this.EQUALN_IGNORES));
                if (tf)
                    [tf,msg] = AbstractNIfTIComponent.checkFields( ...
                        this.hdr.hist, obj.hdr.hist, @(x) lstrfind(x, this.EQUALN_IGNORES));
                end
            end
        end      
 		function this = AbstractNIfTIComponent(inner)
            assert(isa(inner, 'mlfourd.INIfTI') || isa(inner, 'mlfourd.HandleINIfTI'));
            this.innerNIfTI_ = inner;
 		end
    end 
    
    properties (Access = protected)
        innerNIfTI_
    end
    
    %% HIDDEN    
    
    methods (Static, Hidden)
        function [tf,msg] = checkFields(obj1, obj2, evalIgnore)
            tf = true; 
            msg = '';
            flds = fieldnames(obj1);
            for f = 1:length(flds)
                if (~evalIgnore(flds{f}))
                    if (~isequaln(obj1.(flds{f}), obj2.(flds{f})))
                        tf = false;
                        msg = sprintf('AbstractNIfTIComponent.checkFields:  mismatch at field %s.', flds{f});
                        warning('mlfourd:mismatchedField', msg); %#ok<SPWRN>
                        if (strcmp(flds{f}, 'img'))
                            disp(size(obj1.img));
                            disp(size(obj2.img));
                            continue
                        end
                        disp(obj1.(flds{f}));
                        disp(obj2.(flds{f}));
                    end
                end
            end
        end 
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

