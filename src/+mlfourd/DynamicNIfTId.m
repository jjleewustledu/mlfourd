classdef DynamicNIfTId < mlfourd.NIfTIdecorator
	%% DYNAMICNIFTID   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 

	properties 
 		 blur
         mask
 	end 

    methods (Static)        
        function this = load(varargin)
            %% LOAD 
            %  Usage:  this = MaskedNIfTId.load(filename[, description])
            
            import mlfourd.*;            
            this = DynamicNIfTId(NIfTId.load(varargin{:}));
        end
    end
    
	methods 		  
 		function this = DynamicNIfTId(cmp, varargin)            
            %% DYNAMICNIFTID 
            %  Usage:  this = DynamicNIfTId(NIfTIdecorator_object[, option-name, option-value, ...])
            %
            %          options:  'blur'            numeric 3-vector
            %                    'nifti_mask'      NIfTIdInterface
            %                    'freesurfer_mask' NIfTIdInterface, to be binarized internally
            
            import mlfourd.*; 
            this = this@mlfourd.NIfTIdecorator(cmp);
            this = this.append_descrip('decorated by DynamicNIfTId');
            
            p = inputParser;
            addParameter(p, 'timeSum',   [], @islogical);
            addParameter(p, 'volumeSum', [], @islogical);
            addParameter(p, 'blur',      [], @isnumeric);
            addParameter(p, 'mcflirt',   [], @islogical);
            addParameter(p, 'mask',      [], @(x) isa(x, 'mlfourd.NIfTIdInterface'));
            parse(p, varargin{:});             
            
            if (~isempty(p.Results.timeSum) && p.Results.timeSum)
                this = this.timeSummed;
            end
            if (~isempty(p.Results.volumeSum) && p.Results.volumeSum)
                this = this.volumeSummed;
            end
            if (~isempty(p.Results.blur))
                this.blur = p.Results.blur;
                this = this.blurred;
            end
            if (~isempty(p.Results.mcflirt) && p.Results.mcflirt)
                this = this.mcflirted;
            end
            if (~isempty(p.Results.mask))
                this.mask = p.Results.mask;
                this = this.masked;
            end
        end 
        function this = timeSummed(this)
            this.img = sum(this.img, 4);
        end        
        function this = volumeSummed(this)
            this.img = sum(sum(sum(this.img, 1), 2), 3);
        end
        function this = blurred(this)
            assert(~isempty(this.blur) && isnumeric(this.blur));
            bnii = mlfourd.BlurringNIfTId(this.component_, 'blur', this.blur);
            this.component_ = bnii.component_;
        end
        function this = mcflirted(this)
        end
        function this = adjustedFrame(this)
        end
        function this = flirtedBrain(this)
        end
        function this = masked(this)
            assert(~isempty(this.mask) && isa(this.mask, 'mlfourd.NIfTIdInterface'));
            mnii = mlfourd.MaskedNIfTId(this.component_, 'mask', this.mask);
            this.component_ = mnii.component_;
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

