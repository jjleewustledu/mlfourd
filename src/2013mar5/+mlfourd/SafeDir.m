classdef SafeDir 
	%% SAFEDIR decorates the struct arrays available for built-in dir
    %  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/SafeDir.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: SafeDir.m 1231 2012-08-23 21:21:49Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        dirPath
        dirList
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

        % mimic results from built-in dir
 		function sref = subsref( this, subs)
            if (length(subs) > 1)
                sref = this.subsref(subs(1:end-1));
            else
            switch (subs.type)
                case '()'
                    sref = this.dirList(subs.subs{:});
                case '.'
                    sref = this.dirList.(subs.subs);
                otherwise
                    error('mlfourd:SubsrefErr', 'SafeDir');
            end
            end
 		end % subsref
        function this = subsasgn(this, subs, val)
            switch (subs.type)
                case '()'
                    this.dirList(subs.subs{:}) = val;
                case '.'
                    this.dirList.(subs.subs) = val;
                otherwise
                    error('mlfourd:SubsasgnErr', 'SafeDir');
            end
        end % subsasgn
        
        % preferred interface
        function sarr = files(this)
            sarr = this.dirList( ...
                        ~this.dirList.isdir && ~strncmp('.', this.dirList.name, 1));
        end
        function sarr = directories(this)
            sarr = this.dirList( ...
                        this.dirList.isdir && ~strncmp('.', this.dirList.name, 1));
        end
        function sarr = invisibleFiles(this)
            sarr = this.dirList( ...
                        ~this.dirList.isdir &&  strncmp('.', this.dirList.name, 1));
        end
        function sarr = invisibleDirectories(this)
            sarr = this.dirList( ...
                        this.dirList.isdir &&  strncmp('.', this.dirList.name, 1));
        end
        
 		function this = SafeDir(str) 
 			%% SAFEDIR 
 			%  Usage:  expects arguments identical to dir 
            
            this.dirPath = str;
            this.dirList       = dir(str);
 		end % SafeDir (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

