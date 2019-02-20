classdef FourdRegistry < mlpatterns.Singleton  
	%% FOURDREGISTRY  

	%  $Revision$
 	%  was created 02-Feb-2016 19:13:44
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

    methods (Static)
        function tf   = isSupportedImageType(typ)
            imagingTypes = { ...
                'ImagingContext2' 'ImagingContext' ...
                'NIfTIc' 'NIfTId' 'NumericalNIfTId' 'DynamicNIfTId' 'MaskingNIfTId' 'BlurringNIfTId' 'LoggingNIfTId' 'MGH'};
            legacyTypes = {'ImagingComponent'  'ImagingComposite' 'ImagingSeries' 'NIfTI' 'NiiBrowser' 'NIfTI_mask'};
            otherTypes = {'PETImagingContext' 'MRImagingContext' 'mlpet.PETImagingContext' 'mlmr.MRImagingContext' };
            parserTypes = {'filename' 'fileprefix' 'fqfilename' 'fqfileprefix'};
            builtinTypes = [numeric_types 'char'];
            tf = ismember(typ, [ ...
                imagingTypes mlfourdTypes(imagingTypes) ...
                legacyTypes mlfourdTypes(legacyTypes) ...
                otherTypes parserTypes builtinTypes]);
            
            function c = mlfourdTypes(c)
                c = cellfun(@(x) ['mlfourd.' x], c, 'UniformOutput', false);
            end
        end
        function tf   = isSupportedImage(obj)
            if (isa(obj, 'mlfourd.INIfTI') || ...
                isa(obj, 'mlfourd.ImagingContext') || ...
                isa(obj, 'mlfourd.ImagingContext2') || ...
                isnumeric(obj) || ...
                ischar(obj) || ...
                iscell(obj))
                tf = true;
                return
            end
            tf = false;
        end
        function this = instance(qualifier)
            
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfourd.FourdRegistry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end 
    
	%% PROTECTED
    
    methods (Access = 'protected')
 		function this = FourdRegistry(varargin)
            this = this@mlpatterns.Singleton(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

