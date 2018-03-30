classdef (Sealed) Np797Registry < mlfourd.FslRegistry
    
    %% NP797REGISTRY is a wrapper for simple database queries.
    %
    %  Instantiation:  instance = mlfourd.DBase.getInstance;
    %                  info     = instance.getter_info(param0, param1, ...)
    %                  info     = instance.macro(macro_name)
    %                  sqlout   = instance.sql(cmd)
    %
    %                  instance:     singleton instance
    %                  info:         data object
    %                  getter_info:  convenience getter
    %                  macro:        convenience macro
    %
    %  Singleton design pattern after the GoF and Petr Posik; cf. 
    %  http://www.mathworks.de/matlabcentral/newsreader/view_thread/170056
    %  Revised according to Matlab R2008b help topic "Controlling the Number of Instances"
    %
    %  Created by John Lee on 2009-02-15.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to <email="bugs.perfusion.neuroimage.wustl.edu@gmail.com"/>.
    
    properties

        orientationFlips  = struct('pet','y',  'ase','z',      'ep2d','',    'asl','',    'flair','');
        aseFileprefixes   = {'ase_rot'   'ase2nd_rot'};
        aslFileprefixes   = {'pasl_rot'  'paslmoco_rot'  'pwPasl_rot'  'cbfPasl_rot' ...
                             'pasl2_rot' 'paslmoco2_rot' 'pwPasl2_rot' 'cbfPasl2_rot'};
                         
        timeseriesPattern = {'ep2d', 'pasl', 'pcasl', 'ase'};
        petTracers        = {'ho' 'oo' 'oc'};
        petTries          = {'' '2' '3' '4'}; % reasonablel kludge
         
        iscomparator        = false;
        whiteMatterAverage  = false;
        rescaleWhiteMatter  = false;
        assumedWhiteAverage = 22;
        confidenceInterval  = 95;
    end
    
    properties (Dependent)
        preferDatatype
        dcmFolders
    end
    
    properties (Access = 'private')
        bookendsFolder = 'qCBF';
        useQBOLD       = false; 
    end
    
    methods
        
        %% Dependent setters, getters
        
        function        set.preferDatatype(this, dt)
            assert(~isempty(strfind(numeric_types, lower(dt))));
            this.extFileParts_.preferDatatype = dt;
        end
        
        function dt   = get.preferDatatype(this)
            dt = this.extFileParts_.preferDatatype;
        end
        
        function flds = get.dcmFolders(this)
            flds = this.extFileParts_.dcmFolders;
        end
        
        %% Non-dependent methods
        
        function of   = get.orientationFlips(this)
            assert(isstruct(this.orientationFlips_) && ~isempty(this.orientationFlips_));
            of        =     this.orientationFlips_;
        end
        
        function        set.orientationFlips(this, of)
            assert(isstruct(of) && ~isempty(of));
            this.orientationFlips = of;
        end        

        function fnam = betted(this, fnam)
            
            %% BETTED is a convenience wrapper
            import mlfsl.*;
            [~,f, e] =  filepartsx(fnam, mlfourd.INIfTI.FILETYPE_EXT);
                fnam = [BetBuilder.BET_PREFIX f BetBuilder.BET_SUFFIX e];
        end
 
		function tf   = hasFsl(this)
			tf = (7 == exist(fullfile(this.patientPath, 'fsl'), 'dir'));
        end        
        
        function ff   = fileForms(this, varargin)
            ff = this.extFileParts_.fileForms(varargin{:});
        end
        
        
        
 
        
        
        %% TODO:  refactor
        
        function fn   = jessy_filename(this, tag)
            
            %% JESSY_FILENAME  
            %  Usage:  filename = obj.jessy_filename(tag)
            %                                        ^ pid or bool
            %                                          bool==true -> return fully qualified filename
            if (2 == nargin)
                switch (class(tag))
                    case {'logical' numeric_types}
                        isfq = logical(tag);
                        fn   = this.extFileParts_.jessyFileMap(this.pid);
                    case 'char'
                        isfq = true;
                        fn   = this.extFileParts_.jessyFileMap(mlfsl.Np797Registry.ensurePnum(tag));
                    otherwise
                        isfq = true;
                end
            else
                isfq = true;
                fn   = this.extFileParts_.jessyFileMap(this.pid);
            end                
            if (isfq); fn = fullfile(this.mrPath, this.bookendsFolder, fn); end
        end % jessy_filename
    
        function pth  = hdrinfo_path(this, pid)
            
            %% HDRINFO_PATH
            %
            if (nargin > 1); this.pid = mlfourd.Np797Registry.ensurePnum(pid); end
            pth = fullfile(this.patientPath, 'ECAT_EXACT', 'hdr_backup','');
        end % hdrinfo_path

        function fn   = hdrinfo_filename(this, tracer, isfq)
            
            %% HDRINFO_FILENAME
            %  Usage:  fn = mlfourd.DBase.hdrinfo_filename(tracer, isfq)
            %          isfq:  bool true -> return fully qualified filename
            %
            if (nargin < 3); isfq = true; end
            if (nargin < 2); tracer = 'ho1'; end
            switch (tracer)
            case {'ho','ho1','ho2'}
                fn = [this.pid tracer '_g3.hdr.info'];
            case {'oc','oc1','oc2'}
                fn = [this.pid tracer '_g3.hdr.info'];
            case {'oo','oo1','oo2'}
                fn = [this.pid tracer '_g3.hdr.info'];
            case {'ho1_g3',  'ho2_g3',  'oc1_g3',  'oc2_g3',     'oo1_g3',     'oo2_g3',...
                  'ho1_rot', 'oo1_rot', 'oc1_rot', 'ho1_rot_g3', 'oo1_rot_g3', 'oc1_rot_g3', ...
                  'ho2_rot', 'oo2_rot', 'oc2_rot', 'ho2_rot_g3', 'oo2_rot_g3', 'oc2_rot_g3'}
                fn = [this.pid tracer '.hdr.info'];
            otherwise
                error('mlfourd:InternalStateErr', ...
                     ['DBase.hdrinfo_filename:  could not recognize tracer->' tracer]);
            end
            if (isfq); fn = fullfile(this.hdrinfo_path, fn); end
        end % hdrinfo_filename

        function fn  = oldFilename(this, fh, isfq, isblk, isblr)
            
            %% OLDFILENAME
            %  Usage:  filename = obj.oldFilename(func-handle, is-fq, is-block, is-blur)
            blksuf0 = this.useBlockSuffix;
            blrsuf0 = this.useBlurSuffix;
            switch (nargin)
                case {0,1}
                    error('mlfourd:InsufficientParams', 'DBase.t1_filename.nargin->%i\n', nargin);
                case 2
                    isfq = true;
                case 3
                case 4
                    this.useBlockSuffix = isblk;
                otherwise
                    this.useBlockSuffix = isblk;
                    this.useBlurSuffix  = isblr;
            end
            if (isfq)
                fn = fh(fullfile(this.patientPath, 'fsl'));
            else
                fn = fh;
            end
            this.useBlockSuffix = blksuf0;
            this.useBlurSuffix  = blrsuf0;
        end % oldFilename  
        
        function fn  = t1_filename(this, isfq, isblk, isblr)
            
            %% T1_FILENAME
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            fh = @this.t1_fn;
            switch (nargin)
                case 1
                    fn = this.oldFilename(fh);
                case 2
                    fn = this.oldFilename(fh, isfq);
                case 3
                    fn = this.oldFilename(fh, isfq, isblk);
                otherwise
                    fn = this.oldFilename(fh, isfq, isblk, isblr);
            end
        end

        function fn  = epi_filename(this, isfq)
            
            %% EPI_FILENAME
            %  isfq:  bool true -> return fully qualified filename
            % 
            if (nargin < 2); isfq = 1; end

            fn = ['b' this.ep2d this.extFileParts_.mcfMeanvolSuff];
            
            switch (double(isfq))
                case 1
                    fn = fullfilename(this.epi_path, [fn this.onRefSuffix]);
                case 0
                    fn =                             [fn this.onRefSuffix mlfourd.INIfTI.FILETYPE_EXT];
                otherwise
            end
        end % epi_filename

        function pth = fg_path(this, pid)
            
            %% FG_PATH
            %  Usage:  id:  string to identify patient, e.g., 'p5777' or 'vc4437'.  Updates this.pid.  Optional.
            %
			if (nargin > 1); this.pid = mlfourd.Np797Registry.ensurePnum(pid); end
            pth = this.roi_path(this.pid);
        end % fg_path
                 
        function fn  = fg_filename(this, isfq, isblk, isblr)
            
            %% FG_FILENAME 
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq  = 1; end
            if (nargin < 3); isblk = false; end
            if (nargin < 4); isblr = false; end

            if (this.useQBOLD)
                fstem = 'mask';
            else
                fstem = 'bt1_rot_mask';
            end
            fn = [fstem this.averagingSuffixes];

            switch (double(isfq))
                case 1
                    fn = fullfilename(this.fg_path, fn);
                case 0
                    fn =                        filename(fn);
                otherwise
            end
        end % fg_filename
        
        function fn  = seg_filename(this, filestem)

            if (1 == nargin); filestem = 'newseg'; end
            fn = fullfile(this.patientPath, [filestem '_' this.pid '.hdr']);
        end
        
        function fn  = art_filename(this, isfq, isblocked)
            
            %% ART_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = 1; end
            if (nargin < 3); isblocked = false; end
            fn = ['arteries' this.averagingSuffixes];
            switch (double(isfq))
                case 1
                    fn = fullfilename(this.roi_path, fn);
                case 0
                    fn =                         filename(fn);
                otherwise
            end
        end % art_filename
        		
        function fn  = csf_filename(this, isfq, isblocked)
            
            %% CSF_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = 1; end
            if (nargin < 3); isblocked = false; end
            fn = ['rois_seg_csf' this.onRefSuffix this.averagingSuffixes];
            switch (double(isfq))
                case 1
                    fn = fullfilename(this.roi_path, fn);
                case 0
                    fn =                         filename(fn);
                otherwise
            end
        end % csf_filename
        
        function fn  = grey_filename(this, isfq, isblocked)
            
            %% GREY_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = 1; end
            if (nargin < 3); isblocked = false; end
            fn = ['grey' this.onRefSuffix this.averagingSuffixes];
            switch (double(isfq))
                case 1
                    fn = fullfilename(this.roi_path, fn);
                case 0
                    fn =                         filename(fn);
                otherwise
            end
        end % grey_filename
        
        function fn  = white_filename(this, isfq, isblocked)
            
            %% WHITE_FILENAME 		
            %  isfq:  bool true -> return fully qualified filename
            %         ~0, ~1    -> fileprefix only
            %
            if (nargin < 2); isfq = true; end
            if (nargin < 3); isblocked = false; end
            fn = ['white' this.onRefSuffix this.averagingSuffixes];
            switch (double(isfq))
                case 1
                    fn = fullfilename(this.roi_path, fn);
                case 0
                    fn =                         filename(fn);
                otherwise
            end
        end % white_filename       
        
        function mn  = minVoxelsPerBlock(this) %#ok<MANU>
            
            %% MINVOXELSPERBLOCK
            %%nvxl = prod(this.blockSize);
            %%mn   = nvxl/2;
            mn   = 1;
        end
        
        function disp(this)
            
            disp@handle(this);
        end
    end % public methods
    
    methods (Static)

        function this = instance(qualifier)
            
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            pid1 = '';
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                    case 'clear'
                        clear uniqueInstance;
                        return;
                    case 'delete'
                        if (~isempty(uniqueInstance))
                            uniqueInstance.delete;
                            return;
                        end
                    otherwise
                        pid1 = qualifier;
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfourd.Np797Registry();                
                if (~isempty(pid1)); this.pid = pid1; end
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end % static methods
    
    methods (Access = private)

        function this = Np797Registry
            
            %% CTOR is private and empty to ensure instance is the only entry into the class
            this = this@mlfourd.FslRegistry;
        end % private ctor
        
        function fold = qcbf_folder(this, pid)
            
            %% QCBF_FOLDER
            if (nargin > 1)
                this.pid = mlfourd.Np797Registry.ensurePnum(pid); 
            end
            fold = [this.extFileParts_.northwesternIdMap(pid) pid this.extFileParts_.dateMap(pid)];
        end % private qcbf_folder
    end % private methods 
end % classdef DBase
