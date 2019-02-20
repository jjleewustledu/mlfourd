classdef Viewer 
	%% VIEWER prepares viewer apps with mlfourd.NIfTId

	%  $Revision$
 	%  was created 22-Jul-2018 13:33:34 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		app = 'freeview'
        fv
    end

    methods (Static)
        function [s,r] = view(varargin)
            % VIEW has this.app := 'freeview'.
            
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
            
            [s,r] = mlbash(sprintf('%s %s', this.app, cell2str(targs, 'AsRow', true)));
            
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
            ip = inputParser;
            addOptional(ip, 'app', 'freeview', @ischar);
            parse(ip, varargin{:});
            this.app = ip.Results.app;
            this.fv = mlfourdfp.FourdfpVisitor;
 		end
 	end 

    %% PROTECTED
    
    methods (Access = protected)
        function fqt = fqtarget(~, t)
            fqt = [myfileprefix(t) '.nii'];
        end
        function fn = constructTmpNii(this, fn)
            fn_ = tempFqfilename(fn);
            copyfile_4dfp(fn, fn_);
            this.fv.nifti_4dfp_n(fn_);
            fn = this.fqtarget(fn_);
        end
        function [interp,todel] = interpretTarget(this, targ)
            %  @return interp is intended for use by shell apps.  
            %  It will be char, string or cell.  Consider using cell2str(..., 'AsRow', true).
                        
            switch (class(targ))
                case 'cell'
                    [interp,todel] = cellfun(@(x) this.interpretTarget(x), targ, 'UniformOutput', false);
                case {'char' 'string'}
                    
                    % 4dfp extensions
                    if (lstrfind(targ, '.4dfp.'))
                        interp = this.constructTmpNii(targ);
                        todel = true;
                        return
                    end
                    
                    % no extension found
                    if (lexist([targ '.nii'], 'file'))
                        interp = [targ '.nii'];
                        todel = false;
                        return
                    end
                    if (lexist([targ '.nii.gz'], 'file'))
                        interp = [targ '.nii.gz'];
                        todel = false;
                        return
                    end
                    if (lexist([targ '.4dfp.img'], 'file'))
                        interp = this.constructTmpNii(targ);
                        todel = true;
                        return
                    end
                    
                    % NIfTI extension .nii[.gz]
                    if (lstrfind(targ, '.nii'))
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
                    
                    % command-line options
                    interp = targ;
                    todel = false;
                otherwise
                    if false % (~isdeployed)
                        if (isa(targ, 'mlfourd.ImagingContext')) %#ok<UNRCH>
                            if (~lexist(targ.fqfilename))
                                targ.filesuffix = '.nii';
                                targ.save;
                            end
                            [interp,todel] = this.interpretTarget(targ.fqfilename);
                            return
                        end
                    end
                    if (isa(targ, 'mlfourd.ImagingContext2') || ...
                        isa(targ, 'mlfourd.INIfTI'))
                        if (~lexist(targ.fqfilename))
                            targ.filesuffix = '.nii';
                            targ.save;
                        end
                        [interp,todel] = this.interpretTarget(targ.fqfilename);
                        return
                    end
                    error('mlfourd:unsupportedSwitchcase', ...
                        'class(Viewer.interpretTarget.targ)->%s', class(targ));
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

