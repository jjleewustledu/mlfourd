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
                'untouch', [], ...
                'hdr', hdr_, ...
                'original', orig_);      
            this = mlfourd.FourdfpTool( ...
                iform.contexth_, iform.img, ...
                'imagingInfo', info_, ...
                'filesystem', fs_, ...
                'logger', iform.logger, ...
                'viewer', iform.viewer, ...
                'useCase', 2);
        end
        function info = createImagingInfo(fn, varargin)
            info = mlfourd.FourdfpInfo(fn, varargin{:});
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

            try
                this = this.adjustQOffsets;
                this = this.adjustSRows;
            catch ME
                this.addLog(ME.message)
                this.addLog(struct2str(ME.stack))                

                % KLUDGE:  following sucesses of AbstractInnerImagingFormat
                if isfile(this.fqfilename)
                    nii_ = this.imagingInfo_.make_nii;
                    this.imagingInfo_.hdr = nii_.hdr;
                    this.imagingInfo_.untouch = false;
                    this = this.adjustQOffsets;
                    this = this.adjustSRows;
                end
            end
        end
    end

    %% HIDDEN
    
    methods (Hidden) 
        function save__(this)
            %this = copy(this);
            assert(lstrfind(this.filesuffix, '.4dfp'));
            [this.img_,hdr_] = mlfourd.FourdfpInfo.exportFourdfp(this.img_, this.imagingInfo.hdr); %% KLUDGE
            this.imagingInfo_.hdr = hdr_;
            try                
                warning('off', 'MATLAB:structOnObject');
                if numel(this.mmppix) < 3
                    ana = mlniftitools.make_ana(single(this.img_), [this.mmppix, this.mmppix(2)]);
                    this.addLog("mlniftitools.make_ana(single(this.img_), [" + mat2str(this.mmppix) + ", " + this.mmppix(2) + "])");
                else
                    ana = mlniftitools.make_ana(single(this.img_), this.mmppix);
                    this.addLog("mlniftitools.make_ana(single(this.img_), [" + mat2str(this.mmppix) + "])");
                end
                fqfn = strcat(this.fqfileprefix, '.4dfp.hdr');
                mlniftitools.save_untouch_nii(ana, fqfn);
                this.addLog("mlniftitools.save_untouch_nii(ana, " + fqfn + ")");
                this.imagingInfo_.ifh.fqfileprefix = this.fqfileprefix;
                this.imagingInfo_.ifh.save(this);
                this.addLog("this.imagingInfo_.ifh.save(this)");
                this.imagingInfo_.imgrec.fqfileprefix = this.fqfileprefix;
                this.imagingInfo_.imgrec.save();
                this.addLog("this.imagingInfo_.imgrec.save()");
                warning('on', 'MATLAB:structOnObject');
            catch ME
                dispexcept(ME, ...
                    'mlfourd:IOError', ...
                    'InnerFourdfp.saveByNifti4dfp erred while attempting to save %s', this.fqfilename);
            end
        end
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function this = adjustQOffsets(this)
            this.hdr.hist.qoffset_x = this.hdr.hist.qoffset_x / this.hdr.dime.pixdim(2);
            this.hdr.hist.qoffset_y = this.hdr.hist.qoffset_y / this.hdr.dime.pixdim(3);
            this.hdr.hist.qoffset_z = this.hdr.hist.qoffset_z / this.hdr.dime.pixdim(4);            
        end
        function this = adjustSRows(this)
            this.hdr.hist.srow_x(4) = this.hdr.hist.srow_x(4) / this.hdr.dime.pixdim(2);
            this.hdr.hist.srow_y(4) = this.hdr.hist.srow_y(4) / this.hdr.dime.pixdim(3);
            this.hdr.hist.srow_z(4) = this.hdr.hist.srow_z(4) / this.hdr.dime.pixdim(4);
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
