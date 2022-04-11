classdef Viewer < mlfourd.IViewer
	%% VIEWER prepares viewer apps with mlfourd.NIfTId

	%  $Revision$
 	%  was created 22-Jul-2018 13:33:34 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		app
        fv
    end

    methods (Static)
        function [s,r] = view(varargin)
            % VIEW has this.app := 'fsleyes'.
            
            this = mlfourd.Viewer;
            [s,r] = this.aview(varargin{:});
        end
    end
    
	methods 
        function [s,r] = aview(this, varargin)
            targs = cell(size(varargin));
            todel = false(size(targs));
            for v = 1:length(varargin)
                [targs{v},todel(v)] = this.interpretTarget(varargin{v});
            end
            if any(contains(string(targs), ".mgz")) || any(contains(string(targs), ".mgh"))
                app_ = fullfile(getenv('FREESURFER_HOME'), 'bin', 'freeview');
                targs = convertStringsToChars(targs);
                [s,r] = mlbash(sprintf('%s %s', app_, cell2str(targs)));
            else
                targs = convertStringsToChars(targs);
                [s,r] = mlbash(sprintf('%s %s', this.app, cell2str(targs)));
            end
            
            for v = 1:length(varargin)
                if (todel(v))
                    this.deleteTemp(targs{v});
                end
            end
        end
        function deleteTemp(~, fn)
            deleteExisting([myfileprefix(fn) '*']);
        end
		  
 		function this = Viewer(varargin)
            app_ = fullfile(getenv('FSLDIR'), 'bin', 'fsleyes');
            
            ip = inputParser;
            addOptional(ip, 'app', app_, @ischar);
            addParameter(ip, 'temp_pattern', '', @istext)
            parse(ip, varargin{:});
            ipr = ip.Results;

            this.app = ipr.app;
            this.fv = mlfourdfp.FourdfpVisitor;
            this.temp_pattern = ipr.temp_pattern;
 		end
 	end 

    %% PROTECTED
    
    properties (Access = protected)
        temp_pattern
    end

    methods (Access = protected)
        function [interp,todel] = interpretTarget(this, targ)
            %  @return interp is intended for use by shell apps.  
            %  It will be char, string or cell.  Consider using cell2str(..., 'AsRow', true).
                        
            switch (class(targ))
                case 'cell'
                    [interp,todel] = cellfun(@(x) this.interpretTarget(x), targ, 'UniformOutput', false);
                    if iscell(todel)
                        todel = cell2mat(todel);
                    end
                case {'char' 'string'}
                    
                    % NIfTI extension .nii[.gz]
                    if (lstrfind(targ, '.nii'))
                        interp = targ;
                        todel = false;
                        return
                    end
                    
                    % 4dfp extensions
                    if (lstrfind(targ, '.4dfp.'))
                        interp = targ;
                        todel = false;
                        return
                    end
                    
                    % MGZ extension .mgz
                    if (lstrfind(targ, '.mgz'))
                        interp = targ;
                        todel = false;
                        return
                    end
                    
                    % no extension found
                    if isfile(strcat(targ, '.nii.gz'))
                        interp = strcat(targ, '.nii.gz');
                        todel = false;
                        return
                    end
                    if isfile(strcat(targ, '.nii'))
                        interp = strcat(targ, '.nii');
                        todel = false;
                        return
                    end
                    if isfile(strcat(targ, '.4dfp.img'))
                        interp = strcat(targ, '.4dfp.hdr');
                        todel = false;
                        return
                    end
                    
                    % command-line options
                    interp = targ;
                    todel = false;
                otherwise
                    if (isa(targ, 'mlfourd.ImagingContext2') || ...
                        isa(targ, 'mlfourd.ImagingFormatContext2'))
                        targ_temp = copy(targ);
                        targ_temp.fqfp = tempname;
                        targ_temp.filesuffix = '.nii.gz';
                        targ_temp.save();
                        interp = this.interpretTarget(targ.fqfilename);
                        todel = true;
                        return
                    end
                    error('mlfourd:ValueError', ...
                        'class(Viewer.interpretTarget.targ)->%s', class(targ));
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

