classdef InnerNIfTId < mlfourd.AbstractInnerImagingFormat & mlfourd.JimmyShenInterface
	%% INNERNIFTID supplies decorated INIfTI objects to AbstractNIfTIComponent.  It also forms a composite
    %  design pattern with composites InnerNIfTIc, which supplies composite INIfTI objects to AbstractNIfTIComponent.
    
	%  $Revision$
 	%  was created 20-Oct-2015 19:28:49
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.  
    
    properties (Dependent)        
        ext      % Legacy variable for mlfourd.JimmyShenInterface
        filetype % 0 -> Analyze format .hdr/.img; 1 -> NIFTI .hdr/.img; 2 -> NIFTI .nii or .nii.gz
        untouch
        
        hdxml
        orient % RADIOLOGICAL, NEUROLOGICAL
    end 
    
	methods (Static)
        function this = construct(fn, varargin)
            import mlfourd.*;
            this = InnerNIfTId( ...
                InnerNIfTId.constructImagingInfo(fn, varargin{:}), varargin{:});
        end
        function info = constructImagingInfo(fn, varargin)
            info = mlfourd.NIfTIInfo(fn, varargin{:});
        end
        function e = defaultFilesuffix
            e =  mlfourd.NIfTIInfo.NIFTI_EXT;
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
                
        function e    = get.ext(this)
            e = this.imagingInfo_.ext;
        end
        function this = set.ext(this, e)
            this.imagingInfo_.ext = e;
        end
        function f    = get.filetype(this)
            f = this.imagingInfo_.filetype;
        end
        function this = set.filetype(this, ft)
            switch (ft)
                case {0 1}
                    this.imagingInfo_.filetype = ft;
                    this.filesuffix = '.hdr';
                case 2
                    this.imagingInfo_.filetype = ft;
                    this.filesuffix = this.defaultFilesuffix;
                otherwise
                    error('mlfourd:unsupportedParamValue', 'InnerNIfTId.set.filetype.ft->%g', ft);
            end
        end        
        function x    = get.hdxml(this)
            if (~lexist(this.fqfilename, 'file'))
                x = '';
                return
            end
            [~,x] = mlbash(['fslhd -x ' this.fqfileprefix]);
            x = strtrim(regexprep(x, 'sform_ijk matrix', 'sform_ijk_matrix'));
        end
        function o    = get.orient(this)
            if (~isempty(this.orient_))
                o = this.orient_;
                return
            end
            if (lexist(this.fqfilename, 'file') && lstrfind(this.filesuffix, this.defaultFilesuffix))
                [~, o] = mlbash(['fslorient -getorient ' this.fqfileprefix]);
                o = strtrim(o);
                return
            end
            o = '';
        end 
        function u    = get.untouch(this)
            u = this.imagingInfo_.untouch;
        end
        function this = set.untouch(this, s)
            this.imagingInfo_.untouch = logical(s);
        end
         
        %%         
        
        function this = InnerNIfTId(varargin)     
 			%  @param imagingInfo is an mlfourd.ImagingInfo object and is required; it may be an aufbau object.
            
            this = this@mlfourd.AbstractInnerImagingFormat(varargin{:});
            
            this.logger_ = mlpipeline.Logger(this.fqfileprefix, this);
            if (~isempty(this.descrip))
                this.addLog(this.descrip);
            end
        end        
    end
    
    %% HIDDEN
    
    methods (Hidden)        
        function save__(this)
            this.save_nii;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
    
 end 
