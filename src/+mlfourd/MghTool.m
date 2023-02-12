classdef MghTool < handle & mlfourd.ImagingFormatTool
    %% MGHTOOL behaves identically to NIfTIInfo until save() is called.  save() uses mri_convert
    %  to convert nii.gz to mgz.
    %  
    %  Created 12-Dec-2021 23:36:39 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    methods (Static)
        function this = createFromImagingFormat(iform)
            %% from any ImagingFormatTool create MghTool

            assert(isa(iform, 'mlfourd.ImagingFormatTool'))

            fs_ = iform.filesystem_;
            fs_.filesuffix = '.mgz';
            [hdr_,orig_] = mlfourd.MghTool.imagingFormatToHdr(iform);
            info_ = mlfourd.MGHInfo(fs_, ...
                'datatype', iform.datatype, ...
                'ext', iform.ext, ...
                'filetype', iform.filetype, ...
                'N', iform.N , ...
                'untouch', [], ...
                'hdr', hdr_, ...
                'orig', orig_, ...
                'json_metadata', iform.json_metadata);
            this = mlfourd.MghTool( ...
                iform.contexth_, iform.img, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 2);
        end
        function out = mri_convert(varargin)
            %% MRI_CONVERT calls FreeSurfer's mri_convert.
            %  Args:
            %      in (any): object understood by mlfourd.ImagingContext2.
            %      out (any): object understood by mlfourd.ImagingContext2.
            %      options (option, text): see help for mri_convert.
            %  Returns:
            %      out: referencing imaging on filesystem.

            ip = inputParser;
            addRequired(ip, 'in')
            addOptional(ip, 'out', '')
            addParameter(ip, 'options', '', @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;

            in = mlfourd.ImagingContext2(ipr.in);
            out = mlfourd.ImagingContext2(ipr.out);
            if ~isfile(in.fqfn)
                in.save();
            end
            cmd = sprintf('mri_convert %s %s', in.fqfn, out.fqfn);
            s = mlbash(cmd);
            assert(0 == s, 'mlfourd:RuntimeError', 'MghTool.mri_convert()')
            out = mlfourd.ImagingContext2(out.fqfn);
        end
        function out = mri_convert2std(varargin)
            %% MRI_CONVERT2STD calls FreeSurfer's mri_convert, then FSL's fslreorient2std.
            %  Args:
            %      in (any): object understood by mlfourd.ImagingContext2.
            %      out (any): object understood by mlfourd.ImagingContext2.
            %      options (option, text): see help for mri_convert.
            %  Returns:
            %      out: referencing imaging on filesystem.

            ip = inputParser;
            addRequired(ip, 'in')
            addOptional(ip, 'out', '')
            addParameter(ip, 'options', '', @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;

            tmp = strcat(tempname, '.nii.gz');
            tmp = mlfourd.MghTool.mri_convert(ipr.in, tmp, 'options', ipr.options);
            out = mlfourd.MghTool.fslreorient2std(tmp, ipr.out);
            deleteExisting(tmp.fqfn)
        end
        function out = fslreorient2std(varargin)
            %% FSLREORIENT2STD calls FSL's fslreorient2std.
            %  Args:
            %      in (any): object understood by mlfourd.ImagingContext2.
            %      out (any): object understood by mlfourd.ImagingContext2.
            %  Returns:
            %      out: referencing imaging on filesystem.
        end
    end

    properties (Dependent)
        fqfileprefix_mgz
    end

    methods

        %% GET

        function fqfn = get.fqfileprefix_mgz(this)
            fqfn = strcat(this.fqfileprefix, this.MGH_EXT);
        end
        
        %%

        function this = MghTool(varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      img (numeric): option provides numerical imaging data.  Default := [].
            %      imagingInfo (ImagingInfo): Default := [].
            %      filesystem (HandleFilesystem): Default := mlio.HandleFilesystem().
            %      logger (mlpipeline.ILogger): Default := log on filesystem | mlpipeline.Logger2(filesystem.fqfileprefix).
            %      viewer (IViewer): Default := mlfourd.Viewer().
            %      useCase (numeric): described above.  Default := 1.

            this = this@mlfourd.ImagingFormatTool(varargin{:});
        end

        function save(this, opts)
            %% SAVE 

            arguments
                this mlfourd.MghTool
                opts.savejson logical = true;
                opts.savelog logical = true;
            end
            this.assertNonemptyImg();
            this.ensureNoclobber();
            ensuredir(this.filepath);

            try
                fqfn_nii = strcat(this.fqfileprefix, '.nii.gz');
                fqfn_mgz = strcat(this.fqfileprefix, '.mgz');

                this.filesystem_.fqfilename = fqfn_nii;
                this.save_nii();
                this.filesystem_.fqfilename = fqfn_mgz;
                cmd = sprintf('mri_convert %s %s', fqfn_nii, fqfn_mgz);
                mlbash(cmd);

                if opts.savejson
                    this.save_json_metadata();
                end
                if opts.savelog
                    this.addLog(cmd);
                    this.saveLogger();
                end
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError', ...
                    'MghTool.save could not save %s', this.fqfilename);
            end
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
