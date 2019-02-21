classdef ReferenceMprage 
	%% REFERENCEMPRAGE  

	%  $Revision$
 	%  was created 25-Jul-2018 15:08:56 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    properties (Constant)
        DATAROOT = fullfile(getenv('HOME'), 'MATLAB-Drive', 'mlfourd', 'data', '')
        FILEPREFIX = 't1_dcm2niix'
        FILEPREFIX2 = '001'
        FILEPREFIX3 = 'T1'
    end
    
    properties (Dependent)
        asStruct
        asSurfStruct
    end

	methods (Static)
        function copyfiles(dest, varargin)
            assert(isfolder(dest));
            import mlfourd.*;
            suf = {'.nii.gz' '.4dfp.hdr' '.4dfp.ifh' '.4dfp.img' '.4dfp.img.rec'};
            for s = 1:length(suf)
                if (~lexist(fullfile(dest,                      [ReferenceMprage.FILEPREFIX suf{s}]), 'file'))
                    copyfile(fullfile(ReferenceMprage.DATAROOT, [ReferenceMprage.FILEPREFIX suf{s}]), ...
                        dest, varargin{:});
                end
            end
            suf2 = ['.mgz' suf]; 
            for s = 1:length(suf2)
                try
                    if (~lexist(fullfile(dest,                      [ReferenceMprage.FILEPREFIX2 suf2{s}]), 'file'))
                        copyfile(fullfile(ReferenceMprage.DATAROOT, [ReferenceMprage.FILEPREFIX2 suf2{s}]), ...
                            dest, varargin{:});
                    end
                catch ME
                    handwarning(ME);
                end
            end
            for s = 1:length(suf2)
                try
                    if (~lexist(fullfile(dest,                      [ReferenceMprage.FILEPREFIX3 suf2{s}]), 'file'))
                        copyfile(fullfile(ReferenceMprage.DATAROOT, [ReferenceMprage.FILEPREFIX3 suf2{s}]), ...
                            dest, varargin{:});
                    end
                catch ME
                    handwarning(ME);
                end
            end
        end
        function g = dicomAsNii
            import mlfourd.*;
            g = [ReferenceMprage.FILEPREFIX '.nii'];
        end
        function g = dicomAsNiigz
            import mlfourd.*;
            g = [ReferenceMprage.FILEPREFIX '.nii.gz'];
        end
        function g = dicomAsFourdfp
            import mlfourd.*;
            g = [ReferenceMprage.FILEPREFIX '.4dfp.hdr'];
        end
        function g = fqfileprefix
            import mlfourd.*;
            g = fullfile(ReferenceMprage.DATAROOT, ReferenceMprage.FILEPREFIX);
        end
        function g = surferAsMgz
            import mlfourd.*;
            g = [ReferenceMprage.FILEPREFIX2 '.mgz'];
        end
        function g = surferAsNii
            import mlfourd.*;
            g = [ReferenceMprage.FILEPREFIX2 '.nii'];
        end
        function g = surferAsNiigz
            import mlfourd.*;
            g = [ReferenceMprage.FILEPREFIX2 '.nii.gz'];
        end
        function g = surferAsFourdfp
            import mlfourd.*;
            g = [ReferenceMprage.FILEPREFIX2 '.4dfp.hdr'];
        end
        function g = T1AsMgz
            import mlfourd.*;
            g = fullfile(ReferenceMprage.DATAROOT, [ReferenceMprage.FILEPREFIX3 '.mgz']);
        end
        function g = T1AsNiigz
            import mlfourd.*;
            g = fullfile(ReferenceMprage.DATAROOT, [ReferenceMprage.FILEPREFIX3 '.nii.gz']);
        end
        function g = T1AsFourdfp
            import mlfourd.*;
            g = fullfile(ReferenceMprage.DATAROOT, [ReferenceMprage.FILEPREFIX3 '.4dfp.hdr']);
        end
    end 
    
    methods
        
        %% GET
        
        function g = get.asStruct(this)
            g = this.asstruct_;
        end
        function g = get.asSurfStruct(this)
            g = this.asstruct2_;
        end
        
        %%
        
        function this = ReferenceMprage
            import mlniftitools.*;
            this.asstruct_  = load_untouch_nii(fullfile(this.DATAROOT, this.dicomAsNiigz));
            this.asstruct2_ = load_untouch_nii(fullfile(this.DATAROOT, this.surferAsNiigz));
        end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        asstruct_
        asstruct2_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

