classdef ImagingFormatContext < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlfourd.HandleJimmyShenInterface & mlfourd.HandleINIfTI & mlio.HandleIOInterface
	%% IMAGINGFORMATCONTEXT and mlfourd.AbstractInnerImagingFormat together form a state design pattern.  Supported 
    %  states include mlfourd.InnerNIfTI, mlfourdfp.InnerFourdfp, mlsurfer.InnerMGH.  The state is configured by field  
    %  imagingInfo which is an mlfourd.{ImagingInfo,Analyze75Info,NIfTIInfo}, mlfourdfp.FourdfpInfo, mlsurfer.MGHInfo.  
    %  The different available states predominantly manage different imaging formats.  Altering property filesuffix is a
    %  convenient way to change states for formats.

	%  $Revision$
 	%  was created 24-Jul-2018 00:35:24 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
    
    properties (Constant)
        PREFERRED_EXT = '.nii.gz'
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
        N
        negentropy
        orient % RADIOLOGICAL, NEUROLOGICAL
        originator
        pixdim
        seriesNumber
        
        imagingInfo
        innerTypeclass
        logger
        separator % for descrip & label properties, not for filesystem behaviors
        stack
        viewer
    end
    
    methods (Static)
        function [tf,e] = supportedFileformExists(fn)
            %% SUPPORTEDFILEFORMEXISTS searches for an existing filename.  If not found it attempts to find 
            %  the same fileprefix with alternative extension for supported image formats:  drawn from
            %  {mlfourdfp.FourdfpInfo.SUPPORTED_EXT mlfourd.NIfTIInfo.SUPPORTED_EXT mlsurfer.MGHInfo.SUPPORTED_EXT},
            %  respecting their enumerated cardinality.
            %  @param fn is the filename queried.
            %  @return tf := filename or fileprefix with support image format found.
            %  @return e  := found image format expressed as file extension.            
            
            % ff exists
            if (lexist(fn, 'file'))
                tf = true;
                [~,~,e] = myfileparts(fn);
                return
            end
            
            % ff doesn't exist as an explicit file; check if there exists a variation of filesuffix           
            [p,f] = myfileparts(fn);
            e3s = mlfourdfp.FourdfpInfo.SUPPORTED_EXT;
            for ie = 1:length(e3s)
                if (lexist(fullfile(p, [f e3s{ie}]), 'file'))
                    tf = true;
                    e  = e3s{ie};
                    return
                end
            end
            e1s = mlfourd.NIfTIInfo.SUPPORTED_EXT;
            for ie = 1:length(e1s)
                if (lexist(fullfile(p, [f e1s{ie}]), 'file'))
                    tf = true;
                    e  = e1s{ie};
                    return
                end
            end
            e2s = mlsurfer.MGHInfo.SUPPORTED_EXT;
            for ie = 1:length(e2s)
                if (lexist(fullfile(p, [f e2s{ie}]), 'file'))
                    tf = true;
                    e  = e2s{ie};
                    return
                end
            end
            
            % ff and variants don't exist at all on the filesystem
            tf = false;         
            [~,~,e] = myfileparts(fn);
        end
    end
    
	methods 
        
        %% SET/GET
        
        function        set.filename(this, fn)
            this.innerImagingFormat_.filename = fn;
        end
        function fn   = get.filename(this)
            fn = this.innerImagingFormat_.filename;
        end
        function        set.filepath(this, pth)
            this.innerImagingFormat_.filepath = pth;
        end
        function pth  = get.filepath(this)
            pth = this.innerImagingFormat_.filepath;
        end
        function        set.fileprefix(this, fp)
            this.innerImagingFormat_.fileprefix = fp;
        end
        function fp   = get.fileprefix(this)
            fp = this.innerImagingFormat_.fileprefix;
        end
        function        set.filesuffix(this, fs)
            this.innerImagingFormat_.filesuffix = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.innerImagingFormat_.filesuffix;
        end        
        function        set.fqfilename(this, fqfn)
            this.innerImagingFormat_.fqfilename = fqfn;
        end
        function fqfn = get.fqfilename(this)
            fqfn = this.innerImagingFormat_.fqfilename;
        end
        function        set.fqfileprefix(this, fqfp)
            this.innerImagingFormat_.fqfileprefix = fqfp;
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = this.innerImagingFormat_.fqfileprefix;
        end
        function        set.fqfn(this, f)
            this.fqfilename = f;
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function        set.fqfp(this, f)
            this.fqfileprefix = f;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end        
        function        set.noclobber(this, nc)
            this.innerImagingFormat_.noclobber = nc;
        end            
        function nc   = get.noclobber(this)
            nc = this.innerImagingFormat_.noclobber;
        end    
        
        function e    = get.ext(this)
            e = this.innerImagingFormat_.ext;
        end
        function f    = get.filetype(this)
            f = this.innerImagingFormat_.filetype;
        end
        function h    = get.hdr(this)
            h = this.innerImagingFormat_.hdr;
        end 
        function        set.hdr(this, s)
            assert(isstruct(s))
            this.innerImagingFormat_.hdr = s;
        end        
        function im   = get.img(this)
            im = this.innerImagingFormat_.img;
        end        
        function        set.img(this, im)
            %% SET.IMG sets new image state. 
            %  @param im is numeric; it updates datatype, bitpix, dim
            
            this.innerImagingFormat_.img = im;
        end
        function o    = get.originalType(this)
            o = this.innerImagingFormat_.originalType_;
        end
        function u    = get.untouch(this)
            u = this.innerImagingFormat_.untouch;
        end
        
        function bp   = get.bitpix(this) 
            %% BIPPIX returns a datatype code as described by the INIfTI specificaitons
            
            bp = this.innerImagingFormat_.bitpix;
        end
        function        set.bitpix(this, bp) 
            this.innerImagingFormat_.bitpix = bp;
        end
        function cdat = get.creationDate(this)
            cdat = this.innerImagingFormat_.creationDate;
        end
        function dt   = get.datatype(this)
            %% DATATYPE returns a datatype code as described by the INIfTI specificaitons
            
            dt = this.innerImagingFormat_.datatype;
        end    
        function        set.datatype(this, dt)
            this.innerImagingFormat_.datatype = dt;
        end
        function d    = get.descrip(this)
            d = this.innerImagingFormat_.descrip;
        end        
        function        set.descrip(this, s)
            %% SET.DESCRIP
            %  do not add separators such as ";" or ","
            
            this.innerImagingFormat_.descrip = s;
        end   
        function E    = get.entropy(this)
            E = this.innerImagingFormat_.entropy;
        end
        function x    = get.hdxml(this)
            %% GET.HDXML writes the xml file if this objects exists on disk
            
            x = this.innerImagingFormat_.hdxml;
        end 
        function d    = get.label(this)
            d = this.innerImagingFormat_.label;
        end     
        function        set.label(this, s)
            this.innerImagingFormat_.label = s;
        end
        function ma   = get.machine(this)
            ma = this.innerImagingFormat_.machine;
        end
        function mpp  = get.mmppix(this)
            mpp = this.innerImagingFormat_.mmppix;
        end        
        function        set.mmppix(this, mpp)
            %% SET.MMPPIX sets voxel-time dimensions in mm, s.
            
            this.innerImagingFormat_.mmppix = mpp;
        end  
        function g    = get.N(this)
            g = this.innerImagingFormat_.N;
        end
        function        set.N(this, s)
            assert(islogical(s))
            this.innerImagingFormat_.N = s;
        end
        function E    = get.negentropy(this)
            E = this.innerImagingFormat_.negentropy;
        end
        function o    = get.orient(this)
            o = this.innerImagingFormat_.orient;
        end
        function o    = get.originator(this)
            o = this.innerImagingFormat_.originator;
        end        
        function        set.originator(this, o)
            %% SET.ORIGINATOR sets originator position in mm.
            
            this.innerImagingFormat_.originator = o;
        end  
        function pd   = get.pixdim(this)
            pd = this.innerImagingFormat_.pixdim;
        end        
        function        set.pixdim(this, pd)
            %% SET.PIXDIM sets voxel-time dimensions in mm, s.
            
            this.innerImagingFormat_.pixdim = pd;
        end  
        function num  = get.seriesNumber(this)
            num = this.innerImagingFormat_.seriesNumber;
        end
        
        function ii   = get.imagingInfo(this)
            ii = this.innerImagingFormat_.imagingInfo;
        end        
        function tc   = get.innerTypeclass(this)
            tc = class(this.innerImagingFormat_);
        end
        function im   = get.logger(this)
            im = this.innerImagingFormat_.logger;
        end
        function s    = get.separator(this)
            s = this.innerImagingFormat_.separator;
        end
        function        set.separator(this, s)
            this.innerImagingFormat_.separator = s;
        end
        function s    = get.stack(this)
            %% GET.STACK
            %  See also:  doc('dbstack')
            
            s = this.innerImagingFormat_.stack;
        end
        function v    = get.viewer(this)
            v = this.innerImagingFormat_.viewer;
        end
        function        set.viewer(this, v)
            this.innerImagingFormat_.viewer = v;
        end    
        
        %%
        
        function        addLog(this, varargin)
            inst = mlpipeline.PipelineRegistry.instance();
            if inst.verbose
                this.innerImagingFormat_.addLog(varargin{:});
            else
                this.innerImagingFormat_.addLogNoEcho(varargin{:});
            end
        end
        function c    = char(this, varargin)
            c = this.innerImagingFormat_.char(varargin{:});
        end
        function this = append_descrip(this, varargin)
            this.innerImagingFormat_ = this.innerImagingFormat_.append_descrip(varargin{:});
        end
        function this = prepend_descrip(this, varargin)
            this.innerImagingFormat_ = this.innerImagingFormat_.prepend_descrip(varargin{:});
        end
        function d    = double(this)
            d = this.innerImagingFormat_.double;
        end
        function d    = duration(this)
            d = this.innerImagingFormat_.duration;
        end
        function this = append_fileprefix(this, varargin)
            this.innerImagingFormat_ = this.innerImagingFormat_.append_fileprefix(varargin{:});
        end
        function this = prepend_fileprefix(this, varargin)
            this.innerImagingFormat_ = this.innerImagingFormat_.prepend_fileprefix(varargin{:});
        end
        function this = ensureDouble(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.ensureDouble;
        end
        function this = ensureSingle(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.ensureSingle;
        end
        function this = ensureUint8(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.ensureUint8;
        end
        function this = ensureInt16(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.ensureInt16;
        end
        function this = ensureInt32(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.ensureInt32;
        end
        function this = ensureInt64(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.ensureInt64;
        end
        function        export(this, varargin)
            %% supports .mat with conventions from Patrick Luckett
            %  @param required fqfilename.
            %  @param ndims is numeric.
            
            ip = inputParser;
            addRequired(ip, 'fqfilename', @ischar)
            addParameter(ip, 'ndims', 2, @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            if ~strcmp(this.innerTypeclass, 'mlfourdfp.InnerFourdfp')
                this.img = flip(this.img, 2);
            end
            switch ipr.ndims
                case 2
                    sz = size(this);
                    if length(sz) < 4
                        sz_ = sz;
                        sz = ones(1,4);
                        sz(1:length(sz_)) = sz_;
                    end
                    img = reshape(this.img, [prod(sz(1:3)) sz(4)]); %#ok<PROPLC>
                otherwise
                    error('mlfourd:RuntimeError', 'ImagingFormatContext.export.ipr.ndims->%g', ipr.ndims)
            end
            [~,~,x] = myfileparts(ipr.fqfilename);
            switch x
                case '.mat'
                    save(ipr.fqfilename, 'img');
                    clear('img')
                otherwise
                    error('mlfourd:RuntimeError', 'ImagingFormatContext.export.x->%s', x)
            end
        end
        function f    = fov(this)
            f = this.innerImagingFormat_.fov;
        end
        function        freeview(this, varargin)
            this.innerImagingFormat_.freeview(varargin{:});
        end
        function e    = fslentropy(this)
            e = this.innerImagingFormat_.fslentropy;
        end
        function E    = fslEntropy(this)
            E = this.innerImagingFormat_.fslEntropy;
        end
        function        fsleyes(this, varargin)
            this.innerImagingFormat_.fsleyes(varargin{:});
        end
        function        fslview(this, varargin)
            this.innerImagingFormat_.fslview(varargin{:});
        end
        function        hist(this, varargin)
            this.innerImagingFormat_.hist(varargin{:});
        end      
        function tf   = isempty(this)
            tf = isempty(this.innerImagingFormat_.img);
        end
        function tf   = lexist(this)
            tf = this.innerImagingFormat_.lexist;
        end
        function m    = matrixsize(this)
            m = this.innerImagingFormat_.matrixsize;
        end
        function this = mutateInnerImagingFormatByFilesuffix(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.mutateInnerImagingFormatByFilesuffix;
        end
        function n    = ndims(this, varargin)
            n = this.innerImagingFormat_.ndims(varargin{:});
        end
        function n    = numel(this, varargin)
            n = this.innerImagingFormat_.numel(varargin{:});
        end
        function this = optimizePrecision(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.optimizePrecision();
        end
        function this = prod(this, varargin)
            this.innerImagingFormat_ = this.innerImagingFormat_.prod(varargin{:});
        end
        function this = reset_scl(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.reset_scl;
        end
        function r    = rank(this, varargin)
            %% DEPRECATED; use ndims
            
            r = this.ndims(varargin{:});
        end
        function this = roi(this, varargin)
            this = this.zoom(varargin{:});
        end
        function        save(this)
            this.innerImagingFormat_.save;
        end
        function this = saveas(this, fqfn)
            this.innerImagingFormat_ = this.innerImagingFormat_.saveas(fqfn);
        end
        function this = scrubNanInf(this)
            this.innerImagingFormat_ = this.innerImagingFormat_.scrubNanInf;
        end
        function s    = single(this)
            s = this.innerImagingFormat_.single;
        end
        function s    = size(this, varargin)
            s = this.innerImagingFormat_.size(varargin{:});
        end
        function c    = string(this, varargin)
            c = this.innerImagingFormat_.string(varargin{:});
        end
        function this = sum(this, varargin)
            this.innerImagingFormat_ = this.innerImagingFormat_.sum(varargin{:});
        end
        function fqfn = tempFqfilename(this)
            fqfn = this.innerImagingFormat_.tempFqfilename;
        end
        function        view(this, varargin)
            %% VIEW 
            %  @return if this.img is vector, plot(this.img, varargin{:});
            %          else launch this.viewer with this.img and varargin.
            
            if (this.ndims < 3 && ...
                numel(this.img) == length(this.img))
                plot(this.img, varargin{:});
                return
            end
            this.innerImagingFormat_.viewer = this.viewer;
            this.innerImagingFormat_.view(varargin{:});
        end
        function this = zoom(this, varargin)
            this.innerImagingFormat_ = this.innerImagingFormat_.zoom(varargin{:});
        end
        
 		function this = ImagingFormatContext(varargin)
 			%% IMAGINGFORMATCONTEXT
 			%  @param obj must satisfy this.assertCtorObj; if char it must satisfy this.supportedFileformExists.
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  Valid param-names:  bitpix, datatype, descrip, ext, filename, filepath, fileprefix, filetype, fqfilename, 
            %  fqfileprefix, hdr, img, label, mmppix, noclobber, pixdim, separator.

            import mlfourd.*;            
            this.innerImagingFormat_ = ImagingFormatContext.createInner(varargin{:}); 
            
            ip = inputParser;
            addOptional( ip, 'obj',          [], @ImagingFormatContext.assertCtorObj);
            addParameter(ip, 'bitpix',       [], @isnumeric);
            addParameter(ip, 'datatype',     [], @(x) isnumeric(x) || ischar(x));
            addParameter(ip, 'descrip',      '', @ischar);
            addParameter(ip, 'ext',          []);
            addParameter(ip, 'filename',     '', @ischar);
            addParameter(ip, 'filepath',     '', @ischar);
            addParameter(ip, 'fileprefix',   '', @ischar);
            addParameter(ip, 'filetype',     [], @(x) isnumeric(x) && (isempty(x) || (x >= 0 && x <= 2)));
            addParameter(ip, 'fqfilename',   '', @ischar);
            addParameter(ip, 'fqfileprefix', '', @ischar);
            addParameter(ip, 'hdr',  struct([]), @isstruct);
            addParameter(ip, 'hist', struct([]), @isstruct);
            addParameter(ip, 'img',          [], @(x) isnumeric(x) || islogical(x));
            addParameter(ip, 'label',        '', @ischar);
            addParameter(ip, 'mmppix',       [], @isnumeric);
            addParameter(ip, 'noclobber',    []);
            addParameter(ip, 'originator',   [], @isnumeric);
            addParameter(ip, 'pixdim',       [], @isnumeric);
            addParameter(ip, 'separator',    '', @ischar);
            addParameter(ip, 'circshiftK', 0,    @isnumeric);                                    % see also mlfourd.ImagingInfo
            addParameter(ip, 'N', mlpipeline.ResourcesRegistry.instance().defaultN, @islogical); % 
            parse(ip, varargin{:});
            obj = ip.Results.obj;
            
            this.innerImagingFormat_.originalType_ = class(obj);
            if (isa(obj, 'mlfourd.ImagingFormatContext') || ...
                isa(obj, 'mlfourd.AbstractInnerImagingFormat') || ...
                isa(obj, 'mlfourd.ImagingInfo'))
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (ischar(obj)) % && ImagingFormatContext.supportedFileformExists(obj))
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlio.IOInterface') || isa(obj, 'mlio.HandleIOInterface'))
                assert(lexist(obj.fqfilename, 'file'), ...
                    'mlfourd:fileNotFound', 'ImagingFormatContext.ctor could not find %s', obj.fqfilename);
                this = ImagingFormatContext(obj.fqfilename);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isstruct(obj))
                %% base case for recursion using Jimmy Shen's mlniftitools
                this = this.adjustInnerNIfTIWithStruct(ip.Results.obj);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isnumeric(obj))
                this = this.adjustInnerNIfTIWithNumeric(obj);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlfourd.INIfTI')) 
                %% legacy support
                if (isa(obj, 'mlfourd.INIfTIdecorator'))
                    obj = obj.component;
                end
                warning('off', 'MATLAB:structOnObject');
                this = this.adjustInnerNIfTIWithStruct(struct(obj));
                this = this.adjustFieldsFromInputParser(ip);
                warning('on', 'MATLAB:structOnObject');
                return
            end
            error('mlfourd:unsupportedParamTypeclass', ...
                'class(ImagingFormatContext.ctor..obj) -> %s', class(obj));
 		end
    end 
    
    %% PROTECTED    
    
    properties (Access = protected)
        innerImagingFormat_
    end
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.innerImagingFormat_ = copy(this.innerImagingFormat_);
        end
    end
    
    %% PRIVATE    
    
    methods (Static, Access = private)
        function        assertCtorObj(obj)
            assert( ...
                isempty(obj) || ...
                isa(obj, 'mlfourd.ImagingFormatContext') || ...
                isa(obj, 'mlfourd.AbstractInnerImagingFormat') || ...
                isa(obj, 'mlfourd.ImagingInfo') || ...
                ischar(obj) ||  ...
                isa(obj, 'mlfourd.INIfTI') || ...
                isa(obj, 'mlio.IOInterface') || isa(obj, 'mlio.HandleIOInterface') || ...
                isstruct(obj) || ...
                isnumeric(obj), ...
                'mlfourd:invalidCtorParam', ...
                'ImagingFormatContext.assertCtorObj does not support an obj param with typeclass %s', class(obj));
        end
        function inn  = createInner(varargin)
            import mlfourd.* mlfourdfp.*;
            if (isempty(varargin))
                inn = InnerNIfTI(NIfTIInfo); % trivial
                return
            end
            if (1 == length(varargin))
                inn = ImagingFormatContext.createInner1(varargin{:});
                return
            end
            inn = ImagingFormatContext.createInner2(varargin{:});
        end            
        function inn  = createInner1(obj)
            import mlfourd.* mlfourdfp.* mlsurfer.*;     
            if (isa(obj, 'mlfourd.ImagingFormatContext'))
                inn = copy(obj.innerImagingFormat_); % copy ctor
                return
            end
            if (isa(obj, 'mlfourd.AbstractInnerImagingFormat'))
                inn = obj;
                return
            end
            if (isa(obj, 'mlfourd.ImagingInfo'))
                obj = obj.fqfilename;
            end
            if (ischar(obj))
                [~,~,e] = myfileparts(obj);            
                switch (e)
                    case FourdfpInfo.SUPPORTED_EXT
                        inn = InnerFourdfp(FourdfpInfo(obj));
                    case NIfTIInfo.SUPPORTED_EXT
                        inn = InnerNIfTI(NIfTIInfo(obj));
                    case mlsurfer.MGHInfo.SUPPORTED_EXT 
                        inn = InnerMGH(MGHInfo(obj));
                    case '.hdr'
                        inn = InnerNIfTI(Analyze75Info(obj));
                    otherwise
                        inn = ImagingFormatContext.createInner([myfileprefix(obj) ImagingFormatContext.PREFERRED_EXT]);
                end
                return
            end            
            
            % trivial
            inn = InnerNIfTI(NIfTIInfo);    
        end
        function inn  = createInner2(varargin)
            import mlfourd.* mlfourdfp.* mlsurfer.*;  
            obj = varargin{1};
            v_  = varargin(2:end);
            if (isa(obj, 'mlfourd.ImagingFormatContext'))
                inn = obj.innerImagingFormat_; % not copy ctor
                return
            end
            if (isa(obj, 'mlfourd.AbstractInnerImagingFormat'))
                inn = obj;
                return
            end
            if (isa(obj, 'mlfourd.ImagingInfo'))
                obj = obj.fqfilename;
            end
            if (ischar(obj))
                [~,~,e] = myfileparts(obj);            
                switch (e)
                    case FourdfpInfo.SUPPORTED_EXT
                        inn = InnerFourdfp(FourdfpInfo(obj, v_{:}), v_{:});
                    case NIfTIInfo.SUPPORTED_EXT
                        inn = InnerNIfTI(NIfTIInfo(obj, v_{:}), v_{:});
                    case MGHInfo.SUPPORTED_EXT 
                        inn = InnerMGH(MGHInfo(obj, v_{:}), v_{:});
                    case '.hdr'
                        inn = InnerNIfTI(Analyze75Info(obj, v_{:}), v_{:});
                    otherwise
                        inn = ImagingFormatContext.createInner([myfileprefix(obj) ImagingFormatContext.PREFERRED_EXT], v_{:});
                end
                return
            end
            
            % trivial
            inn = InnerNIfTI(NIfTIInfo);            
        end
    end

    methods (Access = private)
        function this = adjustFieldsFromInputParser(this, ip)
            %% ADJUSTFIELDSFROMINPUTPARSER updates this.innerImagingFormat_ with ip.Results from ctor.
            
            for p = 1:length(ip.Parameters)
                if (~ismember(ip.Parameters{p}, ip.UsingDefaults))
                    switch (ip.Parameters{p})
                        case 'circshiftK'
                        case 'descrip'
                            this.innerImagingFormat_ = this.innerImagingFormat_.append_descrip(ip.Results.descrip);
                        case 'hist'
                            this.innerImagingFormat_.hdr.hist = ip.Results.hist;
                        case 'N'
                            this.innerImagingFormat_.N = ip.Results.N;
                        case 'obj'
                        otherwise % adjust programmatically
                            this.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                    end
                end
            end
        end
        function this = adjustInnerNIfTIWithNumeric(this, num)
            lensize                                                   = length(size(num));
            this.innerImagingFormat_.img_                                     = num;
            this.innerImagingFormat_.imagingInfo.hdr.dime.pixdim(2:lensize+1) = ones(1,lensize);
            this.innerImagingFormat_.imagingInfo.hdr.dime.dim                 = ones(1,8);
            this.innerImagingFormat_.imagingInfo.hdr.dime.dim(1)              = lensize;
            this.innerImagingFormat_.imagingInfo.hdr.dime.dim(2:lensize+1)    = size(num);
            this.innerImagingFormat_.imagingInfo.hdr.dime.datatype            = 64;
            this.innerImagingFormat_.imagingInfo.hdr.dime.bitpix              = 64;
        end
        function this = adjustInnerNIfTIWithStruct(this, s)
            % as described by mlniftitools.load_untouch_nii
            this.innerImagingFormat_.hdr          = s.hdr;
            this.innerImagingFormat_.filetype     = s.filetype;
            this.innerImagingFormat_.fqfilename   = s.fileprefix; % Jimmy Shen's fileprefix includes filepath, filesuffix
            % this.innerImagingFormat_.machine is set at run-time
            if isfield(s, 'ext')
                this.innerImagingFormat_.ext      = s.ext;
            end
            this.innerImagingFormat_.img_         = s.img;
            if isfield(s, 'untouch')
                this.innerImagingFormat_.untouch  = s.untouch;
            end
        end
    end 
    
    %% HIDDEN
    
    methods (Hidden) 
        function g = getInnerImagingFormat(this)
            %% allows ImagingContext2 to import ImagingContext without accessing the filesystem.
            
            g = this.innerImagingFormat_;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

