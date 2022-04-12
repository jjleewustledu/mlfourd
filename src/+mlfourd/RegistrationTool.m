classdef RegistrationTool < handle & mlfourd.FilesystemTool
    %% REGISTRATIONTOOL uses minimal memory resources by avoiding loading imaging numerical data.
    %  
    %  Created 13-Mar-2022 13:23:18 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1873467 (R2021b) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    methods
        function forceneurological(this, varargin)
            exec = fullfile(getenv('FSLDIR'), 'bin', 'fslorient');
            cmd = sprintf('%s -forceneurological %s', exec, this.fqfilename);
            mlbash(cmd);
            this.addLog(cmd);
        end
        function forceradiological(this, varargin)
            exec = fullfile(getenv('FSLDIR'), 'bin', 'fslorient');
            cmd = sprintf('%s -forceradiological %s', exec, this.fqfilename);
            mlbash(cmd);
            this.addLog(cmd);
        end
        function this = fslroi(this, varargin)
            %% FSLROI is an adapter to FSL executables.
            %  N.B.: indexing (in both time and space) starts with 0 not 1! 
            %  N.B.: Inputting -1 for a size will set it to the full image extent for that dimension.
            %
            %  @param xmin|fac is required.  Solitary fac symmetrically sets Euclidean spatial size := fac*size
            %                  and symmetrically sets all min.
            %  @param xsize is optional.
            %  @param ymin  is optional.
            %  @param ysize is optional.
            %  @param zmin  is optional.
            %  @param zsize is optional.
            %  @param tmin  is optional.  Solitary tmin with tsize is supported.
            %  @param tsize is optional.
            
            ip = inputParser;
            addRequired(ip, 'xmin',      @isscalar);
            addOptional(ip, 'xsize', [], @isscalar);
            addOptional(ip, 'ymin',  [], @isscalar);
            addOptional(ip, 'ysize', [], @isscalar);
            addOptional(ip, 'zmin',  [], @isscalar);
            addOptional(ip, 'zsize', [], @isscalar);
            addOptional(ip, 'tmin',  [], @isscalar);
            addOptional(ip, 'tsize', [], @isscalar);
            parse(ip, varargin{:});            
            ipr = ip.Results;

            assert(isfile(this.fqfn))
            fqfn_ori = this.fqfn;

            % try to update _fslroi-enum1-enum2-enum3
            tag = this.tupleTag([ipr.xmin ipr.xsize ipr.ymin ipr.ysize ipr.zmin ipr.zsize ipr.tmin ipr.tsize]);
            if contains(this.fileprefix, '_fslroi-')
                re = regexp(this.fileprefix, '\S+(?<tag>_fslroi-[0-9a-zA-Z\-]+)_\S+', 'names');
                if isempty(re)
                    re = regexp(this.fileprefix, '\S+(?<tag>_fslroi-[0-9a-zA-Z\-]+)', 'names');
                end
                this.fileprefix = strrep(this.fileprefix, re.tag, strcat(re.tag, tag));
            else
                this.fileprefix = strcat(this.fileprefix, '_fslroi-', tag);
            end
            assert(contains(this.fileprefix, '_fslroi-'))

            % Usage: 
            %     fslroi <input> <output> <xmin> <xsize> <ymin> <ysize> <zmin> <zsize>
            %     fslroi <input> <output> <tmin> <tsize>
            %     fslroi <input> <output> <xmin> <xsize> <ymin> <ysize> <zmin> <zsize> <tmin> <tsize>            
            exec = fullfile(getenv('FSLDIR'), 'bin', 'fslroi');
            switch (nargin - 1)
                case 1
                    s     = size(this.contexth_);
                    rmin  = [floor([s(1) s(2) s(3)]*fac/2 - 1) 0];
                    rsize = [floor([s(1) s(2) s(3)]*fac) s(4)];
                    rnums = sprintf('%i %i %i %i %i %i %i %i', ...
                        rmin(1), rsize(1), rmin(2), rsize(2), rmin(3), rsize(3), rmin(4), rsize(4));
                case 2
                    rnums = sprintf('%i %i', ipr.tmin, ipr.tsize);
                case 6
                    rmin  = [ipr.xmin  ipr.ymin  ipr.zmin ];
                    rsize = [ipr.xsize ipr.ysize ipr.zsize];
                    rnums = sprintf('%i %i %i %i %i %i', ...
                        rmin(1), rsize(1), rmin(2), rsize(2), rmin(3), rsize(3));
                case 8
                    rmin  = [ipr.xmin  ipr.ymin  ipr.zmin  ipr.tmin];
                    rsize = [ipr.xsize ipr.ysize ipr.zsize ipr.tsize];
                    rnums = sprintf('%i %i %i %i %i %i %i %i', ...
                        rmin(1), rsize(1), rmin(2), rsize(2), rmin(3), rsize(3), rmin(4), rsize(4));
                otherwise
                    error('mlfourd:unsupportedNargin', 'RegistrationTool.fslreorient2std');
            end
            cmd = sprintf('%s %s %s %s', exec, fqfn_ori, this.fqfn, rnums);
            [s,r] = mlbash(cmd, 'echo', true);
            this.addLog(cmd);
            if s ~= 0
                disp(r);
                error('mlfourd:RuntimeError', 'RegistrationTool.fslreorient2std')
            end

            % copy json
            fqfn_ori_json = strcat(myfileprefix(fqfn_ori), '.json');
            if isfile(fqfn_ori_json)
                copyfile(fqfn_ori_json, strcat(this.fqfp, '.json'))
            end        
        end
        function reorient2std(this, varargin)

            % reuse existing
            if contains(this.fileprefix, '_orient-std')
                return
            end

            fqfn_ori = this.fqfn;

            % try to update _orient-enum1-enum2-enum3
            if contains(this.fileprefix, '_orient-')
                re = regexp(this.fileprefix, '\S+(?<orient>_orient-[0-9a-zA-Z\-]+)_\S+', 'names');
                if isempty(re)
                    re = regexp(this.fileprefix, '\S+(?<orient>_orient-[0-9a-zA-Z\-]+)', 'names');
                end
                this.fileprefix = strrep(this.fileprefix, re.orient, strcat(re.orient, '-std'));
            else
                this.fileprefix = strcat(this.fileprefix, '_orient-std');
            end
            assert(contains(this.fileprefix, '_orient-') && contains(this.fileprefix, 'std'))

            % fslreorient2std
            exec = fullfile(getenv('FSLDIR'), 'bin', 'fslreorient2std');
            cmd = sprintf('%s -m %s %s %s', exec, strcat(this.fqfp, '.mat'), fqfn_ori, this.fqfn);
            [s,r] = mlbash(cmd, 'echo', true);
            this.addLog(cmd);
            if s ~= 0
                disp(r);
                error('mlfourd:RuntimeError', 'RegistrationTool.fslreorient2std')
            end

            % copy json
            fqfn_ori_json = strcat(myfileprefix(fqfn_ori), '.json');
            if isfile(fqfn_ori_json)
                copyfile(fqfn_ori_json, strcat(this.fqfp, '.json'))
            end
        end
        function swaporient(this, varargin)
            exec = fullfile(getenv('FSLDIR'), 'bin', 'fslorient');
            cmd = sprintf('%s -swaporient %s', exec, this.fqfilename);
            mlbash(cmd);
            this.addLog(cmd);
        end

        function this = RegistrationTool(varargin)
            %  Args:
            %      contexth (ImagingContext2): handle to ImagingContexts of the state design pattern.
            %      imagingFormat (IImagingFormat): provides a filename for imaging data on the filesystem.  
            %  N.B. that handle classes are given to the encapsulated state, not copied, for performance.  
            
            this = this@mlfourd.FilesystemTool(varargin{:});
        end
    end

    %% PROTECTED

    methods (Access = protected)
        function tag = tupleTag(~, tup)
            assert(isnumeric(tup));
            tag = mat2str(tup);
            tag = strrep(tag, ' ', '-');
            tag = strrep(tag, '.', 'p');
            tag = strrep(tag, '[', '');
            tag = strrep(tag, ']', '');
        end
    end
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
