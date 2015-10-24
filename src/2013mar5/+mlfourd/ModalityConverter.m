classdef ModalityConverter < handle    
    
    properties (SetAccess = protected)
        reg      = 0;
        metric   = '';
        fgnii    = 0;  % may be cell-array of NIfTI
        cbfnii   = 0; 
        cbvnii   = 0;
        mttnii   = 0;
        oefnii   = 0;
        cmro2nii = 0;
    end   
    
    methods (Static)        
        function nii = acceptableNIfTI(nii)
            import mlfourd.*;
            switch (class(nii))
                case NIfTI.NIFTI_SUBCLASS
                    nii.img = NIfTI.ensureDble(nii.img);
                case 'cell'
                    for n = 1:length(nii)
                        nii{n}.img = NIfTI.ensureDble(nii{n}.img);
                    end
                otherwise
                    error('mlfourd:UnsupportedParameterType', ...
                          'class(ModalityConverter.acceptabelNIfTI.nii) -> %s', class(nii));
            end
        end % static acceptableNIfTI
    end % static methods
    
    methods
        
        function set.fgnii(obj, nii)
            
            obj.fgnii = mlfourd.NIfTI(nii); % TODO:  ensure mask qualities
            obj.fgnii = obj.fgnii.forceDouble;
        end % set.fgnii         
        function set.cbfnii(obj, nii)
            obj.cbfnii = mlfourd.ModalityConverter.acceptableNIfTI(nii);
        end % set.cbfnii 
        function set.cbvnii(obj, nii)
            obj.cbvnii = mlfourd.ModalityConverter.acceptableNIfTI(nii);
        end % set.cbvnii      
        function set.mttnii(obj, nii)
            obj.mttnii = mlfourd.ModalityConverter.acceptableNIfTI(nii);
        end % set.mttnii        
        function set.oefnii(obj, nii)
            obj.oefnii = mlfourd.ModalityConverter.acceptableNIfTI(nii);
        end % set.oefnii 
        function set.cmro2nii(obj, nii)
            obj.cmro2nii = mlfourd.ModalityConverter.acceptableNIfTI(nii);
        end % set.cmro2nii
        
        function quot = safe_quotient(obj, num, den)
        
            %% SAFE_QUOTIENT
            %  Usage:  quot = obj.safe_quotient(num, den)
            %          num, den must be numeric arrays, NIfTI, or fileprefixes
            %          quot will have same typeclass
            import mlfourd.*;            
            assert(~isempty(obj.fgnii), 'ModalityConverter.safe_quotient:  requires that foreground be assigned first');
            numType = class(num);
            switch (numType)
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                case numeric_types
                    num = NIfTI(num);
                case 'char'
                    num = NIfTI.load(num);
                otherwise
                    error('mlfourd:UnsupportedType', 'class(ModalityConverter.num) -> %s', numType);
            end
            
            num  = obj.fgnii.makeSimilarNIfTI(num, 'ModalityConverter.safe_quotient.num');
            numb = NiiBrowser(num, obj.reg.baseBlur);
            den  =       num.makeSimilarNIfTI(den, 'ModalityConverter.safe_quotient.den');
            fzfg =       num.makeSimilarNIfTI(obj.fuzzyFg, 'ModalityConverter.safe_quotient.fzfg');
            quot =  numb.safe_quotient(den, fzfg, obj.reg.baseBlur);
            switch (numType)
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                    quot = NIfTI(quot);
                case numeric_types
                    quot = quot.img;
                case 'char'
                    quot = quot.fileprefix;
                otherwise
                    error('mlfourd:UnsupportedType', 'class(ModalityConverter.num) -> %s', numType);
            end
        end % safe_quotient
        function img  = fuzzyFg(obj, blur)
            
            %% FUZZYFG returns numerics
            %  Usage:  obj = mlfourd.ModalityConverter('p9999');
            %          dble_img = obj.fuzzyFg; % normalized mask
            %
            if (nargin < 2); blur = obj.reg.baseBlur; end
            fgniib = mlfourd.NiiBrowser(obj.fgnii, blur);
            fgniib = fgniib.blurredBrowser(blur, obj.fgnii);
            img    = fgniib.img;
            img    = img / dipmax(img);
        end % fuzzyFg
    end % methods

    methods (Access = 'protected')
        
        function obj = ModalityConverter(pid, fgn, blur, blocks) 
            %% CTOR
            %  Usage:  obj = ModalityConverter([pid, fg_filename, blur, blocks])
            %          pid:  string
            %          fg_filename:  NIfTI or []
            %          blur: e.g., [10 10 10], in mm for fwhh
            %          isblck: false or [b1 b2 b3], in #voxels
            
            import mlfourd.* mlfsl.*;
            switch (nargin)
                case 0
                    obj.reg = Np797Registry.instance(pwd);
                case 1
                    obj.reg = Np797Registry.instance(pid);
                case 2
                    obj.reg       = Np797Registry.instance(pid);
                    if (ischar(fgn))
                        obj.fgnii = NIfTI.load(fgn);
                    elseif (isa(fgn, 'mlfourd.NIfTI'))
                        obj.fgnii = fgn;
                    end
                case 3
                    obj.reg          = Np797Registry.instance(pid);
                    if (ischar(fgn))
                        obj.fgnii    = NIfTI.load(fgn); 
                    elseif (isa(fgn, 'mlfourd.NIfTI'))
                        obj.fgnii = fgn;
                    end
                    obj.reg.baseBlur = blur;
                case 4
                    obj.reg           = Np797Registry.instance(pid);
                    if (ischar(fgn))
                        obj.fgnii     = NIfTI.load(fgn); 
                    elseif (isa(fgn, 'mlfourd.NIfTI'))
                        obj.fgnii = fgn;
                    end
                    obj.reg.baseBlur  = blur;
                    obj.reg.blockSize = blocks;
                otherwise
                    throw(MException('mlfourd:UnsupportedNumberOfParameters', ...
                        ['ModalityConverter.ctor:  nargin -> ' num2str(nargin)]));
            end
            %if (~isempty(obj.fgnii)); obj.fgnii = obj.fgnii.forceDouble; end
        end % ctor
    end % protected methods
    
end % ModalityConverter
