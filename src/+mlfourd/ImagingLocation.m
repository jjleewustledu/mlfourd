classdef ImagingLocation < mlfourd.ImagingState & mlio.AbstractSimpleIO
	%% IMAGINGLOCATION   
    %  See also:  mlfourd.ImagingState,  mlfourd.ImagingContext, mlfourd.NIfTIState, mlfourd.NIfTIdState, mlfourd.MGHState, 
    %             mlfourd.ImagingComponentState, mlpatterns.State

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingLocation.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingLocation.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	
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
        composite
        nifti        
        niftid
    end
    
    methods %% Set/Get
        function fn   = get.filename(this)
            fn = [this.fileprefix this.filesuffix];
        end
        function pth  = get.filepath(this)
            if (isempty(this.filepath_))
                this.filepath_ = pwd; end
            pth = this.filepath_;
        end
        function fp   = get.fileprefix(this)
            fp = this.fileprefix_;
        end
        function fs   = get.filesuffix(this)
            if (isempty(this.filesuffix_))
                fs = ''; return; end
            if (~strcmp('.', this.filesuffix_(1)))
                this.filesuffix_ = ['.' this.filesuffix_]; end
            fs = this.filesuffix_;
        end
        function fqfn = get.fqfilename(this)
            fqfn = [this.fqfileprefix this.filesuffix];
        end
        function fqfp = get.fqfileprefix(this)
            fqfp = fullfile(this.filepath, this.fileprefix);
        end
        function f    = get.fqfn(this)
            f = this.fqfilename;
        end
        function f    = get.fqfp(this)
            f = this.fqfileprefix;
        end
        function tf   = get.noclobber(this)
            tf = this.noclobber_;
        end    
        function f    = get.composite(this)
            this.contextH_.changeState( ...
                mlfourd.ImagingComponentState.load(this.fqfilename, this.contextH_));
            f = this.contextH_.composite;
        end
        function f    = get.nifti(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIState.load(this.fqfilename, this.contextH_));
            f = this.contextH_.nifti;
        end
        function f    = get.niftid(this)
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState.load(this.fqfilename, this.contextH_));
            f = this.contextH_.niftid;
        end
        
        function this = set.filename(this, fn)
            [this.filepath,this.fileprefix,this.filesuffix] = myfileparts(fn);
        end
        function this = set.filepath(this, pth)
            if (~isempty(pth))
                if (~strcmp('/', pth(end)))
                    pth = [pth '/']; end
                this.filepath_ = fileparts(pth);
            end
        end
        function this = set.fileprefix(this, fp)
            [~,this.fileprefix_] = myfileparts(fp);
        end
        function this = set.filesuffix(this, fs)
            if (~isempty(fs))
                assert(strcmp('.', fs(1)));
                [~,~,fs] = myfileparts(fs);
                this.filesuffix_ = fs;
            end
        end
        function this = set.fqfilename(this, fqfn)
            [this.filepath,this.fileprefix,this.filesuffix] = myfileparts(fqfn);           
        end
        function this = set.fqfileprefix(this, fqfp)
            [this.filepath, this.fileprefix] = myfileparts(fqfp);
        end
        function this = set.fqfn(this, f)
            this.fqfilename = f;
        end
        function this = set.fqfp(this, f)
            this.fqfileprefix = f;
        end
        function this = set.noclobber(this, nc)
            assert(islogical(nc));
            this.noclobber_ = nc;
        end
        function this = set.composite(this, f)
            this.contextH_.changeState( ...
                mlfourd.ImagingComponentState.load(this.fqfilename, this.contextH_));
            this.contextH_.composite = f;
        end
        function this = set.nifti(this, f)
            this.contextH_.changeState( ...
                mlfourd.NIfTIState.load(this.fqfilename, this.contextH_));
            this.contextH_.nifti = f;
        end
        function this = set.niftid(this, f)
            this.contextH_.changeState( ...
                mlfourd.NIfTIdState.load(this.fqfilename, this.contextH_));
            this.contextH_.niftid = f;
        end
    end 

    methods (Static)
        function this = load(fname, h)
            this = mlfourd.ImagingLocation;
            this.fqfilename = fname;
            this.contextH_ = h;            
        end
    end
    
	methods 
        function this = save(this)
            mlbash(sprintf('touch %s', this.fqfilename));
        end
        function this = saveas(this, filstr)
            this.fqfilename = filstr;
            this.save;
        end
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this = ImagingLocation
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

