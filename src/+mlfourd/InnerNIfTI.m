classdef InnerNIfTI < handle & mlfourd.AbstractInnerImagingFormat & mlfourd.HandleJimmyShenInterface
	%% INNERNIFTI supplies decorated INIfTI objects to AbstractNIfTIComponent.  It also forms a composite
    %  design pattern with composites InnerNIfTIc, which supplies composite INIfTI objects to AbstractNIfTIComponent.
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.  
    
    properties (Dependent) 
        untouch
        
        hdxml
        orient % RADIOLOGICAL, NEUROLOGICAL
    end 
    
	methods (Static)
        function this = create(fn, varargin)
            import mlfourd.*;
            this = InnerNIfTI( ...
                InnerNIfTI.createImagingInfo(fn, varargin{:}), varargin{:});
        end
        function info = createImagingInfo(fn, varargin)
            info = mlfourd.NIfTIInfo(fn, varargin{:});
        end
        function [s,ninfo] = imagingInfo2struct(fn, varargin)
            ninfo = mlfourd.NIfTIInfo(fn, varargin{:});
            nii = ninfo.make_nii;
            s = struct( ...
                'hdr', nii.hdr, ...
                'filetype', ninfo.filetype, ...
                'fileprefix', fn, ...
                'machine', ninfo.machine, ...
                'ext', ninfo.ext, ...
                'img', nii.img, ...
                'untouch', nii.untouch);
        end
    end

 	methods 
        
        %% GET/SET
                      
        function x = get.hdxml(this)
            if (~lexist(this.fqfilename, 'file'))
                x = '';
                return
            end
            [~,x] = mlbash(['fslhd -x ' this.fqfileprefix]);
            x = strtrim(regexprep(x, 'sform_ijk matrix', 'sform_ijk_matrix'));
        end
        function o = get.orient(this)
            if (~isempty(this.orient_))
                o = this.orient_;
                return
            end
            if (lexist(this.fqfilename, 'file') && lstrfind(this.filesuffix, this.imagingInfo.defaultFilesuffix))
                [~, o] = mlbash(['fslorient -getorient ' this.fqfileprefix]);
                o = strtrim(o);
                return
            end
            o = '';
        end 
        function u = get.untouch(this)
            u = this.imagingInfo_.untouch;
        end
        function     set.untouch(this, s)
            this.imagingInfo_.untouch = logical(s);
        end
         
        %%         
        
        function this = InnerNIfTI(varargin)
 			%  @param imagingInfo is an mlfourd.ImagingInfo object and is required; it may be an aufbau object.
            
            this = this@mlfourd.AbstractInnerImagingFormat(varargin{:});
        end        
    end
    
    %% PROTECTED
    
    methods (Access = protected)
        function this = mutateInnerImagingFormatByFilesuffix(this)
            import mlfourd.* mlfourdfp.* mlsurfer.*;  
            hdr_ = this.hdr;
            switch (this.filesuffix)
                case FourdfpInfo.SUPPORTED_EXT
                    deleteExisting([this.fqfileprefix '.4dfp.*']);
                    [this.img,hdr_] = FourdfpInfo.exportFourdfp(this.img, hdr_);
                    info = FourdfpInfo(this.fqfilename, ...
                        'datatype', this.datatype, 'ext', this.imagingInfo.ext, 'filetype', this.imagingInfo.filetype, 'N', this.N , 'untouch', false, 'hdr', hdr_);                    
                    this = InnerFourdfp(info, ...
                       'creationDate', this.creationDate, 'img', this.img, 'label', this.label, 'logger', this.logger, ...
                       'orient', this.orient_, 'originalType', this.originalType, 'seriesNumber', this.seriesNumber, ...
                       'separator', this.separator, 'stack', this.stack, 'viewer', this.viewer);
                    this.imagingInfo.hdr = hdr_;
                case [NIfTIInfo.SUPPORTED_EXT]
                case MGHInfo.SUPPORTED_EXT 
                    deleteExisting([this.fqfileprefix '.mgz']);
                    deleteExisting([this.fqfileprefix '.mgh']);
                    info = MGHInfo(this.fqfilename, ...
                        'datatype', this.datatype, 'ext', this.imagingInfo.ext, 'filetype', this.imagingInfo.filetype, 'N', this.N , 'untouch', false, 'hdr', this.hdr);
                    this = InnerMGH(info, ...
                       'creationDate', this.creationDate, 'img', this.img, 'label', this.label, 'logger', this.logger, ...
                       'orient', this.orient_, 'originalType', this.originalType, 'seriesNumber', this.seriesNumber, ...
                       'separator', this.separator, 'stack', this.stack, 'viewer', this.viewer);
                    this.imagingInfo.hdr = hdr_;
                otherwise
                    error('mlfourd:unsupportedSwitchcase', ...
                        'InnerNIfTI.filesuffix->%s', this.filesuffix);
            end
        end        
    end
    
    %% HIDDEN
    
    methods (Hidden)        
        function save__(this)
            assert(strcmp(this.filesuffix, '.nii') || strcmp(this.filesuffix, '.nii.gz'))
            this.save_nii;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
    
 end 
