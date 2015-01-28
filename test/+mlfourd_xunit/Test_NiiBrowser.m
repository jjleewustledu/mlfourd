%% TEST_NiiBrowser tests high-level functioning of the NiiBrowser class
%
%  Tests instantiation, and salient properties and methods.
%
%  _Usage:_  runtests Test_NIfTI
%
%  Created by John Lee on 2008-5-12.
%  Rev. by John Lee on 2008-12-23: replacing voxel keyword with fourd, introducing direct fourdData support
%  Copyright (c) 2008 Washington University School of Medicine. All rights reserved.
%  Report bugs to bugs.perfusion.neuroimage.wustl.edu@gmail.com.
%
classdef Test_NiiBrowser < mlfourd_xunit.Test_NIfTI

    methods
        
        function obj = Test_NiiBrowser(varargin)
            import mlfourd.*;
            import mlfourd_xunit.*;
            obj         = obj@mlfourd_xunit.Test_NIfTI(varargin{:});
            %obj.niib_t1 = mlfourd.NiiBrowser(obj.nii_t1);         
        end
% 
% 		function obj = test_stretchVec(obj)
% 			mlunit.assert_equals([10 10 10 10 10 10 10 10], ...
% 								 mlfourd.NiiBrowser.stretchVec([10 10], 8), ...
% 								 'stretchVec failed its test');
% 		end % function test_stretchVec
% 		
% 		function obj = test_sampleDbleVoxels(obj)
% 			vec = mlfourd.NiiBrowser.sampleDblVoxels(obj.nii_t1.img, obj.nii_fg.img);
% 			mlunit.assert_equals(151444, ...
% 			                     size(vec), ...
% 			                     'sampleDbleVoxels failed');
% 		end % function test_sampleDbleVoxels
% 		
%         function obj = test_blockBrowser(obj)
%             BLOCKSZ = [8 8 2];
%             blockBr = obj.niib_t1.blockBrowser(BLOCKSZ);
%             assert(all(     blockBr.blur                 == floor(     obj.niib_t1.blur                 ./ BLOCKSZ)));
%             assert(all(size(blockBr.img)                 == floor(size(obj.niib_t1.img)                 ./ BLOCKSZ)));
%             assert(all(     blockBr.hdr.dime.dim(2:4)    == floor(     obj.niib_t1.hdr.dime.dim(2:4)    ./ BLOCKSZ)));
%             assert(         blockBr.hdr.dime.datatype    ==            obj.niib_t1.hdr.dime.datatype);
%             assert(         blockBr.hdr.dime.bitpix      ==            obj.niib_t1.hdr.dime.bitpix);
%             assert(all(     blockBr.hdr.dime.pixdim(2:4) ==            obj.niib_t1.hdr.dime.pixdim(2:4) .* BLOCKSZ));
%             assert(         blockBr.hdr.hist.originator  ==            obj.niib_t1.hdr.hist.originator);
%         end % function test_blockBrowser
%         
%         function obj = test_updateImg(obj)
%             obj.niib_t1.img = obj.nii_fg.img;
%             obj.niib_t1     = obj.niib_t1.append_descrip('test_updateImg');
%             assert(sum(dip_image(obj.niib_t1.img))) == sum(dip_image(obj.nii_fg.img)));
%         end % function test_updateImg        
    end
end
