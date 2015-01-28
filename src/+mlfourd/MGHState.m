classdef MGHState < mlfourd.ImagingState 
	%% MGHSTATE   

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
        
        mgh
        nifti	
        imcomponent	 
    end 
    
	methods % GET/SET
        function f = get.filename(this)
            f = this.mgh_.filename;
        end
        function f = get.filepath(this)
            f = this.mgh_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.mgh_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.mgh_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.mgh_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.mgh_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.mgh_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.mgh_.fqfp;
        end    
        function f = get.mgh(this)
            assert(~isempty(this.mgh_));
            f = this.mgh_.clone;
        end
        function f = get.nifti(this)
            this.contextHandle_.changeState( ...
                mlfourd.NIfTIState.load( ...
                    mlsurfer.MGH.mghFilename2niiFilename(this.fqfilename), this.contextHandle_));
            f = this.contextHandle_.nifti;
        end
        function f = get.imcomponent(this)
            this.contextHandle_.changeState( ...
                mlfourd.ImagingComponentState.load( ...
                    mlsurfer.MGH.mghFilename2niiFilename(this.fqfilename), this.contextHandle_));
            f = this.contextHandle_.imcomponent;
        end
        
        function this = set.filename(this, f)
            [~,fp,fs] = gzfileparts(f);
            f = [fp fs];
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(fullfile(this.filepath, f), this.contextHandle_));
        end        
        function this = set.filepath(this, f)
            if (~strcmp('/', f(end)))
                f = [f '/']; end
            f = fileparts(f);
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(fullfile(f, this.filename), this.contextHandle_));
        end
        function this = set.fileprefix(this, f)
            [~,f] = fileparts(f);
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(fullfile(this.filepath, filename(f)), this.contextHandle_));
        end        
        function this = set.filesuffix(this, f)
            assert(ischar(f));
            [~,~,f] = gzfileparts(f);
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(fullfile(this.filepath, [this.fileprefix f]), this.contextHandle_));
        end        
        function this = set.fqfilename(this, f)
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(f, this.contextHandle_));
        end        
        function this = set.fqfileprefix(this, f)
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(filename(f), this.contextHandle_));
        end        
        function this = set.fqfn(this, f)
            this.fqfilename = f;
        end        
        function this = set.fqfp(this, f)
            this.fqfileprefix = f;
        end     
        function this = set.mgh(this, f)
            assert(isa(f, 'mlsurfer.MGH'));
            this.contextHandle_.changeState( ...
                mlfourd.MGHState.load(f, this.contextHandle_));
        end
        function this = set.nifti(this, f)
            assert(isa(f, 'mlfourd.NIfTIInterface'));
            this.contextHandle_.changeState( ...
                mlfourd.NIfTIState.load(f, this.contextHandle_));
        end
        function this = set.imcomponent(this, f)
            assert(isa(f, 'mlfourd.ImagingComponent'));
            this.contextHandle_.changeState( ...
                mlfourd.ImagingComponentState.load(f, this.contextHandle_));
        end
    end 
    
	methods (Static)
        function this = load(mgh, h)
            if (~isa(mgh, 'mlsurfer.MGH'))
                mgh = mlsurfer.MGH.load(mgh); end
            this = mlfourd.MGHState;
            this.mgh_ = mgh.clone;
            this.contextHandle_ = h;
        end
    end 

	methods
        function this = save(this)
            this.mgh_.save;
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(this.mgh_.fqfilename, this.contextHandle_));
        end
        function this = saveas(this, f)
            this.mgh_ = this.mgh_.saveas(f);
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(this.mgh_.fqfilename, this.contextHandle_));
        end
 	end 

	properties (Access = 'private')
        mgh_
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

