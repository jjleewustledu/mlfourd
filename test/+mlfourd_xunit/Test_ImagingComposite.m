classdef Test_ImagingComposite < mlfourd_xunit.Test_AbstractComponent
	%% TEST_IMAGINGCOMPOSITE 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_ImagingComposite % in . or the matlab path 
 	%          >> runtests Test_ImagingComposite:test_nameoffunc 
 	%          >> runtests(Test_ImagingComposite, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	%  Version $Revision: 2643 $ was created $Date: 2013-09-21 17:58:37 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:37 -0500 (Sat, 21 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImagingComposite.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: Test_ImagingComposite.m 2643 2013-09-21 22:58:37Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
	
	methods 
        function test_copy(this)
            cp = mlfourd.ImagingComposite(this.imcps);
            for c = 1:length(cp)
                cp{c}.zeros;
                assertTrue(this.imcps{c}.dipmax > 0);
            end
        end
        function test_forceDouble(this)
            import mlfourd.*;
            ho = NIfTI.load(this.ho_fqfn);
            ho.img = ho.img > 0;
            ho.saveas(this.fqfilenameInFsl('hobin'));
            oo = NIfTI.load(this.oo_fqfn);
            oo.img = oo.img > 0;
            oo.saveas(this.fqfilenameInFsl('oobin'));
            pet = ImagingComposite.load({ho.fqfilename oo.fqfilename}); 
            pet = pet.reset;
            while (pet.hasNext)
                pet = pet.iterateNext;
                pet = pet.forceDouble;
            end
            for p = 1:length(pet)
                assertEqual('double', class(pet{p}.img));
            end
        end
        function test_createFromCell(this)
            imcps = mlfourd.ImagingComposite.createFromCell(this.files);
            assertTrue(isa(imcps, 'mlfourd.ImagingComposite'));
        end
        function test_createFromImagingArrayList(this)
            imcps = mlfourd.ImagingComposite.createFromImagingArrayList(this.imcps.asList);
            assertTrue(isa(imcps, 'mlfourd.ImagingComposite'));
        end
        function test_heterogeneousHorzcat(this)
            import mlfourd.*;
            objs = ImagingComposite.load([this.files this.files2 this.files3]);
            cats = [this.imcps this.imcps2.get(1) this.imcps2.get(2) this.imcps3];
            assertEqual(length(objs), length(cats));
            for f = 1:length(objs)
                assertTrue(isequal( objs.get(f), cats.get(f)));
            end
        end
        function test_growingHorzcat(this)
            tmp = this.imcps;
            tmp = [tmp this.imcps.get(3)];
            assertTrue(length(tmp) == 4);
            assertTrue(isa(   tmp, 'mlfourd.ImagingComposite'));
        end
        function test_horzcat(this)
            import mlfourd.*;
            series = ImagingSeries.load(this.imcps.get(1));
            catted = [series this.imcps.get(2) this.imcps.get(3)];
            assertTrue( length(catted) == 3);
            assertTrue(isa(    catted,                   'mlfourd.ImagingComposite'));
            for c = 1:length(  catted)
                assertTrue(isa(catted.get(c),            'mlfourd.NIfTIInterface'));
                assertEqual(   catted.get(c).fqfilename,  this.files{c});
            end
            assertEqual(       catted.asList, this.imcps.asList);    
        end
 		function test_subsref(this)
 			import mlfourd.*;            
            assertTrue(       isa(this.imcps,    'mlfourd.ImagingComposite'));
            for c = 1:length(     this.imcps)
                assertTrue(   isa(this.imcps{c}, 'mlfourd.NIfTIInterface'));
                assertEqual(      this.imcps{c}.fqfilename, this.files{c});
            end
        end
        function test_makeSimilar(this)
            imcps   = this.imcps;
            similar = imcps.makeSimilar(ones(size(imcps)), 'similar');
            assertElementsAlmostEqual(ones(size(imcps)), similar.img);
        end
 		function test_saveas(this) 
 			import mlfourd.*; 
            is  = ImagingComposite.load(this.files);
            is2 = is.saveas(                         this.test_fqfn);
            is3 = ImagingComposite.load(this.test_fqfn);
            assertElementsAlmostEqual(double(is.img),  double(is2.img));
            assertElementsAlmostEqual(double(is.img),  double(is3.img));
            assertTrue( strcmp(this.files{1},  is.fqfilename));
            assertFalse(strcmp(this.files{1},  is2.fqfilename));
            assertTrue( strcmp(is2.fqfilename, is3.fqfilename));
        end
        function test_length(this)
            assertEqual(3, this.imcps.length);
        end
        function test_add(this)
            ir    = mlfourd.NIfTI.load(this.files{3});
            imcps = this.imcps;
            imcps.add(ir);
            assertEqual(4, imcps.length);
            assertEqual(this.files{3}, imcps.get(4).fqfilename);
        end
        function test_remove(this)
            imcps = this.imcps;
            imcps = imcps.remove(2);
            assertEqual(2, imcps.length);
            assertEqual(this.files{1}, imcps.get(1).fqfilename);
            assertEqual(this.files{3}, imcps.get(2).fqfilename);
        end
        function test_get(this)
            import mlfourd.*;
            gotten = this.imcps.get(1);
            assertTrue(gotten.isequal(NIfTI.load(this.files{1})));
        end
        function test_countOf(this)
            ir =  mlfourd.NIfTI.load(this.files{3});
            assertEqual(2, this.imcps.countOf(ir));
        end
        function test_locationsOf(this)
            ir = mlfourd.NIfTI.load(this.files{3});
            assertEqual([2;3], this.imcps.locationsOf(ir));
        end
        function test_iterator(this)
            %% TEST_ITERATOR tests reset, hasNext, next
            imcps = this.imcps;
            imcps.reset;
            cnt = 0;
            while (imcps.hasNext)
                cnt = cnt + 1;
                imcps = imcps.iterateNext;
                assertTrue(isa(imcps.cachedNext, 'mlfourd.NIfTIInterface'));
                %fprintf('imcps.cachedNext.fileprefix->%s\n', imcps.cachedNext.fileprefix);
            end            
            assertEqual(this.imcps.length, cnt);
        end
        
        
        function setUp(this)
            setUp@mlfourd_xunit.Test_AbstractComponent(this);
        end
        function tearDown(this)
            tearDown@mlfourd_xunit.Test_AbstractComponent(this);
        end
        
 		function this = Test_ImagingComposite(varargin)
 			this = this@mlfourd_xunit.Test_AbstractComponent(varargin{:}); 
            this.preferredSession = 2;
 		end % Test_ImagingComposite (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

