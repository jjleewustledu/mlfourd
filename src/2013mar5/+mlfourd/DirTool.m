classdef DirTool 
	%% DIRTOOL decorates the struct arrays available for built-in dir
    %  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $,
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/DirTool.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: DirTool.m 2318 2013-01-20 06:52:48Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
        itsPath
        itsDirlist
    end

    methods (Static)
        
        % filesystem methods
        function [S,R] = rm(ca, flags)
            import mlfourd.*;
            if (~exist('flags','var'));    flags  = ''; end
            if (DirTool.hasflags(ca)); [ca,flags] = DirTool.swap(ca, flags); end     
            ca = ensureCell(ca);
            try
                [S,R] = cellfun(@(x) mlbash(['rm ' flags ' ' x]),          ca, 'UniformOutput', false);
            catch ME
                handexcept(ME);
            end
        end
        function [S,R] = cp(ca, dest, flags)
            import mlfourd.*;    
            if (~exist('flags','var'));        flags  = ''; end        
            if (DirTool.hasflags(ca));   [ca,  flags] = DirTool.swap(ca,   flags); end  
            if (DirTool.hasflags(dest)); [dest,flags] = DirTool.swap(dest, flags); end 
            ca = ensureCell(ca);
            try
                [S,R] = cellfun(@(x) mlbash(['cp ' flags ' ' x ' ' dest]), ca, 'UniformOutput', false);
            catch ME
                handexcept(ME);
            end
        end
        function [S,R] = mv(ca, dest, flags)
            import mlfourd.*;
            if (~exist('flags','var'));        flags  = ''; end
            if (DirTool.hasflags(ca));   [ca,  flags] = DirTool.swap(ca,   flags); end  
            if (DirTool.hasflags(dest)); [dest,flags] = DirTool.swap(dest, flags); end 
            ca = ensureCell(ca);
            try
                [S,R] = cellfun(@(x) mlbash(['mv ' flags ' ' x ' ' dest]), ca, 'UniformOutput', false);
            catch ME
                handexcept(ME);
            end
        end
    end
    
	methods 
        function pth  = get.itsPath(this)
            tokpth = strtok(this.itsPath, '*');
            if (lexist(tokpth))
                pth = tokpth;
            else
                pth = fileparts(tokpth);
            end
        end
        
        % return struct-arrays
        function sarr = files2sa(this, idx)
            sarr = this.pathDecoration( ...
                   this.itsDirlist(~this.isdir & ~this.invisible));
            if (exist('idx','var')); sarr = sarr(idx); end
        end
        function sarr = directories2sa(this, idx)
            sarr = this.pathDecoration( ...
                   this.itsDirlist( this.isdir & ~this.invisible));
            if (exist('idx','var')); sarr = sarr(idx); end
        end
        function sarr = invisibleFiles2sa(this, idx)
            sarr = this.pathDecoration( ...
                   this.itsDirlist(~this.isdir &  this.invisible));
            if (exist('idx','var')); sarr = sarr(idx); end
        end
        function sarr = invisibleDirectories2sa(this, idx)
            sarr = this.pathDecoration( ...
                   this.itsDirlist( this.isdir &  this.invisible));
            if (exist('idx','var')); sarr = sarr(idx); end
        end
        
        % return cell-arrays
        function pp   = paths(this, idx)
            sarr = this.files2sa;
            pp   = cell(1,length(sarr));
            for s = 1:length(sarr)
                pp{s} = sarr(s).itsPath;
            end
            if (exist('idx','var'))
                pp = pp{idx}; 
            else
                pp = ensureCell(pp);
            end
        end
        function ff   = fqfns(this, idx)
            sarr = this.files2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlfourd.DirTool.fqname(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function ff   = fns(  this, idx)
            sarr = this.files2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlfourd.DirTool.name(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function ff   = fqdns(this, idx)
            sarr = this.directories2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlfourd.DirTool.fqname(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function ff   = dns(  this, idx)
            sarr = this.directories2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlfourd.DirTool.name(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function len  = length(this)
            len = length(this.itsDirlist);
        end
        
 		function this = DirTool(str) 
 			%% DirTool 
 			%  Usage:  expects arguments identical to dir
            
            if (~ischar(str))
                str = imcast(str, 'char'); end
            [p1,p2,~] = filepartsx(str, mlfourd.AbstractImage.FILETYPE_EXT);
            this.itsPath = fullfile(p1, p2, '');
            if (isempty(this.itsPath))
                this.itsPath = pwd;
            end
            this.itsDirlist = dir(str);
 		end % DirTool (ctor) 
    end 
    
    %% PRIVATE
    
    methods (Access = 'private', Static)
        
        function tf    = hasflags(obj)
            if (ischar(obj) && strncmp('-', obj, 1))
                tf = true;
            else
                tf = false;
            end
        end
        function [a,b] = swap(a, b)
            tmp = a;
            a   = b;
            b   = tmp;
        end
        function ff    = fqname(strct)
            ff = fullfile(strct.itsPath, strct.name, '');
        end
        function ff    = name(strct)
            ff = strct.name;
        end
    end
    
    methods (Access = 'private')
        
        function z    = zerosVec(this)
            z = zeros(1,length(this.itsDirlist));
        end
        function tf   = isdir(this)
            tf = this.zerosVec;
            for z = 1:length(tf) %#ok<FORFLG>
                tf(z) = this.itsDirlist(z).isdir; %#ok<PFBNS>
            end
        end
        function tf   = invisible(this)
            tf = this.zerosVec;
            for z = 1:length(tf) %#ok<FORFLG>
                tf(z) = strncmp('.', this.itsDirlist(z).name, 1); %#ok<PFBNS>
            end
        end
        function sarr = pathDecoration(this, sarr)
            for s = 1:length(sarr) %#ok<FORFLG>
                sarr(s).itsPath = this.itsPath; %#ok<PFBNS>
            end
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

