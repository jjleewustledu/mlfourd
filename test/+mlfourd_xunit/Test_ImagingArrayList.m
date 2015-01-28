classdef Test_ImagingArrayList < MyTestCase
	%% TEST_IMAGINGARRAYLIST 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_ImagingArrayList % in . or the matlab path
	%          >> runtests mlfourd.Test_ImagingArrayList:test_nameoffunc
	%          >> runtests(mlfourd.Test_ImagingArrayList, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision: 2619 $
 	%  was created $Date: 2013-09-08 23:16:05 -0500 (Sun, 08 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-08 23:16:05 -0500 (Sun, 08 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_ImagingArrayList.m $, 
 	%  developed on Matlab 8.1.0.604 (R2013a)
 	%  $Id: Test_ImagingArrayList.m 2619 2013-09-09 04:16:05Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        ialist
 	end

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_clone(this)  
            %% TEST_CLONE extracts from mlpatterns_xunit/demoCloneScript
            
            % Create two instances of ImagingArrayList
            import mlfourd.*;
            a = ImagingArrayList();
            b = ImagingArrayList();

            % Change the parameters in objects
            a.add([5 10]);
            b.add([1 2]);

            % Call the copy object method to create a clone of 'a' using 'b'
            b = ImagingArrayList(a);
            this.assertListsEqual(a, b);

            % Change the parameters in object 'a' again
            a.remove(1); a.remove(2);
            a.add([500 1000]);            
            this.assertListsNotEqual(a, b);

            % ANOTHER WAY TO CLONE - USING CONSTRUCTOR
            % This procedure implicitly creates a placeholder in memory
            % for cloning the original object by way of the constructor.

            % Create a clone (or deep copy) of object 'a'
            b = mlfourd.ImagingArrayList(a);

            % Change the parameters in object 'a' again
            a.remove(1); a.remove(2);
            a.add([501 1001]);
            this.assertListsNotEqual(a, b);
        end         
        function test_ctor(this)
            assertTrue(this.ialist.isempty);
            assertEqual(0, this.ialist.length);
        end        
        function test_list(this)
            myList = mlfourd.ImagingArrayList;
            myList.add(5);
            myList.add(rand(2)); % 2x2 matrix
            myList.add({50,55}); % 2 separate integer elements

            % check elements
            assertFalse(myList.isempty);
            assertEqual(4, myList.length);
            
            % seeking:  countOf, locationsOf
            assertEqual(1, myList.countOf(50));
            assertEqual(3, myList.locationsOf(50));

            myList.add({rand(3),5:7},2);  % a 3x3 matrix and a 1x3 array
            myList.add(myList,7);    % reference to self!   ImagingArrayList will flatten
            myList0 = myList.clone;
            myList.add({10,11;12,13},5);  % a 2x2 cell array
            myList.add({150,160,170},3);  % 3 integers as 3 unique elements

            % check elements
            assertEqual(16, myList.length); 

            % get elements
            assertEqual(150,        myList.get(3));          % elt = 150
            assertEqual([2 2], size(myList.get(7)));  % elt = 2x2 rand matrix
            assertEqual([2 2], size(myList.get(8)));  % elt = 2x2 cell array
            elts = myList.get([3:4,2]);
            assertEqual(150, elts{1});
            assertEqual(160, elts{2});
            assertEqual([3 3], size(elts{3}));

            % add duplicate element
            myList.add(5,6);

            % seeking
            assertEqual(3,        myList.countOf(5));
            assertEqual([1;6;12], myList.locationsOf(5));

            % remove elements
            assertTrue(isempty(myList.remove([4:5,20])));
            assertEqual(17,    myList.length);

            % remove all elements
            myList.remove(1:myList.length);

            % check elements
            assertTrue(myList.isempty);
            assertEqual(0, myList.length);
        end
        function test_arrayOfimagingArrayList(this) %#ok<MANU>
            myList(2,2) = mlfourd.ImagingArrayList;
            myList.add({rand(3),5:7},2);  % a 3x3 matrix and a 1x3 array
            myList.add(500,5);            % a single integer
            myList(:,1).add({99,100});  % 2 integers
            assertEqual([5,3; 5,3], myList.length);

            % insert element to two lists at location 4
            myList(1,:).add(rand(2),4);
            assertEqual([6,4; 5,3], myList.length);

            % append element
            myList(2,1).add(99);
            assertEqual([6,4; 6,3], myList.length);

            % seek on element
            assertElementsAlmostEqual([1,0; 2,0], myList.countOf(99));
            %%assertElementsAlmostEqual({5,[ ]; [4;6],[ ]}, myList.locationsOf(99));

            % remove elements
            elts  = myList.remove([4,5]);
            elts2 = elts{1,1};
            assertEqual([2 2], size(elts2{1}));
            assertEqual(99, elts2{2});
            assertEqual({99; 100}, elts{2,1});
            assertTrue(isempty(elts{1,2}));
            assertTrue(isempty(elts{2,2}));
        end
        
        function        setUp(this)
            this.ialist = mlfourd.ImagingArrayList;
        end
 		function this = Test_ImagingArrayList(varargin) 
 			this = this@MyTestCase(varargin{:}); 
        end % ctor 
    end 
    
    methods (Static, Access = 'private')
        function assertListsEqual(a, b)
            assertEqual(a.length, b.length);
            for i = 1:length(a);
                assertEqual(a.get(i), b.get(i));
            end
        end
        function assertListsNotEqual(a, b)
            assertEqual(a.length, b.length);
            for i = 1:length(a);
                assertFalse(all(a.get(i) == b.get(i)));
            end
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

