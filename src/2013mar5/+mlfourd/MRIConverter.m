classdef MRIConverter < mlfourd.AbstractDicomConverter
	%% MRICONVERTER is a concrete strategy for interfaces AbstractDicomConverter, AbstractConverter, ConverterInterface
    %
    %  Version $Revision: 2308 $ was created $Date: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/MRIConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: MRIConverter.m 2308 2013-01-12 23:51:00Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Constant)
        INFO_EXPRESSION = ...
'(?<sessionId>\S+)_(?<date>\d+)_(?<time>\d+)_(?<index>\d+)_(?<seq_type>\S+\.nii)';
        unpackFolders = {'MRIConvert'}; 
    end
    
    properties
		mcverterDin
        mcverterDout
    end

    methods (Static)    
        function this    = convertSession(sessionPth, varargin)
            import mlfourd.*;
            this = MRIConverter.convertModalityPath( ...
                   firstExistingFile( ...
                      sessionPth, ...
                      MRIConverter.modalityFolders), ...
                   varargin{:});
        end
        function lastobj = convertSessions(patt, varargin)
            import mlfourd.*;
            dt = DirTool(patt);
            for s = 1:length(dt)
                fprintf('MRIConverter will convert:  %s\n', dt.fqdns{s});
                lastobj = MRIConverter.convertSession(dt.fqdns{s}, varargin{:});
            end
            assert(~isempty(lastobj));
        end   
        function this      = convertModalityPath(modalPth)
            try
                this = mlfourd.MRIConverter.createFromModalityPath(modalPth);                
                if (this.islockedFslFolder('.mriconverter'))
                    this.archiveFslFolder; 
                    error('mlfourd:DataDirectoryWasLocked', ...
                          'MRIConverter.convertModalityPath');
                end
                this = this.unpackDicom;
                this.copyUnpacked(this.unpackPath, this.fslPath); 
                this.orientChange2Standard(this.fslPath);                
                this.orientRepair(this.fslPath, this.orients2fix);
                this.lockFslFolder('.mriconverter'); 
            catch ME
                handwarning(ME, r);
            end            
        end
        function this      = createFromModalityPath(mpth)
            this = mlfourd.MRIConverter(mpth);
        end
        
        function cal = unpacksDcmDir(dcmdir, targdir, ~)
            %% UNPACKDICOM is a facade for mcverter            
            
            import mlfourd.*;
            this  = MRIConverter(dcmdir);
            this.mcvert(dcmdir, targdir);
            dirt  = DirTool(targdir);
            cal   = mlpatterns.CellArrayList;
            for f = 1:length(dirt.fns) %#ok<FORFLG>
                cal.add(dirt.fns{f}); 
            end
        end % static unpacksDcmDir    
        function [s,r]     = scanDicom(dcmdir, targdir)
            %% SCANDICOM is a facade for mcverter
            
            [~,s,r] = mlfourd.MRIConverter.unpacksDcmDir(dcmdir, targdir);
        end % static scanDicom
    end
    
	methods %% get/set
		function this = set.mcverterDin( this, din)
	            assert(~isempty(din));
            [p,~,~] = fileparts(din);
            if (isempty(p))
                this.mcverterDin = fullfile(pwd, din, '');
            end
            this.mcverterDin = din;
            if (~lexist(this.mcverterDin, 'dir'))
                error('mlfourd:IO:FailedRead', ...
                      'MRIConverter.set.mcverterDin could not find directory %s', this.mcverterDin);
            end
        end % set.mcverterDin
        function this = set.mcverterDout(this, dout)
                assert(~isempty(dout));
            [p,~,~] = fileparts(dout);
            if (isempty(p))
                this.mcverterDout = fullfile(pwd, dout, '');
            end
            this.mcverterDout = ensureFolderExists(dout);
        end % set.mcverterDout
    end
    
    methods
        function              copyUnpacked(this, unpackPth, fslPth)
            %% RENAME
            
            import mlfourd.*;
            unpacked = DirTool(fullfile(unpackPth, '*.nii'));
            fslPth = ensureFolderExists(fslPth);
            for f = 1:length(unpacked.fns) %#ok<FORFLG>
                names  = regexp(unpacked.fns{f}, this.INFO_EXPRESSION, 'names'); 
                fslnam = fileprefix(this.namingRegistry_.fslName(names.seq_type), '.nii');
                copyfile(fullfile(unpackPth, unpacked.fns{f}), ...
                         fullfile(   fslPth, [fslnam '_' sprintf('%03u', names.index) '.nii']), 'f');
            end
        end % copyUnpacked     
		function [s,r]      = mcvert(this, din, dout)
            %% MCVERTER is a wrapper that runs MRIConverter in a shell
            %  Warning:  do not wrap in parfor!
            %  Usage:   [sta, std] = mcverter(DICOM_fold, output_fold)

            if (exist('din',  'var'))
                this.mcverterDin = din;
            elseif (isempty(this.mcverterDin))
                this.mcverterDin = this.dicomPath;
            end
            assert(lexist(this.mcverterDin, 'dir'), 'mlfsl:IOError', ...
                  'FslBuilder.mcverter:  %s does not exist', this.mcverterDin);

            if (exist('dout', 'var'))
                this.mcverterDout = dout;
            elseif (isempty(this.mcverterDout))
                this.mcverterDout = fullfile(this.mrPath, this.mcverterFolder, '');
            end
            this.mcverterDout = ensureFolderExists(this.mcverterDout);
            
            [s,r] = mlbash([this.mcverterBin ' --output=' this.mcverterDout ' ' this.mcverterArgs ' ' this.mcverterDin]);
            if (~isempty(r))
                warning('mlfsl:MRImagingComponent:mcverter', r);
            end
        end % mcvert        
        function structInfo = dicomQuery(this, dcmPth, unpackPth)
 			%% DICOMQUERY
            %  Usage:  structInfo = obj.dicomQuery([dicom_path, target_path])
            %          ^ struct-array for session, one struct per series;
            %            fields:  index, seq_type, status, dim1, dim2, dim3, dim4
            
            if (exist('dcmPth',  'var'))
                this.dicomPath  = dcmPth; end
            if (exist('unpackPth', 'var'))
                this.unpackPath = unpackPth; end
            structInfo = this.dicoms2structInfo;
 		end % dicomQuery  
        function structInfo = dicoms2structInfo(this)
            %% DICOM2STRUCTINFO
            
            import mlfourd.*;
            MRIConverter.scanDicom(this.dicomPath, this.unpackPath); 
            mlbash(['pushd ' this.unpackPath '; gunzip *.nii.gz; popd']);
            dt = DirTool(fullfile(this.unpackPath, '*.nii'));
            structInfo = MRIConverter.parseInfoCell(dt.fns);
        end % dicoms2structInfo
        function unpackInfo = structInfo2unpackInfo(this, structInfo)
            %% STRUCTINFO2UNPACKINFO
            %  Usage:  unpackInfo = obj.structInfo2unpackInfo(structInfo)
            %                                      ^ cf. dicomQuery
            %          ^ struct-array for session, one struct per series
            %            fields:   index, seq_tuype, ext, name, dicom_path, target_path
            
            import mlsurfer.* mlfourd.*;
            n       = 0;
            unpackInfo = struct([]);
            for s = 1:length(structInfo) %#ok<FORFLG>
                n = n + 1;
                unpackInfo(n).index       = structInfo(s).index; 
                unpackInfo(n).seq_type    = structInfo(s).seq_type;
                unpackInfo(n).ext         = 'nii';
                unpackInfo(n).name        = structInfo(s).seq_type;  
                unpackInfo(n).dicom_path  = this.dicomPath; 
                unpackInfo(n).target_path = this.unpackPath;
            end            
        end % structInfo2unpackInfo
    end % methods
    
    %% PROTECTED
    
    properties (SetAccess = 'protected')
        mcverterBin   = '/usr/bin/mcverter';
        mcverterArgs  = ' --format=fsl -d --nii --fnformat=SeriesNumber,ProtocolName,SeriesDate,SeriesTime --rescale ';
    end 

    methods (Access = 'protected')
 		function this = MRIConverter(varargin) 
 			%% MRICONVERTER 
 			%  Usage:  mc = MRIConverter([dicom_path, target_path])
            
            this = this@mlfourd.AbstractDicomConverter(varargin{:});
 		end % MRIConverter (ctor) 
    end 
    
    %% PRIVATE
        
    methods (Static, Access = 'private')
        function  structInfo = parseInfoCell(ca)
            %% PARSEINFOCELL
            %  Usage:   structInfo = MRIConverter.parseInfoCell(cell_array_of_filenames)
            %           ^ struct-array for scan session, one struct per scan series;
            %             fields:  sessionId, date, time, index, seq_type, status
            %                                                   ^ e.g., DirTool.fns

            for j = 1:length(ca)
                [~,info,~]    = filepartsx(ca{j}, mlfourd.AbstractImage.FILETYPE_EXT);
                structInfo(j) = mlfourd.MRIConverter.parseInfoFile(info); %#ok<AGROW>
            end
        end
        function  structInfo = parseInfoFile(fname)
            %% PARSEINFOFILE
            %  Usage:   structInfo = MRIConverter.parseInfoFile(name)
            %           ^ struct-array for scan session, one struct per scan series;
            %             fields:  sessionId, date, time, index, seq_type, status
            
            try
                [~, info]       = regexp(fname, mlfourd.MRIConverter.INFO_EXPRESSION, 'tokens', 'names');
                if (~isempty(info))
                    info.index  = str2double(info.index);
                    info.status = 'ok';
                    structInfo  = info;
                end
            catch ME
                handwarning(ME);
                structInfo = struct('sessionId', fname, 'status', 'err');
            end
        end
    end
    
    

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

