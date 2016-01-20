classdef NIfTIdIO < mlfourd.NIfTIIO
	%% NIFTIDIO 
    
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$

	properties (Dependent)
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
        noclobber
    end
    
    methods %% Set/Get
        function this = set.filename(this, fn)
            assert(ischar(fn));
            [this.filepath,this.fileprefix,this.filesuffix] = myfileparts(fn);
        end
        function fn   = get.filename(this)
            fn = [this.fileprefix this.filesuffix];
        end
        function this = set.filepath(this, pth)
            assert(ischar(pth));
            this.filepath_ = pth;
        end
        function pth  = get.filepath(this)
            if (isempty(this.filepath_))
                this.filepath_ = pwd; 
            end
            pth = this.filepath_;
        end
        function this = set.fileprefix(this, fp)
            assert(ischar(fp));
            [~,this.fileprefix_] = myfileparts(fp);
        end
        function fp   = get.fileprefix(this)
            fp = this.fileprefix_;
        end
        function this = set.filesuffix(this, fs)
            assert(ischar(fs));
            if (~isempty(fs) && ~strcmp('.', fs(1)))
                fs = ['.' fs];
            end
            this.filesuffix_ = fs;
        end
        function fs   = get.filesuffix(this)
            fs = this.filesuffix_;
        end
        function this = set.fqfilename(this, fqfn)
            assert(ischar(fqfn));
            [this.filepath,this.fileprefix,this.filesuffix] = myfileparts(fqfn);           
        end
        function fqfn = get.fqfilename(this)
            fqfn = [this.fqfileprefix this.filesuffix];
        end
        function this = set.fqfileprefix(this, fqfp)
            assert(ischar(fqfp));
            [this.filepath, this.fileprefix] = myfileparts(fqfp);
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = fullfile(this.filepath, this.fileprefix);
        end
        function this = set.fqfn(this, f)
            this.fqfilename = f;
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function this = set.fqfp(this, f)
            this.fqfileprefix = f;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end
        function this = set.noclobber(this, nc)
            assert(islogical(nc));
            this.noclobber_ = nc;
        end
        function tf   = get.noclobber(this)
            tf = this.noclobber_;
        end
    end
    
    %% PROTECTED
    
    properties (Abstract, Access = protected)
        filepath_
        fileprefix_
        filesuffix_
        noclobber_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

