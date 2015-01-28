classdef Test_ImagingSeries < mlfourd_xunit.Test_AbstractComponent
	%% TEST_IMAGINGSERIES 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_ImagingSeries % in . or the matlab path 
 	%          >> runtests Test_ImagingSeries:test_nameoffunc 
 	%          >> runtests(Test_ImagingSeries, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	%  Version $Revision: 2619 $ was created $Date: 2013-09-08 23:16:05 -0500 (Sun, 08 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-08 23:16:05 -0500 (Sun, 08 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImagingSeries.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: Test_ImagingSeries.m 2619 2013-09-09 04:16:05Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	methods 
        function test_copyctor(this)
            cp = mlfourd.ImagingSeries(this.imseries);
            cp.zeros;
            assertTrue(max(this.imseries.img(:)) > 0);
        end
        function test_createFromFilename(this)
            assertTrue(isa(this.imseries, 'mlfourd.ImagingSeries'));
        end
        function test_ctorAndImagingSeries(this)
            import mlfourd.*;
            cal = mlfourd.ImagingArrayList;
            cal.add(NIfTI.load(this.t1_fqfn));
            assertTrue(isa(ImagingSeries(cal), 'mlfourd.ImagingSeries')); 
        end    
        function test_ctorAndImagingComposite(this)
            import mlfourd.*;
            cal = mlfourd.ImagingArrayList;
            cal.add(NIfTI.load(this.t2_fqfn));
            cal.add(NIfTI.load(this.ir_fqfn));
            assertTrue(isa(ImagingComposite(cal), 'mlfourd.ImagingComposite'));
        end  
        function test_heterogeneousHorzcat(this)
            import mlfourd.*;
            objs =  ImagingSeries.load({this.t1_fqfn this.t1_fqfn this.t1_fqfn});
            cats = [ImagingSeries(this.imseries) ...
                    ImagingSeries(this.imseries) ... 
                    ImagingSeries(this.imseries)];
            assertEqual(length(objs), length(cats));
            for f = 1:length(objs)
                assertTrue(isequal( objs.get(f), cats.get(f)));
            end
        end
        function test_growingHorzcat(this)
            import mlfourd.*;
            tmp =      ImagingSeries(this.imseries);
            tmp = [tmp ImagingSeries(this.imseries)];
            tmp = [tmp ImagingSeries(this.imseries)];  
            assertTrue(isa(          this.imseries, 'mlfourd.ImagingSeries'));
            assertTrue(length(tmp) == 3);
            assertTrue(isa(   tmp, 'mlfourd.ImagingComposite'));
            assertEqual(      tmp.get(1), this.imseries.get(1));
        end
        function test_horzcat(this)
            import mlfourd.*;
            catted = [ImagingSeries(this.imseries) ImagingSeries(this.imseries) ImagingSeries(this.imseries)];  
            assertTrue(isa(this.imseries, 'mlfourd.ImagingSeries'));
            assertTrue(isa(    catted,    'mlfourd.ImagingComposite'));
            assertTrue( length(catted) == 3);
            for c = 1:length(  catted)
                assertTrue(isa(catted.get(c),           'mlfourd.NIfTIInterface'));
                assertEqual(   catted.get(c).fqfilename, this.t1_fqfn);
            end
        end 
 		function test_subsref(this)
 			import mlfourd.*;            
            assertTrue(       isa(this.imseries, 'mlfourd.ImagingSeries'));
            assertEqual(1, length(this.imseries));
            assertTrue(       isa(this.imseries{1}, 'mlfourd.NIfTIInterface'));
            assertTrue(   isequal(this.imseries{1}, this.imseries.cachedNext));
            assertEqual(          this.imseries{1}.fqfilename, this.t1_fqfn);
        end     
        function test_makeSimilar(this)
            imser   = this.imseries;
            similar = imser.makeSimilar(ones(size(imser)), 'similar');
            assertElementsAlmostEqual(ones(size(imser)), similar.img);
        end
 		function test_saveas(this) 
 			import mlfourd.*; 
            is  = ImagingSeries.load(this.files3);
            is2 = is.saveas(                      this.test_fqfn);
            is3 = ImagingSeries.load(this.test_fqfn);
            assertElementsAlmostEqual(is.img, is2.img);
            assertElementsAlmostEqual(is.img, is3.img);
            assertTrue( strcmp(this.files3, is.fqfilename));
            assertFalse(strcmp(this.files3, is2.fqfilename));
            assertTrue( strcmp(is2.fqfilename, is3.fqfilename));
        end
        function test_length(this)
            assertEqual(1, this.imseries.length);
        end
        function test_add(this)
            ir       = mlfourd.NIfTI.load(this.files{3});
            imseries = this.imseries;
            imseries = imseries.add(ir);
            assertEqual(2, imseries.length);
            assertTrue(isa(imseries, 'mlfourd.ImagingComposite'));
        end
        function test_remove(this)
            imseries = this.imseries;
            h = @() imseries.remove(1);
            assertExceptionThrown(h,'MATLAB:assertion:failed');
        end
        function test_get(this)
            nii = this.imseries.get(1);
            assertTrue(nii.isequal(mlfourd.NIfTI.load(this.t1_fqfn)));
        end
        function test_countOf(this)
            t1 = mlfourd.NIfTI.load(this.t1_fqfn);
            assertEqual(1, this.imseries.countOf(t1));
        end
        function test_locationsOf(this)
            item = this.imseries.get(1);
            assertEqual(1, this.imseries.locationsOf(item));
        end
        function test_iterator(this)
            %% TEST_ITERATOR tests reset, hasNext, next
            imseries = this.imseries;
            imseries = imseries.reset;
            cnt = 0;
            while (imseries.hasNext)
                cnt = cnt + 1;
                imseries = imseries.iterateNext;
                assertTrue(isa(imseries.cachedNext, 'mlfourd.NIfTIInterface'));
            end
            assertEqual(1, cnt);
        end
        
 		function this = Test_ImagingSeries(varargin) 
 			this = this@mlfourd_xunit.Test_AbstractComponent(varargin{:});            
 		end % Test_ImagingSeries (ctor) 
        
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

