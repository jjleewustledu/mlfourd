classdef AbstractDBase < handle
	%% ABSTRACTDBASE abstractions for DBase singletons, not itself a singleton design pattern
	%  Version $Revision$ was created $Date$ by $Author$  
 	%  and checked into svn repository $URL$ 
 	%  Developed on Matlab 7.11.0.584 (R2010b) 
 	%  $Id$ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Constant)
        FILETYPE_EXT = mlfourd.NIfTIInterface.FILETYPE_EXT;        
        FILETYPE     = mlfourd.NIfTIInterface.FILETYPE;
    end
    
    properties
 		counter   = 0;
        pid       = 'unknown';
        sid       = 'unknown';
        verbosity = 0; %% in range [0,1]
    end
    
    properties (Dependent)
        sidPath
        patientFolder
        patientPath     
        verbose
    end    

    methods (Static, Abstract)
        getInstance
    end
    
    methods (Static)
        function pnum = ensurePnum(id)
            
            %% ENSUREPNUM validates & converts to canonical forms as needed
            %  pnum = ConcreteDBase.ensurePnum(pnum)
            %  ^ pXXXX, int X                  ^ possibly longer string, patient-folder w/ p-number, double
            %    empty if unidentified
            pnum = [];
            switch(class(id))
                case 'char'
                    if (strncmpi('p', id, 1) && isnumeric(str2double(id(2:end))))
                        pnum = id;
                    end
                    s2d = str2double(id);
                    if (~isnan(s2d)) % SPOTRIAS
                        pnum = id;
                    end
                               % regexp for *_pXXXX_*, int X
                    [~, names] = regexpi(id, '[_]+(?<pnum>p[0-9]+)[_]+', 'tokens', 'names', 'once');
                    if (~isempty(struct2cell(names)))
                        pnum = names.pnum;
                    end
                case 'double'
                    if (                        isnumeric(id))
                        pnum = num2str(id);
                    end
                otherwise
                    error('mlfourd:InputParamErr', 'ensurePnum could not recognize id->%s\n', char(id));
            end
        end 
    end 
    
    methods        
        function        set.pid(this, id)
            tmp = mlfourd.AbstractDBase.ensurePnum(id);
            if (isempty(tmp))
                tmp = 'unknown';
            end            
            this.pid = tmp;
        end
        function        set.sid(this, id)
            if (isempty(id))
                id = 'unknown';
            end
            if (isnumeric(id))
                id = double2str(id);
            end
            this.sid = id;
        end
        function pth  = get.sidPath(this)
            idx = strfind(this.patientPath, this.sid);
            if (numel(idx) > 1); idx = idx(end); end
            pth = this.patientPath(1:idx+length(this.sid)-1);
        end
        function fld  = get.patientFolder(this)
            fld = pathparts(this.patientPath_, 1);
        end
        function pth  = get.patientPath(this)
            %% GET.PATIENTPATH always returns a trailing '/'
            if (isempty(this.patientPath_))
                this.patientPath_ = pwd;
            end
            pth = this.patientPath_;            
            if (~strcmp(filesep, pth(end))) % trailing '/'
                pth = [pth filesep];
            end
        end
        function        set.patientPath(this, pth)
            %% SET.PATIENTPATH also adds argument to matlab's path; sets only pwd if argument is empty
            if (isempty(pth))
                this.patientPath_ = pwd;
            else
                this.patientPath_ = pth;
                path(path, pth);
            end
            if (~exist( pth, 'dir'))
                error('mlfourd:IOErr', 'AbstractDBase.set.patientPath could not find %s\n', pth);
            end            
        end        
        function        disp(this)
            
            disp@handle(this);
            WHITE_SPACE = 25;
            frmt        = ['%' num2str(WHITE_SPACE) 's%s\n'];
            
            fprintf(1, 'Properties:\n');
            fprintf(1, frmt, this.method_label(@this.counter),       this.counter);
            fprintf(1, frmt, this.method_label(@this.pid),           this.pid);
            fprintf(1, frmt, this.method_label(@this.sid),           this.sid);
            fprintf(1, frmt, this.method_label(@this.sidPath),       this.sidPath);
            fprintf(1, frmt, this.method_label(@this.patientFolder), this.patientFolder);
            fprintf(1, frmt, this.method_label(@this.patientPath),   this.patientPath);
            fprintf(1, frmt, this.method_label(@this.verbosity), this.verbosity);
        end
    end 
    
    %% PROTECTED
    
    methods (Access = protected)
        function this = AbstractDBase
            %% CTOR must be consistent with singleton behavior in implemented subclasses
        end
        function s    = method_label(this, fhandle)            
            %% METHOD_LABEL pads methodnames so that all possible methodnames from DBase
            %  will be returned in char array s, right-justified, ending with ': '.
            %  Usage:  s = method_label(@functionname)
            
            fname    = func2str(   fhandle);
            idx      = strfind(    fname, '.');
            if ( length(idx) > 1);   idx = idx(1); end
            if (~isempty(idx));    fname = strtrim(fname(idx+1:end)); end
            idx2     = strfind(    fname, '(varargin{:})');
            if ( length(idx2) > 1); idx2 = idx2(1); end
            if (~isempty(idx2));   fname = strtrim(fname(1:idx2-1)); end
            s    = sprintf('%s: ', fname);
        end
    end 
	
    %% PRIVATE
    
    properties (Access = private)
        patientPath_
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
