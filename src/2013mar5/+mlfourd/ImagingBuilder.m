classdef ImagingBuilder 
	%% IMAGINGBUILDER is an abstract interface, a builder design pattern
    %  Version $Revision: 2318 $ was created $Date: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-20 00:52:48 -0600 (Sun, 20 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ImagingBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImagingBuilder.m 2318 2013-01-20 06:52:48Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    properties
        imagingProduct        
        useKL     = false;
        baseBlur  = mlfsl.PETBuilder.petPointSpread;
        blockSize = [1 1 1];
    end
    
    properties (Dependent)
        references
        reference
        onRefsSuffixes
        onRefSuffix
        onFolders
        onFolder
        ref_fps
        ref_fp
        ref_fns
        ref_fn
        
        blurSuffix
        blockSuffix
        fgnii
    end
    
    properties (SetAccess = 'protected')
        namingRegistry_  
        references_  = {'t1_rot'};
        fgnii_
    end
    
    methods (Static)        
        function b = createFromImaging(~)
            b = mlfourd.ImagingBuilder;
        end
    end % static methods 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 
 		
        function this = set.baseBlur(this, blr)
            %% SET.BLOCKSIZE adds singleton dimensions as needed to fill 3D
            assert(isnumeric(blr));
            switch (numel(blr))
                case 1
                    if (blr < norm(mlfsl.PETBuilder.petPointSpread))
                        this.baseBlur = mlfsl.PETBuilder.petPointSpread;
                    else
                        this.baseBlur = [blr blr blr];
                    end
                case 2
                    this.baseBlur = [blr(1) blr(2) 1];
                case 3
                    this.baseBlur = [blr(1) blr(2) blr(3)];
                otherwise
                    this.baseBlur = [0 0 0];
            end
        end % set.baseBlur
        function bb   = get.baseBlur(this)
            bb = this.baseBlur;
        end % get.baseBlur
        function suff = get.blurSuffix(this)
            bB   = this.baseBlur;
            suff = ['_' num2str(bB(1),1) 'x' num2str(bB(2),1) 'x' num2str(bB(3),1) 'blur'];
        end % get.blurSuffix
        function suff = get.blockSuffix(this)
            bS   = this.blockSize;
            suff = ['_' num2str(bS(1))   'x' num2str(bS(2))   'x' num2str(bS(3)) 'blocks'];
        end % get.blockSuffix
        function this = set.fgnii(this, nii)
            
            this.fgnii_ = mlfourd.NIfTI(nii); % TODO:  ensure mask qualities
            this.fgnii_ = this.fgnii_.forceDouble;
        end % set.fgnii 
        function this = set.references(this, fps)
            if (ischar(fps)); fps = {fps}; end
            if (iscell(fps) && ischar(fps{1}))
                this.references_ = fps;
            end
        end  
        function fps  = get.references(this)
            if (iscell(this.references_) && ~isempty(this.references_) && ischar(this.references_{1}))
                fps = this.references_;
            end
        end
        function this = set.reference(this, fp)
            if (ischar(fp))
                this.references_ = [fp this.references_];
            end
        end       
        function fp   = get.reference(this)
            if (~isempty(this.references) && ischar(this.references{1}))
                fp = this.references{1};
            else
                throw(MException('mlfsl:NullReferenceError', 'FilesystemRegistry.get.reference'));
            end
        end
        function suf  = get.onRefsSuffixes(this)
            suf = cell(size(this.references));
            for s = 1:length(this.references)  %#ok<*FORFLG>
                suf{s} = ['_on_' this.references{s}]; 
            end
        end        
        function suf  = get.onRefSuffix(this)
            suf = ['_on_' this.reference];
        end        
        function flds = get.onFolders(this)
            flds = cell(size(this.references));
            for f = 1:length(flds) 
                flds{f} = ['on' upper(this.references{f}(1)) this.references{f}(2:end)]; 
            end
        end
        function fld  = get.onFolder(this)
            fld = ['on' upper(this.reference(1)) this.reference(2:end)];
        end
        function fp   = get.ref_fp(this)
            fp = fileprefix(this.reference);
        end        
        function fps  = get.ref_fps(this)
            [~,fps] = pathparts(this.references);
        end
        function fn   = get.ref_fn(this)
            fn = filename(this.ref_fp);
        end        
        function fns  = get.ref_fns(this)
            fns = filenames(this.ref_fps);
        end

        function tf   = blur2bool(this)
            assert(isnumeric(this.baseBlur));
            tf = ~all([0 0 0] == this.baseBlur);
        end
        function tf   = block2bool(this)
            assert(isnumeric(this.blockSize));
            tf = ~all([1 1 1] == this.blockSize);
        end        
        function        cd(this, target) %#ok<MANU>
            mlfourd.FilesystemRegistry.scd(target);
        end
        
 	end % methods
    
    methods (Access = 'protected')        
        function this = ImagingBuilder(~, fgn, imaging)
            
            %% CTOR
            %  Usage:  this = ImagingBuilder([pnum, fg_filename, imaging])
            %          pnum:  string
            %          fg_filename:  NIfTI or []
            import mlfourd.* mlfsl.* mlsurfer.*;
            this.namingRegistry_ = NamingRegistry.instance;
            switch (nargin)
                case 0
                    this.imagingProduct = ImagingComponent;
                case 1                   
                    this.imagingProduct = [];
                case 2                   
                    this.imagingProduct = [];
                    if (ischar(fgn))
                        this.fgnii_ = NIfTI.load(fgn);
                    elseif (isa(fgn, 'mlfourd.NIfTI'))
                        this.fgnii_ = fgn;
                    end
                case 3                   
                    this.imagingProduct = imaging;
                    if (ischar(fgn))
                        this.fgnii_ = NIfTI.load(fgn); 
                    elseif (isa(fgn, 'mlfourd.NIfTI'))
                        this.fgnii_ = fgn;
                    end
                case 4
                    this.imagingProduct = imaging;
                    if (ischar(fgn))
                        this.fgnii_ = NIfTI.load(fgn); 
                    elseif (isa(fgn, 'mlfourd.NIfTI'))
                        this.fgnii_ = fgn;
                    end;
                otherwise
                    throw(MException('mlfourd:UnsupportedNumberOfParameters', ...
                        ['ImagingBuilder.ctor:  nargin -> ' num2str(nargin)]));
            end
            %if (~isempty(this.fgnii_)); this.fgnii_ = this.fgnii_.forceDouble; end
        end % ctor
    end % protected methods
    
   
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

