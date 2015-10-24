classdef MRIConverter < mlfourd.AbstractDicomConverter
	%% MRICONVERTER is a concrete strategy for interfaces AbstractDicomConverter, AbstractConverter, ConverterInterface
    %
    %  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/MRIConverter.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: MRIConverter.m 1231 2012-08-23 21:21:49Z jjlee $ 
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
        function cvert     = creation(modalPth)
            %% CREATION returns an instance of MRIConverter for testing
            %  Usage:  converter = MRIConverter.creation(modality_path)
            %                                                    ^ e.g., /path_to_session/Trio
            
            cvert = mlfourd.MRIConverter(modalPth);
        end % static creation           
        function this      = createFromSessionPath(spth)
            import mlfourd.*;
            mpth = firstExistingFile(spth, MRIConverter.modalityFolders);
            this = MRIConverter.createFromModalityPath(mpth);
        end
        function this      = createFromModalityPath(mpth)
            this = mlfourd.MRIConverter.creation(mpth);
        end
        function [cal,s,r] = unpackDicom(dcmdir, targdir, ~)
            %% UNPACKDICOM is a facade for mcverter            
            
            import mlfourd.*;
            this  = MRIConverter(dcmdir);
            [s,r] = this.mcvert(dcmdir, targdir);
            dirt  = DirTool(targdir);
            cal   = mlpatterns.CellArrayList;
            for f = 1:length(dirt.fns) %#ok<FORFLG>
                cal.add(dirt.fns{f}); 
            end
        end % static unpackDicom
        function             convertStudy(studyPth, patt)
            import mlfourd.*;
            assert(lexist(studyPth, 'dir'));
            if (~exist('patt', 'var')); patt = '*'; end
            dt = DirTool(fullfile(studyPth, patt));
            for d = 1:length(dt.fqdns)
                try
                    MRIConverter.convertSession(dt.fqdns{d});
                catch ME
                    handwarning(ME);
                end
            end
        end % static convertStudy        
        function this      = convertSession(sessionPth)
            import mlfourd.*;
            this = MRIConverter.createFromSessionPath(sessionPth); 
            this.unpack(this.unpackPath);            
            MRIConverter.fixOrient(this.fslPath, this.orients2fix);
        end % static convertSession      
        function [s,r]     = scanDicom(dcmdir, targdir)
            %% SCANDICOM is a facade for mcverter
            
            [~,s,r] = mlfourd.MRIConverter.unpackDicom(dcmdir, targdir);
        end % static scanDicom
    end
    
	methods
		function this       = set.mcverterDin( this, din)
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
        function this       = set.mcverterDout(this, dout)
                assert(~isempty(dout));
            [p,~,~] = fileparts(dout);
            if (isempty(p))
                this.mcverterDout = fullfile(pwd, dout, '');
            end
            this.mcverterDout = ensureFolderExists(dout);
        end % set.mcverterDout
        
        function              rename(this, unpackPth, fslPth)
            %% RENAME
            
            import mlfourd.*;
            unpacked = DirTool(fullfile(unpackPth, '*.nii'));
            fslPth = ensureFolderExists(fslPth);
            for f = 1:length(unpacked.fns) %#ok<FORFLG>
                names  = regexp(unpacked.fns{f}, this.INFO_EXPRESSION, 'names'); 
                fslnam = fileprefix(this.namereg_.fslName(names.seq_type), '.nii');
                copyfile(fullfile(unpackPth, unpacked.fns{f}), ...
                         fullfile(   fslPth, [fslnam '_' sprintf('%03u', names.index) '.nii']), 'f');
            end
        end % rename     
		function [s,r]      = mcvert(this, din, dout)
            %% MCVERTER is a wrapper that runs MRIConverter in a shell
            %  Warning:  do not wrap in parfor!
            %  Usage:   [sta, std] = mcverter(DICOM_fold, output_fold)

            s = 0; r = '';
            if (exist('din',  'var'))
                this.mcverterDin = din;
            elseif (isempty(this.mcverterDin))
                this.mcverterDin = this.dicomPath;
            end
            assert(lexist(this.mcverterDin, 'dir'), 'mlfsl:IOError', ...
                  'FslFacade.mcverter:  %s does not exist', this.mcverterDin);

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

%            nlist = dir2cell(fullfile(this.mcverterDout, '*.nii'));
%             for n = 1:length(nlist) %#ok<FORPF>
%                 gzip(  nlist{n});
%                 delete(nlist{n});
%             end
        end % mcvert        
        function structInfo = dicomQuery(this, dcmPth, unpackPth)
 			%% DICOMQUERY
            %  Usage:  structInfo = obj.dicomQuery([dicom_path, target_path])
            %          ^ struct-array for session, one struct per series;
            %            fields:  index, seq_type, status, dim1, dim2, dim3, dim4
            
            if ( exist('dcmPth',  'var')); this.dicomPath  = dcmPth;  end
            if ( exist('unpackPth', 'var')); this.unpackPath = unpackPth; end
            structInfo = this.dicoms2structInfo;
 		end % dicomQuery  
        function structInfo = dicoms2structInfo(this)
            %% DICOM2STRUCTINFO
            
            import mlfourd.*;
            [s,r]      = MRIConverter.scanDicom(this.dicomPath, this.unpackPath); assert(0 == s);
                         mlbash(['pushd ' this.unpackPath '; gunzip *.nii.gz; popd']);
            dt         = DirTool(fullfile(this.unpackPath, '*.nii'));
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
    
    methods (Static, Access = 'protected')
        
        function  structInfo = parseInfoFile(fname)
            %% parseInfoFile
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
        function  structInfo = parseInfoCell(ca)
            %% PARSEINFOSTRING
            %  Usage:   structInfo = MRIConverter.parseInfoCell(cell_array_of_filenames)
            %           ^ struct-array for scan session, one struct per scan series;
            %             fields:  sessionId, date, time, index, seq_type, status
            %                                                   ^ e.g., DirTool.fns
            
            try
                for j = 1:length(ca)
                    [~,info,~]    = fileparts(ca{j});
                    structInfo(j) = mlfourd.MRIConverter.parseInfoFile(info);
                end
            catch ME
                handexcept(ME);
            end
        end
    end % static methods
    
    methods (Access = 'protected')
 		function this       = MRIConverter(varargin) 
 			%% MRICONVERTER 
 			%  Usage:  mc = MRIConverter([dicom_path, target_path])
            
            this = this@mlfourd.AbstractDicomConverter(varargin{:});
 		end % MRIConverter (ctor) 
    end % methods
    

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

