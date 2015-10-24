classdef O15Director < mlfourd.FslDirector
	%% O15DIRECTOR is the client director that specifies algorithms for creating PET imaging objects;
    %              takes part in builder_ design patterns
	
	%  Version $Revision: 2321 $ was created $Date: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-21 00:17:57 -0600 (Mon, 21 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/O15Director.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: O15Director.m 2321 2013-01-21 06:17:57Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties (Dependent)
        petReference
        allPet
    end
    
    methods (Static)
        function this = doAll(mpth)
            import mlfourd.*;
            this = O15Director.createFromModalityPath(mpth);
            this = this.directBuildingCounts;
            this = this.directPerfusionAnalysis;
            this = this.directOxygenMetabolismAnalysis;
        end
        function this = createFromModalityPath(pth)
            import mlfsl.*;
            assert(lexist(pth, 'dir'));
            this = O15Director.createFromBuilder( ...
                   O15Builder.createFromModalityPath(pth));
        end
        function this = createFromBuilder(bldr)
            assert(isa(bldr, 'mlfsl.PETBuilder'));
            this = mlfsl.O15Director(bldr);
        end
    end
    
    methods %% get/set
        function this = set.petReference(this, ref)
            this.builder_.petReference = ref;
        end
        function ref  = get.petReference(this)
            ref = this.builder_.petReference;
        end
        function cal  = get.allPet(this)
            assert(isa(this.builder_.allPet, 'mlpatterns.HandlelessListInterface'));
            cal = this.builder_.allPet;
        end
    end
    
    methods
        function  this       = directBuildingCounts(this)
            this = this.coregisterSequence2PetRef;
            this = this.coregisterSequence2MrRef;
            this = this.coregisterSequence2Standard;
        end
        function [this,xfms] = coregisterSequence2PetRef(this, ref)
            %% COREGISTERSEQUENCE2PETREF
            %  Usage:  [this, xfms] = this.coregisterSequence2PetRef([reference])
            %                 ^ cell-array list                       this.petReference is default
            
            p = inputParser;
            addOptional(p, 'ref', this.petReference, @(x) ~isempty(x));
            parse(p, ref);
            allpet = cellArrayListCopy(this.allPet); % paranoia, since allPet is far out of scope
            allpet.add(ref);            
            [this, this.xfms2pet_] = this.coregisterSequence(allpet);
            xfms = cellArrayListCopy(this.xfms2pet_);
            this.products_ = this.xfms2niis(xfms);
        end
        function [this,xfms] = coregisterSequence2MrRef(this, ref)
            %% COREGISTERSEQUENCE2MRREF avoids recomputing coregisterSequence2PetRef
            %  Usage:  [this, xfms] = this.coregisterSequence2MrRef([reference])
            %                 ^ cell-array list                      this.petReference is default
            
            p = inputParser;
            addOptional(p, 'ref', this.mrReference, @(x) ~isempty(x));
            parse(p, ref);
            if (isempty(this.xfms2pet_))
                [this,this.xfms2pet_] = this.coregisterSequence2PetRef; end
            [this,xfm0] = this.coregister(this.petReference, p.Results.ref);
            this.xfms2mr_ = cellArrayListCopy(this.xfms2pet_);
            this.xfms2mr_.add(xfm0);
            xfms = cellArrayListCopy(this.xfms2mr_);
            this.products_.add(this.xfms2niis(xfms));
        end
        function [this,xfms] = coregisterSequence2Standard(this, ref)
            %% COREGISTERSEQUENCE2STANDARD avoids recomputing coregisterSequence2PetRef, coregisterSequence2MrRef
            %  Usage:  [this, xfms] = this.coregisterSequence2Standard([reference])
            %                 ^ cell-array list                        this.standardReference is default
            
            p = inputParser;
            addOptional(p, 'ref', this.standardReference, @(x) ~isempty(x));
            parse(p, ref);
            if (isempty(this.xfms2pet_))
                [this,this.xfms2pet_] = this.coregisterSequence2PetRef; end
            if (isempty(this.xfms2mr_))
                [this,this.xfms2mr_] = this.coregisterSequence2MrRef; end
            [this,xfm0] = this.coregister(this.mrReference, p.Results.ref);
            this.xfms2stand_ = cellArrayListCopy(this.xfms2mr_);
            this.xfms2stand_.add(xfm0);            
            xfms = cellArrayListCopy(this.xfms2stand_);
            this.products_.add(this.xfms2niis(xfms));
        end
        function  this       = directPerfusionAnalysis(this)
            assert(isa(this.products, 'mlpatterns.HandlelessListInterface'));
            if (this.quantitativePet)
                this.products = this.builder_.perfuse(this.products);
            end
        end
        function  this       = directOxygenMetabolismAnalysis(this)
            assert(isa(this.products, 'mlpatterns.HandlelessListInterface'));
            if (this.quantitativePet && this.oxygenAvailable)
                this.products = this.builder_.metabolize(this.products);
            end
        end
        function tf          = quantitativePet(this)
        end
        function tf          = oxygenAvailable(this)
        end
    end
    
    %% PROTECTED
        
    methods (Access = 'protected')
 		function this = O15Director(bldr)
            assert(isa(bldr, 'mlfsl.O15Builder'));
			this = this@mlfourd.FslDirector(bldr);
        end
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        xfms2pet_
        xfms2mr_
        xfms2stand_
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

