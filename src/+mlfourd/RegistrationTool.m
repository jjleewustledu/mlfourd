classdef RegistrationTool < handle & mlfourd.FilesystemTool
    %% REGISTRATIONTOOL uses minimal memory resources by avoiding loading imaging numerical data.
    %  
    %  Created 13-Mar-2022 13:23:18 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
    %  Developed on Matlab 9.11.0.1873467 (R2021b) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    methods
        function ensureNifti(this)
            if ~strcmp(this.filesuffix, '.nii.gz')
                ic = mlfourd.ImagingContext2(this.fqfilename);
                ic.selectNiftiTool();
                ic.save();
                this.filesuffix = ic.filesuffix;
            end
        end
        function forceneurological(this, varargin)
            this.ensureNifti();
            cmd = sprintf('fslorient -forceneurological %s', this.fqfilename);
            mlbash(cmd);
            this.addLog(cmd);
        end
        function forceradiological(this, varargin)
            this.ensureNifti();
            cmd = sprintf('fslorient -forceradiological %s', this.fqfilename);
            mlbash(cmd);
            this.addLog(cmd);
        end
        function reorient2std(this, varargin)
            this.ensureNifti();
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

            % fslreorient2std
            cmd = sprintf('fslreorient2std %s %s', fqfn_ori, this.fqfn);
            mlbash(cmd);
            this.addLog(cmd);

            % copy json
            fqfn_ori_json = strcat(myfileprefix(fqfn_ori), '.json');
            if isfile(fqfn_ori_json)
                copyfile(fqfn_ori_json, strcat(this.fqfp, '.json'))
            end
        end
        function swaporient(this, varargin)
            this.ensureNifti();
            cmd = sprintf('fslorient -swaporient %s', this.fqfilename);
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
