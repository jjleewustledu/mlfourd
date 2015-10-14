classdef ImagingComponentState < mlfourd.ImagingState
	%% IMAGINGCOMPONENTSTATE   

	%  $Revision: 2627 $ 
 	%  was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingComponentState.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: ImagingComponentState.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	 
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
            f = this.imcomponent_.filename;
        end
        function f = get.filepath(this)
            f = this.imcomponent_.filepath;
        end
        function f = get.fileprefix(this)
            f = this.imcomponent_.fileprefix;
        end
        function f = get.filesuffix(this)
            f = this.imcomponent_.filesuffix;
        end
        function f = get.fqfilename(this)
            f = this.imcomponent_.fqfilename;
        end
        function f = get.fqfileprefix(this)
            f = this.imcomponent_.fqfileprefix;
        end
        function f = get.fqfn(this)
            f = this.imcomponent_.fqfn;
        end
        function f = get.fqfp(this)
            f = this.imcomponent_.fqfp;
        end    
        function f = get.mgh(this)            
            this.contextHandle_.changeState( ...
                mlfourd.MGHState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.mgh;
        end
        function f = get.nifti(this)  
            this.contextHandle_.changeState( ...
                mlfourd.NIfTIState.load(this.fqfilename, this.contextHandle_));
            f = this.contextHandle_.nifti;
        end
        function f = get.imcomponent(this)
            assert(~isempty(this.imcomponent_));
            f = this.imcomponent_.clone;
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
        function this = load(imcmp0, h)
            import mlfourd.*;
            if (~isa(imcmp0, 'mlfourd.ImagingComponent'))
                imcmp = ImagingComponent.load(imcmp0); 
            else
                imcmp = imcmp0;
            end
            this = ImagingComponentState;
            this.imcomponent_ = imcmp.clone;
            this.contextHandle_ = h;
        end
    end 
    
	methods
        function this = save(this)
            imcmp = this.imcomponent_;
            null  = imcmp.save; %% KLUDGE
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(this.imcomponent_.fqfilename, this.contextHandle_));
        end
        function this = saveas(this, f)
            this.imcomponent_ = this.imcomponent_.saveas(f);
            this.contextHandle_.changeState( ...
                mlfourd.ImagingLocation.load(this.imcomponent_.fqfilename, this.contextHandle_));
        end
 	end 

	properties (Access = 'private')
        imcomponent_
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

