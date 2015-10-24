classdef FilesystemRegistry < mlpatterns.Singleton
	%% FILESYSTEMREGISTRY is a singleton providing filesystem utilities	 
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/FilesystemRegistry.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: FilesystemRegistry.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    methods (Static)
        
        function this = instance(varargin)
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            %  Usage:   obj = FilesystemRegistry.instance([qualifier, qualifier2, ...])
            %                                              e.g., 'initialize'
            persistent uniqueInstance
            
            for v = 1:length(varargin) %#ok<*FORFLG>
                if (strcmp(varargin{v}, 'initialize'))
                    uniqueInstance = []; 
                end
            end
            if (isempty(uniqueInstance))
                this = mlfourd.FilesystemRegistry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end % static instance
        
        function cwd  = scd(targetfold)
            
            %% SCD is a static wrapper to Matlab's cd.  
            %  It makes targetfold as needed, handles exceptions as needed and displays messages to console
            %  Usage:  cwd = FilesystemRegistry.cd(targetfold)
            try
                targetfold = ensureFolderExists(targetfold);
                try
                    cwd = cd(targetfold); %#ok<MCCD>
                    warning('mlfourd:IO', 'FilesystemRegistry.scd changed dir to %s\n', cwd);
                catch ME
                    handexcept(ME, 'FilesystemRegistry.scd failed to cd to %s\n', targetfold);
                end
            catch ME2
                handexcept(ME2, 'FilesystemRegistry.scd could not access %s from %s\n', targetfold, pwd);
            end
        end % static scd 
        function pth  = composePath(pth, fld)
            
            %% COMPOSEPATH appends a path with a folder, dropping duplicate folder names
            %  Usage:  pth = FilesystemRegistry.composePath(pth, fld)
            import mlfsl.*;
            try
                assert(~lstrfind(pth, fld));
            catch ME
                handwarning(ME, 'composePath.pth->%s, fld->%s', pth, fld);
                indices = strfind(pth, fld);
                pth     = pth(1:indices(1)-1);
                fprintf('truncating pth to %s', pth);
            end
            pth = ensureFolderExists(fullfile(pth, fld, ''));
        end % static composePath
        function s    = extractNestedFolders(pth, patt)
            %% EXTRACTNESTEDFOLDERS finds folders with string-pattern in the specified filesystem path
            %  and moves the folders to the path (flattens)
            %  Usage:  status = FilesystemRegistry.extractNestedFolders(path, string_pattern)
            
            s = 0;
            if (lstrfind(pth, patt))
                try
                    dlist = mlfourd.DirTool(fullfile(pth, '*', ''));
                    for d = 1:length(dlist.fqdns) %#ok<*FORFLG>
                        [s,msg,mid] = movefile(dlist.fqdns{d}, fullfile(pth, '..', ''));
                    end
                catch ME
                    handexcept(ME, msg, mid);
                end
            end
        end % static extractNestedFolders
        function ca   = textfileToCell(fqfn, eol) 
            if (~exist('eol','var'))
                fget = @fgetl;
            else
                fget = @fgets;
            end
            ca = {[]};
            try
                fid = fopen(fqfn);
                i   = 1;
                while 1
                    tline = fget(fid);
                    if ~ischar(tline), break, end
                    ca{i} = tline;
                    i     = i + 1;
                end
                fclose(fid);
            catch ME
                handexcept(ME);
            end
            if (isempty(ca) || isempty(ca{1}))
                error('mlfourd:IOError', '%s was empty', fqfn);
            end
        end % static textfileToCell
        function tf = textfileStrcmp(fqfn, str)
            ca = mlfourd.FilesystemRegistry.textfileToCell(fqfn, true);
            castr = '';
            for c = 1:length(ca)
                castr = [castr ca{c}]; %#ok<AGROW>
            end
            tf = strcmp(strtrim(castr), strtrim(str));
        end
    end
    
	methods (Access = 'private')
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 

 		function this = FilesystemRegistry() 
 			%% FILESYSTEMREGISTRY (ctor) is private to enforce instantiation through instance            
            this = this@mlpatterns.Singleton;
 		end % FilesystemRegistry (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
