classdef Test_ImagingComposite < mlfourd_unittest.Test_AbstractComponent
	%% TEST_IMAGINGCOMPOSITE 

	%  Usage:  >> results = run(mlfourd_unittest.Test_ImagingComposite)
 	%          >> result  = run(mlfourd_unittest.Test_ImagingComposite, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 18-Oct-2015 14:40:41
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/test/+mlfourd_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		registry
 		testObj
 	end

	methods (Test)
        function test_copy(this)
            cp = mlfourd.ImagingComposite(this.imcps);
            for c = 1:length(cp)
                cp{c}.zeros;
                this.verifyTrue(max(max(max(this.imcps{c}.img))) > 0);
            end
        end
        function test_forceDouble(this)
            import mlfourd.*;
            ho = NIfTId.load(this.ho_fqfn);
            ho.img = uint8(ho.img > 0);
            ho.saveas(this.fqfilenameInFsl('hobin'));
            oo = NIfTId.load(this.oo_fqfn);
            oo.img = uint8(oo.img > 0);
            oo.saveas(this.fqfilenameInFsl('oobin'));
            pet = ImagingComposite.load({ho.fqfilename oo.fqfilename}); 
            pet = pet.reset;
            while (pet.hasNext)
                pet = pet.iterateNext;
                pet = pet.forceDouble;
            end
            for p = 1:length(pet)
                this.verifyEqual('double', class(pet{p}.img));
            end
        end
        function test_createFromCell(this)
            imcps = mlfourd.ImagingComposite.createFromCell(this.files);
            this.verifyTrue(isa(imcps, 'mlfourd.ImagingComposite'));
        end
        function test_createFromImagingArrayList(this)
            imcps = mlfourd.ImagingComposite.createFromImagingArrayList(this.imcps.asList);
            this.verifyTrue(isa(imcps, 'mlfourd.ImagingComposite'));
        end
        function test_heterogeneousHorzcat(this)
            import mlfourd.*;
            objs = ImagingComposite.load([this.files this.files2 this.files3]);
            cats = [this.imcps this.imcps2.get(1) this.imcps2.get(2) this.imcps3];
            this.verifyEqual(length(objs), length(cats));
            for f = 1:length(objs)
                this.verifyTrue(isequal( objs.get(f), cats.get(f)));
            end
        end
        function test_growingHorzcat(this) % failed
            tmp = this.imcps;
            tmp = [tmp this.imcps.get(3)];
            this.verifyTrue(length(tmp) == 4);
            this.verifyTrue(isa(   tmp, 'mlfourd.ImagingComposite'));
        end
        function test_horzcat(this) % failed
            import mlfourd.*;
            series = ImagingSeries.load(this.imcps.get(1));
            catted = [series this.imcps.get(2) this.imcps.get(3)];
            this.verifyTrue( length(catted) == 3);
            this.verifyTrue(isa(    catted,                   'mlfourd.ImagingComposite'));
            for c = 1:length(  catted)
                this.verifyTrue(isa(catted.get(c),            'mlfourd.INIfTI'));
                this.verifyEqual(   catted.get(c).fqfilename,  this.files{c});
            end
            this.verifyEqual(       catted.asList, this.imcps.asList);    
        end
 		function test_subsref(this)
 			import mlfourd.*;            
            this.verifyTrue(       isa(this.imcps,    'mlfourd.ImagingComposite'));
            for c = 1:length(     this.imcps)
                this.verifyTrue(   isa(this.imcps{c}, 'mlfourd.INIfTI'));
                this.verifyEqual(      this.imcps{c}.fqfilename, this.files{c});
            end
        end
        function test_makeSimilar(this)
            imcps   = this.imcps;
            similar = imcps.makeSimilar('img', ones(size(imcps)), 'fileprefix', 'similar');
            this.verifyEqual(ones(size(imcps)), similar.img);
        end
 		function test_saveas(this) 
 			import mlfourd.*; 
            is  = ImagingComposite.load(this.files);
            is2 = is.saveas(                         this.test_fqfn);
            is3 = ImagingComposite.load(this.test_fqfn);
            this.verifyEqual(double(is.img),  double(is2.img));
            this.verifyEqual(double(is.img),  double(is3.img));
            this.verifyTrue( strcmp(this.files{1},  is.fqfilename));
            this.verifyFalse(strcmp(this.files{1},  is2.fqfilename));
            this.verifyTrue( strcmp(is2.fqfilename, is3.fqfilename));
        end
        function test_length(this) % failed
            this.verifyEqual(3, this.imcps.length);
        end
        function test_add(this) % failed
            ir    = mlfourd.NIfTId.load(this.files{3});
            imcps = this.imcps;
            imcps.add(ir);
            this.verifyEqual(4, imcps.length);
            this.verifyEqual(this.files{3}, imcps.get(4).fqfilename);
        end
        function test_remove(this) % failed
            imcps = this.imcps;
            imcps = imcps.remove(2);
            this.verifyEqual(2, imcps.length);
            this.verifyEqual(this.files{1}, imcps.get(1).fqfilename);
            this.verifyEqual(this.files{3}, imcps.get(2).fqfilename);
        end
        function test_get(this)
            import mlfourd.*;
            gotten = this.imcps.get(1);
            this.verifyTrue(gotten.isequal(NIfTId.load(this.files{1})));
        end
        function test_countOf(this) % failed
            ir =  mlfourd.NIfTId.load(this.files{3});
            this.verifyEqual(2, this.imcps.countOf(ir));
        end
        function test_locationsOf(this) % failed
            ir = mlfourd.NIfTId.load(this.files{3});
            this.verifyEqual([2;3], this.imcps.locationsOf(ir));
        end
        function test_iterator(this)
            %% TEST_ITERATOR tests reset, hasNext, next
            imcps = this.imcps;
            imcps.reset;
            cnt = 0;
            while (imcps.hasNext)
                cnt = cnt + 1;
                imcps = imcps.iterateNext;
                this.verifyTrue(isa(imcps.cachedNext, 'mlfourd.INIfTI'));
                %fprintf('imcps.cachedNext.fileprefix->%s\n', imcps.cachedNext.fileprefix);
            end            
            this.verifyEqual(this.imcps.length, cnt);
        end
 	end

 	methods (TestClassSetup)
 		function setupImagingComposite(this)
 		end
 	end

 	methods (TestClassTeardown)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

