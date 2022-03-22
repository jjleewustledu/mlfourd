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
        function reorient2std(this, varargin)
            fqfn_ori = this.fqfn;

            % try to update _proc-enum1-enum2-enum3
            if contains(this.fileprefix, '_proc-')
                re = regexp(this.fileprefix, '\S+_(?<proc>proc-[0-9a-zA-Z\-]+)_\S+', 'names');
                if isempty(re)
                    re = regexp(this.fileprefix, '\S+_(?<proc>proc-[0-9a-zA-Z\-]+)', 'names');
                end
                this.fileprefix = strrep(this.fileprefix, re.proc, strcat(re.proc, '-orientstd'));
            else
                this.fileprefix = strcat(this.fileprefix, '_orientstd');
            end
            assert(contains(this.fileprefix, 'orientstd'))

            % fslreorient2std
            exec = fullfile(getenv('FSLDIR'), 'bin', 'fslreorient2std');
            cmd = sprintf('%s %s %s', exec, fqfn_ori, this.fqfn);
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
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
