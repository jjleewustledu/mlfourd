classdef InnerNIfTIIO < mlfourd.NIfTIIO
	%% INNERNIFTIIO
    %  yet abstract:  noclobber
    
	%  $Revision$
 	%  was created $Date$
 	%  by $Author$, 
 	%  last modified $LastChangedDate$
 	%  and checked into repository $URL$, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id$
    
    properties (Abstract)
        imagingInfo % See also mlfourd.ImagingInfo   
        untouch        
    end
    
    methods (Abstract)
        addLog(this, lg)
    end

	properties (Dependent)
        filename
        filepath
        fileprefix 
        filesuffix
        fqfilename
        fqfileprefix
        fqfn
        fqfp
    end
    
    methods 
        
        %% SET/GET
        
        function this = set.filename(this, fn)
            assert(ischar(fn));
            [this.filepath,this.fileprefix,this.filesuffix] = myfileparts(fn);
        end
        function fn   = get.filename(this)
            fn = [this.fileprefix this.filesuffix];
        end
        function this = set.filepath(this, pth)
            assert(ischar(pth));
            if (~isempty(this.imagingInfo.filepath))
                this.untouch = false;
            end
            this.imagingInfo.filepath = pth;
            this.addLog('InnerNIfTIIO.set.filepath<-%s', pth);
        end
        function pth  = get.filepath(this)
            if (isempty(this.imagingInfo.filepath))
                pth = pwd; 
                return
            end
            pth = this.imagingInfo.filepath;
        end
        function this = set.fileprefix(this, fp)
            assert(ischar(fp));
            assert(~isempty(fp));
            if (~isempty(this.imagingInfo.fileprefix))
                this.untouch = false;
            end
            this.imagingInfo.fileprefix = fp;
            this.addLog('InnerNIfTIIO.set.fileprefix<-%s', fp);
        end
        function fp   = get.fileprefix(this)
            fp = this.imagingInfo.fileprefix;
        end
        function this = set.filesuffix(this, fs)
            assert(ischar(fs));
            if (~isempty(fs) && ~strcmp('.', fs(1)))
                fs = ['.' fs];
            end            
            if (~isempty(this.imagingInfo.filesuffix))
                this.untouch = false;
            end
            [~,~,this.imagingInfo.filesuffix] = myfileparts(fs);
            this.addLog('InnerNIfTIIO.set.filesuffix<-%s', fs);
        end
        function fs   = get.filesuffix(this)
            if (isempty(this.imagingInfo.filesuffix))
                fs = ''; return; end
            if (~strcmp('.', this.imagingInfo.filesuffix(1)))
                this.imagingInfo.filesuffix = ['.' this.imagingInfo.filesuffix]; end
            fs = this.imagingInfo.filesuffix;
        end
        function this = set.fqfilename(this, fqfn)
            assert(ischar(fqfn));
            [p,f,e] = myfileparts(fqfn);
            if (~isempty(p))
                this.filepath = p;
            end
            if (~isempty(f))
                this.fileprefix = f;
            end
            if (~isempty(e))
                this.filesuffix = e;
            end
        end
        function fqfn = get.fqfilename(this)
            fqfn = [this.fqfileprefix this.filesuffix];
        end
        function this = set.fqfileprefix(this, fqfp)
            assert(ischar(fqfp));
            [p,f] = fileprefixparts(fqfp);            
            if (~isempty(p))
                this.filepath = p;
            end
            if (~isempty(f))
                this.fileprefix = f;
            end
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
    end
    
    methods
        function c = char(this, varargin)
            c = this.fqfilename;
            c = c(varargin{:});
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

