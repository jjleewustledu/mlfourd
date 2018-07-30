classdef NIfTIHeavy < mlfourd.NIfTIComponent
	%% NIFTIHEAVY is a data-heavy subclass of the concrete component of a decorator design pattern.

	%  $Revision$
 	%  was created 24-Jul-2018 00:35:24 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.

    properties (Constant)
        PREFERRED_EXT = '.4dfp.hdr'
    end
    
    methods (Static)
        function inn  = constructInner(obj, varargin)
            import mlfourd.*;
            if (~ischar(obj))
                inn = InnerNIfTId;
                return
            end
            
            [~,~,e] = myfileparts(obj);            
            switch (e)
                case mlfourdfp.FourdfpInfo.SUPPORTED_EXT
                    inn = mlfourdfp.InnerFourdfp( ...
                        mlfourdfp.FourdfpInfo(obj, varargin{:}), varargin{:});
                case NIfTIInfo.SUPPORTED_EXT
                    inn = InnerNIfTId( ...
                        NIfTIInfo(obj, varargin{:}), varargin{:});
                case mlsurfer.MGHInfo.SUPPORTED_EXT 
                    inn = mlsurfer.InnerMGH( ...
                        mlsurfer.MGHInfo(obj, varargin{:}), varargin{:});
                case '.hdr'
                    inn = InnerNIfTId( ...
                        Analyze75Info(obj, varargin{:}), varargin{:});
                otherwise
                    obj  = [myfileprefix(obj) NIfTIHeavy.PREFERRED_EXT];
                    inn = NIfTIHeavy.constructInner(obj, varargin{:});
            end
        end
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
 		function this = NIfTIHeavy(obj, varargin)
 			%% NIFTIHEAVY
 			%  @param .

            import mlfourd.*;
 			this = this@mlfourd.NIfTIComponent( ...
                NIfTIHeavy.constructInner(obj, varargin{:})); % nontrivial innerNIfTI_ only for obj is char.
            
            ip = inputParser;
            addOptional( ip, 'obj',          [], @NIfTIHeavy.assertCtorObj);
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
            parse(ip, obj, varargin{:});
            
            this.innerNIfTI_.originalType_ = class(obj);
            if (ischar(obj) && ...
                    NIfTIHeavy.supportedFileformExists(obj))
                % using nontrivial innerNIfTI_ from call to superclass
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlfourd.INIfTId'))
                this = NIfTIHeavy(obj, varargin{:}); % inf recursion?
                this = this.adjustFieldsFromInputParser(ip);
                return
            end
            if (isa(obj, 'mlio.IOInterface') || isa(obj, 'mlio.HandleIOInterface'))
                assert(lexist(obj.fqfilename, 'file'), ...
                    'mlfourd:fileNotFound', 'NIfTIHeavy.ctor could not find %s', obj.fqfilename);
                this = NIfTIHeavy(obj.fqfilename);
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
            error('mlfourd:unsupportedParamTypeclass', ...
                'class(NIfTIHeavy.ctor..obj) -> %s', class(obj));
 		end
    end 
    
    %% PRIVATE    
    
    methods (Static, Access = private)        
        function assertCtorObj(obj)
            assert( ...
                ischar(obj) ||  ...
                isa(obj, 'mlio.IOInterface') || isa(obj, 'mlio.HandleIOInterface') || ...
                isnumeric(obj) || ...
                isstruct(obj), ...
                'mlfourd:invalidCtorParam', ...
                'NIfTIHeavy.assertCtorObj does not support an obj param with typeclass %s', class(obj));
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
                            this.innerNIfTI_.hdr = ip.Results.hdr;
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
            % mlsystem.FilesystemRegistry is a singleton design pattern
            this.innerNIfTI_.imagingInfo = mlfourd.NIfTIInfo(obj.fqfilename, varargin{:});
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

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

