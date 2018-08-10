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
        SUPPORTED_EXT = {'.nii' '.nii.gz'}
    end
    
    methods (Static)
        function inn  = createInner(varargin)
            import mlfourd.* mlfourdfp.*;
            if (isempty(varargin))
                inn = InnerFourdfp(FourdfpInfo);
                return
            end
            if (1 == length(varargin))
                inn = NIfTId.createInner1(varargin{:});
                return
            end
            inn = NIfTId.createInner2(varargin{:});
        end
        function inn  = createInner1(obj)   
            import mlfourd.* mlfourdfp.* mlsurfer.*;         
            if (~ischar(obj))
                inn = InnerFourdfp(FourdfpInfo);
                return
            end
            
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
                    inn = NIfTId.createInner([myfileprefix(obj) NIfTId.NIFTI_EXT]);
            end
        end
        function inn  = createInner2(varargin)
            import mlfourd.* mlfourdfp.* mlsurfer.*;  
            obj = varargin{1};
            v_  = varargin(2:end);
            if (~ischar(obj))
                inn = InnerNIfTI(FourdfpInfo);
                return
            end
            
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
                    inn = NIfTId.createInner([myfileprefix(obj) NIfTId.NIFTI_EXT], v_{:});
            end
        end
        function this = load(fn, varargin)
            %% LOAD is a factory method having homology with decorators of NIfTId.
            
            this = mlfourd.NIfTId(fn, varargin{:});
        end 
        function [tf,e] = supportedFileformExists(fn)
            %% SUPPORTEDFILEFORMEXISTS searches for an existing filename.  If not found it attempts to find 
            %  the same fileprefix with alternative extension for supported image formats:  drawn from
            %  {mlfourdfp.Fourdfp.SUPPORTED_EXT mlfourd.NIfTId.SUPPORTED_EXT mlsurfer.MGH.SUPPORTED_EXT},
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
            e3s = mlfourdfp.Fourdfp.SUPPORTED_EXT;
            for ie = 1:length(e3s)
                if (lexist(fullfile(p, [f e3s{ie}]), 'file'))
                    tf = true;
                    e  = e3s{ie};
                    return
                end
            end
            e1s = mlfourd.NIfTId.SUPPORTED_EXT;
            for ie = 1:length(e1s)
                if (lexist(fullfile(p, [f e1s{ie}]), 'file'))
                    tf = true;
                    e  = e1s{ie};
                    return
                end
            end
            e2s = mlsurfer.MGH.SUPPORTED_EXT;
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
            
            import mlfourd.*;
            this = this@mlfourd.AbstractNIfTIComponent( ...
                NIfTId.createInner(varargin{:}));
            
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
            addParameter(ip, 'imagingInfo',  [], @(x) isa(x, 'mlfourd.ImagingInfo') || isempty(x));
            parse(ip, varargin{:});
            
            this.innerNIfTI_.originalType_ = class(ip.Results.obj);
            switch (class(ip.Results.obj))
                case 'char'
                    if (NIfTId.supportedFileformExists(ip.Results.obj))
                        this = NIfTId(this.innerNIfTI_.asStruct);
                        this = this.adjustFieldsFromInputParser(ip);
                    end
                case 'struct' 
                    %% base case for recursion using Jimmy Shen's mlniftitools
                    this = this.adjustInnerNIfTIWithStruct(ip.Results.obj);
                otherwise
                    if (isa(ip.Results.obj, 'mlfourd.INIfTId'))
                        this = this.adjustInnerNIfTIWithINIfTId(ip.Results.obj);
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (isa(ip.Results.obj, 'mlfourd.INIfTIc'))
                        this = NIfTId(ip.Results.obj.get(1));
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (isa(ip.Results.obj, 'mlfourd.NIfTIInterface'))
                        %% legacy support of deprecated NIfTIInterface
                        warning('off', 'MATLAB:structOnObject');
                        this = NIfTId(struct(ip.Results.obj));
                        this = this.adjustFieldsFromInputParser(ip);
                        warning('on', 'MATLAB:structOnObject');
                        return
                    end
                    if (isa(ip.Results.obj, 'mlio.IOInterface'))
                        this = NIfTId(ip.Results.obj.fqfilename);
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    if (isnumeric(ip.Results.obj))
                        this = this.adjustInnerNIfTIWithNumeric(ip.Results.obj);
                        this = this.adjustFieldsFromInputParser(ip);
                        return
                    end
                    error('mlfourd:unsupportedSwitchcase', ...
                        'class(NIfTId.ctor.ip.Results.obj) -> %s', class(ip.Results.obj));
            end
            this = this.adjustFieldsFromInputParser(ip);
        end 
    end
    
    %% PRIVATE
    
    methods (Static, Access = private)
        function        assertCtorObj(obj)
            assert( ...
                ischar(obj) || isstruct(obj) || isnumeric(obj) || ...
                isa(obj, 'mlio.IOInterface') || isa(obj, 'mlfourd.INIfTId') || isa(obj, 'mlfourd.INIfTIc') || ...
                isa(obj, 'mlfourd.NIfTIInterface'), ...
                'mlfourd:invalidCtorObj', ...
                'NIfTId.assertCtorObj does not support class(obj)->%s', class(obj));
        end
        function this = load_4dfp(fn, varargin)

            %% NIFTI_4DFP:  legacy implementation using nifti_4dfp
            import mlfourd.* mlfourdfp.*;
            [pth,fp] = myfileparts(fn);
            fp2 = [fp '_' datestr(now,30)];
            fn2 = fullfile(pth, [fp2 '.nii']);
            visitor = FourdfpVisitor;
            visitor.nifti_4dfp_n(fullfile(pth,fp), fullfile(pth, fp2));
            this = NIfTId.load_JimmyShen(fn2);
            this.fileprefix = fp;
            deleteExisting(fn2);
            
            %import mlfourd.* mlfourdfp.*;
            %this = NIfTId(InnerFourdfp.imagingInfo2struct(fn, varargin{:}));
        end
    end 
    
    methods (Access = private)
        function this     = adjustFieldsFromInputParser(this, ip)
            %% ADJUSTFIELDSFROMINPUTPARSER updates this.innerNIfTI_ with ip.Results from ctor.
            
            for p = 1:length(ip.Parameters)
                if (~ismember(ip.Parameters{p}, ip.UsingDefaults))
                    switch (ip.Parameters{p})
                        case 'datatype'
                        case 'descrip'
                            this.innerNIfTI_ = this.innerNIfTI_.append_descrip(ip.Results.descrip);
                        case 'ext'
                            this.innerNIfTI_.ext = ip.Results.ext;
                        case 'hdr'
                            this.innerNIfTI_.imagingInfo.hdr = ip.Results.hdr;
                        case 'img'
                            this.innerNIfTI_.img_ = ip.Results.img;
                        case 'obj'
                        case 'circshiftK'
                        case 'N'
                        case 'imagingInfo'
                            this.innerNIfTI_.imagingInfo = ip.Results.imagingInfo;
                        otherwise
                            this.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                    end
                end
            end
        end
        function this     = adjustInnerNIfTIWithStruct(this, s)
            % as described by mlniftitools.load_untouch_nii
            this.innerNIfTI_.hdr          = s.hdr;
            this.innerNIfTI_.filetype     = s.filetype;
            this.innerNIfTI_.fqfilename   = s.fileprefix; % Jimmy Shen's fileprefix includes filepath, filesuffix
            this.innerNIfTI_.ext          = s.ext;
            this.innerNIfTI_.img_         = s.img;
            this.innerNIfTI_.untouch      = s.untouch;
        end
        function this     = adjustInnerNIfTIWithINIfTId(this, obj)
            %% dedecorates
            this.innerNIfTI_.ext          = obj.innerNIfTI_.ext;
            this.innerNIfTI_.fqfileprefix = obj.fqfileprefix;
            this.innerNIfTI_.filetype     = obj.innerNIfTI_.filetype;
            this.innerNIfTI_.img_         = obj.img;
            this.innerNIfTI_.label        = obj.label;
            this.innerNIfTI_.noclobber    = obj.noclobber;
            this.innerNIfTI_.orient_      = obj.orient;
            this.innerNIfTI_.separator    = obj.separator;
            this.innerNIfTI_.untouch      = obj.untouch;  
            this.innerNIfTI_.hdr          = obj.hdr;
        end
        function this     = adjustInnerNIfTIWithNumeric(this, num)
            rank                                            = length(size(num));
            this.innerNIfTI_.img_                           = num;
            this.innerNIfTI_.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
            this.innerNIfTI_.hdr.dime.dim                   = ones(1,8);
            this.innerNIfTI_.hdr.dime.dim(1)                = rank;
            this.innerNIfTI_.hdr.dime.dim(2:rank+1)         = size(num);
            this.innerNIfTI_.hdr.dime.datatype              = 64;
            this.innerNIfTI_.hdr.dime.bitpix                = 64;
        end
    end 
    
end

