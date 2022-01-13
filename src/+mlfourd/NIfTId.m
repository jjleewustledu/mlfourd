classdef NIfTId < mlfourd.AbstractNIfTIComponent & mlfourd.JimmyShenInterface & mlfourd.INIfTId & mlio.IOInterface
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
        PREFERRED_EXT = '.nii.gz'
    end
    
    methods (Static)
        function this = load(varargin)
            this = mlfourd.NIfTId(varargin{:});
        end 
        function [tf,e] = supportedFileformExists(fn)
            %% SUPPORTEDFILEFORMEXISTS searches for an existing filename.  If not found it attempts to find 
            %  the same fileprefix with alternative extension for supported image formats:  drawn from
            %  {mlfourd.FourdfpInfo.SUPPORTED_EXT mlfourd.NIfTIInfo.SUPPORTED_EXT mlfourd.MGHInfo.SUPPORTED_EXT},
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
            e3s = mlfourd.FourdfpInfo.SUPPORTED_EXT;
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
            e2s = mlfourd.MGHInfo.SUPPORTED_EXT;
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
        
        function this = NIfTId(varargin)
            %% NIfTId  
            %  @ param [obj] may be empty, a filename, numerical, INIfTI instantiation, struct compliant with 
            %  package mlniftitools; it constructs the class instance. 
            %  @ param [param-name, param-value[, ...]] allow adjusting public fields at creation.
            %  Valid param-names:  bitpix, datatype, descrip, ext, filename, filepath, fileprefix,
            %  filetype, fqfilename, fqfileprefix, hdr, img, label, mmppix, noclobber, pixdim, separator.
            %  @ return this as a class instance.  Without arguments, this has default values.
            %  @ throws mlfourd:invalidCtorObj, mlfourd:fileTypeNotSupported, mlfourd:fileNotFound, mlfourd:unsupportedParamValue, 
            %  mlfourd:unknownSwitchCase, mlfourd:unsupportedDatatype, mfiles:unixException, MATLAB:assertion:failed.
            
            import mlfourd.*;
            this = this@mlfourd.AbstractNIfTIComponent(NIfTId.createInner(varargin{:}));
            
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
            obj = ip.Results.obj;
            
            this.innerNIfTI_.originalType_ = class(obj);
            if (isa(obj, 'mlfourd.INIfTId'))
                this = this.adjustInnerNIfTIWithINIfTId(obj);
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlfourd.INIfTIc'))
                this = this.adjustInnerNIfTIWithINIfTId(obj.get(1));
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlfourd.ImagingFormatContext') || ...
                isa(obj, 'mlfourd.AbstractInnerImagingFormat') || ...
                isa(obj, 'mlfourd.ImagingInfo'))
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (ischar(obj) && ...
                NIfTId.supportedFileformExists(obj))
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlio.IOInterface'))
                assert(lexist(obj.fqfilename, 'file'), ...
                    'mlfourd:fileNotFound', 'NIfTId.ctor could not find %s', obj.fqfilename);
                this = NIfTId(obj.fqfilename);
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
        end
        function that = clone(this, varargin)
            that = mlfourd.NIfTId(this, varargin{:});
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
                isa(obj, 'mlfourd.INIfTId')  || isa(obj, 'mlfourd.INIfTIc') || ...
                isa(obj, 'mlio.IOInterface') || ...
                isstruct(obj) || ...
                isnumeric(obj), ...                
                'mlfourd:invalidCtorObj', ...
                'NIfTId.assertCtorObj does not support an obj param with typeclass %s', class(obj));
        end
        function inn  = createInner(varargin)
            import mlfourd.* mlfourdfp.*;
            if (isempty(varargin))
                inn = InnerNIfTI(NIfTIInfo);
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
            if (isa(obj, 'mlfourd.NIfTId'))
                inn = copy(obj.innerNIfTI_); % copy ctor
                return
            end
            if (isa(obj, 'mlfourd.ImagingFormatContext'))
                obj = obj.getInnerImagingFormat;
            end
            if (isa(obj, 'mlfourd.AbstractInnerImagingFormat'))
                inn = obj;
                return
            end
            if (isa(obj, 'mlfourd.ImagingInfo'))
                inn = InnerNIfTI(obj);
                return
            end
            if (ischar(obj))
                [~,~,e] = myfileparts(obj);            
                switch (e)
                    case FourdfpInfo.SUPPORTED_EXT
                        inn = InnerFourdfp(FourdfpInfo(obj));
                    case NIfTIInfo.SUPPORTED_EXT
                        inn = InnerNIfTI(NIfTIInfo(obj));
                    case mlfourd.MGHInfo.SUPPORTED_EXT 
                        inn = InnerMGH(MGHInfo(obj));
                    case '.hdr'
                        inn = InnerNIfTI(Analyze75Info(obj));
                    otherwise
                        inn = NIfTId.createInner([myfileprefix(obj) NIfTId.PREFERRED_EXT]);
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
            if (isa(obj, 'mlfourd.NIfTId'))
                inn = obj.innerNIfTI_; 
                return
            end
            if (isa(obj, 'mlfourd.ImagingFormatContext'))
                obj = obj.getInnerImagingFormat;
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
                        otherwise
                            this.(ip.Parameters{p}) = ip.Results.(ip.Parameters{p});
                    end
                end
            end
        end
        function this     = adjustInnerNIfTIWithINIfTId(this, obj, varargin)
            %% dedecorates
            
            this.innerNIfTI_.creationDate_ = obj.creationDate;
            this.innerNIfTI_.img_ = obj.img;
            this.innerNIfTI_.label_ = obj.label;
            this.innerNIfTI_.logger_ = obj.logger;
            this.innerNIfTI_.orient_ = obj.orient;
            this.innerNIfTI_.originalType_ = obj.originalType;
            this.innerNIfTI_.seriesNumber_ = obj.seriesNumber;
            this.innerNIfTI_.separator_ = ';';
            this.innerNIfTI_.stack_ = obj.stack;
            this.innerNIfTI_.viewer = obj.viewer;
            % mlio.FilesystemRegistry is a singleton design pattern
            this.innerNIfTI_.imagingInfo = obj.imagingInfo;
        end
        function this     = adjustInnerNIfTIWithNumeric(this, num)
            rank                                                        = length(size(num));
            this.innerNIfTI_.img_                                       = num;
            this.innerNIfTI_.imagingInfo.hdr.dime.pixdim(2:this.rank+1) = ones(1,this.rank);
            this.innerNIfTI_.imagingInfo.hdr.dime.dim                   = ones(1,8);
            this.innerNIfTI_.imagingInfo.hdr.dime.dim(1)                = rank;
            this.innerNIfTI_.imagingInfo.hdr.dime.dim(2:rank+1)         = size(num);
            this.innerNIfTI_.imagingInfo.hdr.dime.datatype              = 64;
            this.innerNIfTI_.imagingInfo.hdr.dime.bitpix                = 64;
        end
        function this     = adjustInnerNIfTIWithStruct(this, s)
            % as described by mlniftitools.load_untouch_nii
            this.innerNIfTI_.hdr          = s.hdr;
            this.innerNIfTI_.filetype     = s.filetype;
            this.innerNIfTI_.fqfilename   = s.fileprefix; % Jimmy Shen's fileprefix includes filepath, filesuffix
            % this.innerNIfTI_.machine is set at run-time
            this.innerNIfTI_.ext          = s.ext;
            this.innerNIfTI_.img_         = s.img;
            this.innerNIfTI_.untouch      = s.untouch;
        end
    end 
    
end

