classdef NIfTId < mlfourd.AbstractNIfTIComponent & mlfourd.INIfTId
    %% NIFTID specifies imaging data using img, fileprefix, hdr.hist.descrip, hdr.dime.pixdim as
    %  described by Jimmy Shen's entries at http://www.mathworks.com/matlabcentral/fileexchange/authors/20638.
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.    
 	 
 	
    properties (Constant) 
        FILETYPE      = 'NIFTI_GZ'
        FILETYPE_EXT  = '.nii.gz'
        NIFTI_EXT     = '.nii.gz'
        SUPPORTED_EXT = {'.nii.gz' '.nii'}
    end
    
    methods (Static) 
        function this = load(varargin)
            %% LOAD aliases the ctor.
            
            this = mlfourd.NIfTId(varargin{:});
        end 
    end 
    
    methods 
        function niid = clone(this, varargin)
            %% CLONE
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niid copy-construction with niid.descrip appended with 'clone'.
            %  See also:  mlfourd.NIfTId.NIfTId
            
            niid = mlfourd.NIfTId(this, varargin{:});
            niid = niid.append_descrip('cloned');
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
        function niid = makeSimilar(this, varargin)
            %% MAKESIMILAR 
            %  @param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  @return niid copy-construction with niid.descrip appended with 'made similar'.
            %  See also:  mlfourd.NIfTId.NIfTId
    
            niid = mlfourd.NIfTId(this, varargin{:});
            niid = niid.append_descrip('made similar');
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
        
        function this = NIfTId(varargin)
            %% NIfTId  
            %  @ param [obj] may be empty, a filename, numerical, INIfTI instantiation, struct compliant with 
            %  package mlniftitools; it constructs the class instance. 
            %  @ param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  Valid param-names:  bitpix, datatype, descrip, ext, filename, filepath, fileprefix,
            %  filetype, fqfilename, fqfileprefix, hdr, img, label, mmppix, noclobber, pixdim, separator.
            %  Param-name 'circshiftK' := 0 for 4dfp := nifti_4dfp(freesurfer)
            %  @ return this as a class instance.  Without arguments, this has default values.
            %  @ throws mlfourd:invalidCtorObj, mlfourd:fileTypeNotSupported, mlfourd:fileNotFound, mlfourd:unsupportedParamValue, 
            %  mlfourd:unknownSwitchCase, mlfourd:unsupportedDatatype, mfiles:unixException, MATLAB:assertion:failed.
            
            this = this@mlfourd.AbstractNIfTIComponent(mlfourd.InnerNIfTId);
            if (0 == nargin); return; end
            
            import mlfourd.*;
            ip = inputParser;
            addOptional( ip, 'obj',          [], @NIfTId.assertCtorObj); % compare to NIfTIc
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
            addParameter(ip, 'img',          [], @(x) isnumeric(x) || islogical(x));
            addParameter(ip, 'label',        '', @ischar);
            addParameter(ip, 'mmppix',       [], @isnumeric);
            addParameter(ip, 'noclobber',    []);
            addParameter(ip, 'pixdim',       [], @isnumeric);
            addParameter(ip, 'separator',    '', @ischar);
            addParameter(ip, 'circshiftK', 0,    @isnumeric); % see also mlfourd.ImagingInfo
            addParameter(ip, 'N', true,          @islogical); % 
            parse(ip, varargin{:});
            
            this.innerNIfTI_.originalType_ = class(ip.Results.obj);
            switch (class(ip.Results.obj))
                case 'char'
                    if (NIfTId.supportedFileformExists(ip.Results.obj))
                        this = NIfTId.load_existing( ...
                            ip.Results.obj, ...
                            'circshiftK', ip.Results.circshiftK, 'N', ip.Results.N, 'datatype', ip.Results.datatype);
                    else
                        [p,f] = myfileparts(ip.Results.obj);
                        this.fqfilename = fullfile(p, [f NIfTId.NIFTI_EXT]);
                        this = this.populateLogger;
                        this = this.adjustFieldsFromInputParser(ip);
                    end
                case 'struct' 
                    %% base case for recursion using Jimmy Shen's mlniftitools
                    this = this.adjustInnerNIfTI(ip.Results.obj);
                    this = this.populateLogger;
                    this = this.adjustFieldsFromInputParser(ip);
                case 'mlio.IOInterface'
                    this = NIfTId(ip.Results.obj.fqfilename);
                case 'mlfourd.INIfTId'
                    this = this.adjustInnerNIfTIWithINIfTId(ip.Results.obj);
                    this = this.populateLogger;
                    this = this.adjustFieldsFromInputParser(ip);
                case 'mlfourd.INIfTIc'
                    this = NIfTId(ip.Results.obj.get(1));
                case 'mlfourd.NIfTIInterface' 
                    %% legacy
                    warning('off', 'MATLAB:structOnObject');
                    this = NIfTId(struct(ip.Results.obj));
                    warning('on', 'MATLAB:structOnObject');
                otherwise
                    if (isnumeric(ip.Results.obj))
                        this = this.adjustInnerNIfTIWithNumeric(ip.Results.obj);
                        this = this.populateLogger;
                        this = this.adjustFieldsFromInputParser(ip);
                    else
                        error('mlfourd:unsupportedSwitchcase', ...
                            'class(NIfTId.ctor.ip.Results.obj) -> %s', class(ip.Results.obj));
                    end
            end
        end 
    end
    
    %% PRIVATE
 
    properties (Constant, Access = private)
        EQUALN_IGNORES = ...
            {'creationDate' 'descrip' 'hdr' 'hdxml' 'label' 'logger' 'originalType' 'regular' 'stack' 'untouch'}
    end
    
    methods (Static, Access = private)
        function        assertCtorObj(obj)
            assert( ...
                ischar(obj) || isstruct(obj) || isnumeric(obj) || ...
                isa(obj, 'mlio.IOInterface') || isa(obj, 'mlfourd.INIfTId') || isa(obj, 'mlfourd.INIfTIc') || ...
                isa(obj, 'mlfourd.NIfTIInterface'), ...
                'mlfourd:invalidCtorObj', ...
                'NIfTId.assertCtorObj does not support class(obj)->%s', class(obj));
        end
        function [tf,msg] = checkFields(obj1, obj2, evalIgnore)
            tf = true; 
            msg = '';
            flds = fieldnames(obj1);
            for f = 1:length(flds)
                if (~evalIgnore(flds{f}) && ~isequaln(obj1.(flds{f}), obj2.(flds{f})))
                    tf = false;
                    msg = sprintf('NIfTId.checkFields:  mismatch at field %s.', flds{f});
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
        function s    = FourdfpInfo2struct(fn, varargin)
            finfo = mlfourdfp.FourdfpInfo(fn, varargin{:});
            nii = finfo.make_nii;
            s = struct( ...
                'hdr', nii.hdr, ...
                'filetype', 2, ...
                'fileprefix', finfo.fileprefix, ...
                'machine', finfo.machine, ...
                'ext', [], ...
                'img', nii.img, ...
                'untouch', nii.untouch);  
            
            %% DEBUGGING
            %save_nii(nii, 'test.nii.gz');
            %system('fsleyes test.nii.gz');
        end
        function this = load_existing(fn, varargin)
            try
                import mlfourd.* mlfourdfp.*;
                e = NIfTId.selectExistingExtension(fn);
                if (lstrfind(e, NIfTId.SUPPORTED_EXT))
                    this = NIfTId.load_JimmyShen(fn, varargin{:});
                    this = this.adjustInnerNIfTIdAfterLoading(fn);
                    return
                end
                if (lstrfind(e, mlsurfer.MGH.SUPPORTED_EXT))
                    this = NIfTId.load_surfer(fn, varargin{:});
                    this = this.adjustInnerNIfTIdAfterLoading(fn);
                    return
                end
                if (lstrfind(e, Fourdfp.SUPPORTED_EXT))
                    this = NIfTId.load_4dfp(fn, varargin{:});
                    this = this.adjustInnerNIfTIdAfterLoading(fn);
                    return
                end
            catch ME
                handexcept(ME, ...
                    'mlfourd:fileNotFound', 'NIfTId.load_existing could not open fn->%s', fn);
            end
        end
        function this = load_4dfp(fn, varargin)

            %% NIFTI_4DFP
            % import mlfourd.* mlfourdfp.*;
            % [pth,fp] = myfileparts(fn);
            % fp2 = [fp '_' datestr(now,30)];
            % fn2 = fullfile(pth, [fp2 '.nii']);
            % visitor = FourdfpVisitor;
            % visitor.nifti_4dfp_n(fullfile(pth,fp), fullfile(pth, fp2));
            % this = NIfTId.load_JimmyShen(fn2);
            % this.fileprefix = fp;
            % deleteExisting(fn2);
            
            import mlfourd.*;
            [p,f] = myfileparts(fn);
            this = NIfTId( ...
                NIfTId.FourdfpInfo2struct(fullfile(p, [f '.4dfp.hdr']), varargin{:})); 
        end
        function this = load_JimmyShen(fn, varargin)
            %% makes recursive call to ctor with struct
            
            import mlfourd.*;
            this = NIfTId( ...
                NIfTId.NIfTIInfo2struct(fn, varargin{:})); % (mlniftitools.load_untouch_nii(fn));
            this.innerNIfTI_.fqfilename = fn;
        end
        function this = load_surfer(fn, varargin)
            import mlfourd.*;
            [p,f] = myfileparts(fn);
            fn2 = fullfile(p, [f '_' datestr(now,30) NIfTId.FILETYPE_EXT]); 
            mlbash(sprintf('mri_convert %s %s', fn, fn2));
            this = NIfTId.load_JimmyShen(fn2, varargin{:});
            this.fileprefix = f;
            deleteExisting(fn2);
        end
        function s    = NIfTIInfo2struct(fn, varargin)
            ninfo = mlfourd.NIfTIInfo(fn, varargin{:});
            nii = ninfo.make_nii;
            s = struct( ...
                'hdr', nii.hdr, ...
                'filetype', ninfo.filetype, ...
                'fileprefix', ninfo.fileprefix, ...
                'machine', ninfo.machine, ...
                'ext', ninfo.ext, ...
                'img', nii.img, ...
                'untouch', nii.untouch);
        end
        function e    = selectExistingExtension(fn)
            [~,~,e] = myfileparts(fn);
            if (lexist(fn, 'file') && ~isempty(e))
                return
            end
            if (isempty(e))
                dt = mlsystem.DirTool([fn '.*']);
                fns = dt.fns;
                for f = 1:length(fns)
                    if (lstrfind(fns{f}, mlfourd.NIfTId.SUPPORTED_EXT) || ...
                        lstrfind(fns{f}, mlsurfer.MGH.SUPPORTED_EXT) || ...
                        lstrfind(fns{f}, mlfourdfp.Fourdfp.SUPPORTED_EXT))
                        [~,~,e] = myfileparts(fns{f});
                        return
                    end
                end
            end
            error('mlfourd:IOError:fileNotFound', ...
                  'NIfTId.selectExistingExtension could not find %s', fn);
        end
        function tf   = supportedFileformExists(ff)
            tf = false;
            if (lexist(ff, 'file'))
                tf = true;
                return
            end
            [p,f] = myfileparts(ff);
            e1s = mlfourd.NIfTId.SUPPORTED_EXT;
            for e = 1:length(e1s)
                if (lexist(fullfile(p, [f e1s{e}]), 'file'))
                    tf = true;
                    return
                end
            end
            e2s = mlsurfer.MGH.SUPPORTED_EXT;
            for e = 1:length(e2s)
                if (lexist(fullfile(p, [f e2s{e}]), 'file'))
                    tf = true;
                    return
                end
            end
            e3s = mlfourdfp.Fourdfp.SUPPORTED_EXT;
            for e = 1:length(e3s)
                if (lexist(fullfile(p, [f e3s{e}]), 'file'))
                    tf = true;
                    return
                end
            end
        end
    end 
    
    methods (Access = private)
        function this     = adjustFieldsFromInputParser(this, ip)
            %% updates this.innerNIfTI_ with ip.Results from ctor
            
            if (isstruct(ip.Results.obj))
                return
            end
            for p = 1:length(ip.Parameters)
                if (~ismember(ip.Parameters{p}, ip.UsingDefaults))
                    switch (ip.Parameters{p})
                        case 'descrip'
                            this.innerNIfTI_ = this.innerNIfTI_.append_descrip(ip.Results.descrip);
                        case 'ext'
                            this.innerNIfTI_.ext_ = ip.Results.ext;
                        case 'hdr'
                            this.innerNIfTI_.hdr_ = ip.Results.hdr;
                        case 'img'
                            this.innerNIfTI_.img_ = ip.Results.img;
                        case 'obj'
                        case 'circshiftK'
                        case 'N'
                        otherwise
                            this.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                    end
                end
            end
        end
        function this     = adjustInnerNIfTI(this, obj)
            % as described by mlniftitools.load_untouch_nii
            this.innerNIfTI_.hdr_         = obj.hdr;
            this.innerNIfTI_.filetype_    = obj.filetype;
            this.innerNIfTI_.fqfileprefix = obj.fileprefix; % Jimmy Shen's fileprefix includes filepath
            this.innerNIfTI_.ext_         = obj.ext;
            this.innerNIfTI_.img_         = obj.img;
            this.innerNIfTI_.untouch_     = obj.untouch;
        end
        function this     = adjustInnerNIfTIdAfterLoading(this, fn)
            this.innerNIfTI_.orient_ = this.innerNIfTI_.orient; % caches results of fslorient
            lg = sprintf('NIfTId.adjustInnerNIfTIdAfterLoading read %s', fn);
            this.innerNIfTI_.hdr_.hist.descrip = lg;
            this.addLog(lg);
        end
        function this     = adjustInnerNIfTIWithINIfTId(this, obj)
            %% dedecorates
            this.innerNIfTI_.ext_         = obj.ext;
            this.innerNIfTI_.fqfileprefix = obj.fqfileprefix;
            this.innerNIfTI_.filetype_    = obj.filetype;
            this.innerNIfTI_.img_         = obj.img;
            this.innerNIfTI_.label        = obj.label;
            this.innerNIfTI_.noclobber    = obj.noclobber;
            this.innerNIfTI_.orient_      = obj.orient;
            this.innerNIfTI_.separator    = obj.separator;
            this.innerNIfTI_.untouch_     = obj.untouch;  
            this.innerNIfTI_.hdr_         = obj.hdr;
        end
        function this     = adjustInnerNIfTIWithNumeric(this, num)
            rank                                             = length(size(num));
            this.innerNIfTI_.img_                            = num;
            this.innerNIfTI_.hdr_.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
            this.innerNIfTI_.hdr_.dime.dim                   = ones(1,8);
            this.innerNIfTI_.hdr_.dime.dim(1)                = rank;
            this.innerNIfTI_.hdr_.dime.dim(2:rank+1)         = size(num);
            this.innerNIfTI_.hdr_.dime.datatype              = 64;
            this.innerNIfTI_.hdr_.dime.bitpix                = 64;
        end
        function [tf,msg] = classesequal(this, c)
            tf  = true; 
            msg = '';
            if (~isa(c, class(this)))
                tf  = false;
                msg = sprintf('NIfTId.classesequal:  class(this)-> %s but class(compared)->%s', class(this), class(c));
                warning('mlfourd:mismatchedClass', msg); %#ok<SPWRN>
            end
        end
        function [tf,msg] = fieldsequaln(this, obj)
            [tf,msg] = mlfourd.NIfTId.checkFields(this, obj, @(x) lstrfind(x, this.EQUALN_IGNORES));
        end
        function [tf,msg] = hdrsequaln(this, obj)
            tf = true; 
            msg = '';
            if (isempty(this.hdr) && isempty(obj.hdr)); return; end
            import mlfourd.*;
            [tf,msg] = NIfTId.checkFields(this.hdr.hk, obj.hdr.hk,  @(x) lstrfind(x, this.EQUALN_IGNORES));
            if (tf)
                [tf,msg] = NIfTId.checkFields(this.hdr.dime, obj.hdr.dime, @(x) lstrfind(x, this.EQUALN_IGNORES));
                if (tf)
                    [tf,msg] = NIfTId.checkFields(this.hdr.hist, obj.hdr.hist, @(x) lstrfind(x, this.EQUALN_IGNORES));
                end
            end
        end
        function this     = populateLogger(this)
            import mlpipeline.*;
            logfn  = [this.fqfileprefix mlpipeline.Logger.FILETYPE_EXT];
            this.innerNIfTI_.logger_ = Logger(logfn, this);
            if (~isempty(this.descrip))
                this.innerNIfTI_.addLog('Previous descrip:  %s', this.descrip);
            end            
            
%             imgrec = [this.fqfileprefix '.img.rec'];
%             if (lexist(imgrec, 'file'))
%                 c = mlsystem.FilesystemRegistry.textfileToCell(imgrec);
%                 this.innerNIfTI_.addLog(cell2str(c));
%             end
        end
    end 
    
end

