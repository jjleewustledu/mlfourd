classdef FourdfpTool < handle & mlfourd.ImagingFormatTool
    %% FOURDFPTOOL
    %
    %  Created 12-Dec-2021 23:36:09 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee.
    
    properties (Dependent)
        ifh
        imgrec
    end

    methods (Static)
        function this = createFromImagingFormat(iform)
            %% from any ImagingFormatTool create FourdfpTool

            assert(isa(iform, 'mlfourd.ImagingFormatTool'))

            fs_ = iform.filesystem_;
            fs_.filesuffix = '.4dfp.hdr';
            [hdr_,orig_] = mlfourd.FourdfpTool.imagingFormatToHdr(iform);
            info_ = mlfourd.FourdfpInfo(fs_, ...
                'datatype', iform.datatype, ...
                'ext', iform.ext, ...
                'filetype', iform.filetype, ...
                'N', iform.N , ...
                'json_metadata', iform.json_metadata, ...
                'untouch', [], ...
                'hdr', hdr_, ...
                'original', orig_, ...
                'json_metadata', iform.json_metadata);      
            this = mlfourd.FourdfpTool( ...
                iform.contexth_, iform.img, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 2);
        end
    end

    methods

        %% GET, SET

        function g = get.ifh(this)
            if (~isprop(this.imagingInfo_, 'ifh'))
                g = [];
                return
            end
            g = this.imagingInfo_.ifh;
        end
        function     set.ifh(this, s)
            if (~isprop(this.imagingInfo_, 'ifh'))
                return
            end
            assert(isa(s, mlfourdfp.IfhParser));
            this.imagingInfo_.ifh = s;
        end
        function g = get.imgrec(this)
            if ~isprop(this.imagingInfo_, 'imgrec')
                g = [];
                return
            end
            g = this.imagingInfo_.imgrec;
        end
        function     set.imgrec(this, s)
            if ~isprop(this.imagingInfo_, 'imgrec')
                return
            end
            assert(isa(s, mlfourdfp.ImgRecLogger));
            this.imagingInfo_.imgrec = s;
        end

        %%

        function addImgrec(this, varargin)
            if isempty(this.imgrec)
                return
            end
            if istext(varargin{1})
                this.imgrec.add(varargin{:});
                return
            end
            this.imgrec.add(ensureString(varargin{:}));
        end 
        
        function this = FourdfpTool(contexth, img, varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      img (numeric): option provides numerical imaging data.  Default := [].
            %      imagingInfo (ImagingInfo): Default := [].
            %      filesystem (HandleFilesystem): Default := mlio.HandleFilesystem().
            %      logger (mlpipeline.ILogger): Default := log on filesystem | mlpipeline.Logger2(filesystem.fqfileprefix).
            %      viewer (IViewer): Default := mlfourd.Viewer().
            %      useCase (numeric): described above.  Default := 1.

            this = this@mlfourd.ImagingFormatTool(contexth, img, varargin{:});
        end

        function save(this, opts)
            %% SAVE 

            arguments
                this mlfourd.FourdfpTool
                opts.savelog logical = true;
            end
            this.assertNonemptyImg();
            this.ensureNoclobber();
            ensuredir(this.filepath);
            imagingInfo__ = copy(this.imagingInfo_);

            warning('off', 'MATLAB:structOnObject');
            try
                ana = mlniftitools.make_ana(single(this.img), this.mmppix_triple(), [0 0 0], 16);
                this.addLog("mlniftitools.make_ana(this.img, [" + mat2str(this.mmppix) + "])");
                ana = this.imagingInfo.ensureSavingOrientation(ana);
                ana = this.ensureHist(ana);

                fqfn = strcat(this.fqfileprefix, '.4dfp.hdr');
                mlniftitools.save_untouch_nii(ana, fqfn); % make_ana() requires save_untouch_nii()
                this.addLog("mlniftitools.save_untouch_nii(ana, " + fqfn + ")");

                imagingInfo__.ifh.fqfileprefix = this.fqfileprefix;
                imagingInfo__.ifh.save(this);
                this.addLog("imagingInfo__.ifh.save(this)");
                
                imagingInfo__.imgrec.fqfileprefix = this.fqfileprefix;
                imagingInfo__.imgrec.save();
                
                if opts.savelog
                    this.addLog("imagingInfo__.imgrec.save()");
                    this.saveLogger();
                end
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError', ...
                    'FourdfpTool.save could not save %s', this.fqfilename);
            end
            warning('on', 'MATLAB:structOnObject');
        end
    end

    %% PROTECTED

    methods (Access = protected)
        function ana = ensureHist(this, ana)
            %% override behavior of mlniftitools.make_ana() dropping aux_file

            ana.hdr.hist.aux_file = this.imagingInfo_.hdr.hist.aux_file;
        end
    end

    %% PRIVATE

    methods (Access = private)
        function m = mmppix_triple(this)
            switch numel(this.mmppix)
                case 1
                    m = this.mmppix;
                    m(2) = 0;
                    m(3) = 0;
                case 2
                    m = this.mmppix;
                    m(3) = 0;
                case 3
                    m = this.mmppix;
                otherwise
                    m = this.mmppix(1:3);
            end
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
