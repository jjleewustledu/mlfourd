%% NIITYPES is a wrapper for simple database queries.
%
%  Singleton design pattern after the GoF and Petr Posik; cf. 
%  http://www.mathworks.de/matlabcentral/newsreader/view_thread/170056
%  Revised according to Matlab R2008b help topic "Controlling the Number of Instances"
%
%  Created by John Lee on 2009-03-11.
%  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
%  Report bugs to <email="bugs.perfusion.neuroimage.wustl.edu@gmail.com"/>.

classdef (Sealed) NiiTypes < handle
    
    properties
        types = {};
    end % properties
    
    properties (SetAccess = private)
    end % private properties

    methods (Static)

        %% static GETINSTANCE
        %  Usage:  obj = mlfourd.NiiTypes.getInstance
        function   obj =                  getInstance
            persistent myobj;
            if isempty(myobj) || ~isvalid(myobj)
                disp('mlfourd.NiiTypes:  new, persistent instance created');
                myobj = mlfourd.NiiTypes;
                myobj.counter = 1;
            else
                myobj.counter = myobj.counter + 1;
            end
            obj = myobj;
        end % static function getInstance
    end % static methods

    methods        
        %% Static IMGTODATATYPE
        function dt = imgToDatatype(img)
        end
        
        %% Static IMGTOBITPIX
        function bp = imgToBitpix(img)
        end
        
        %% Static LABELTODATATYPE
        
        %% Static LABELTOBITPIX
        
        %% Static CHECKNUMERICSNII
        function ok = checkNumericsNii(nii)
        end        
    end % public methods

    methods (Access = private)

        %% private CTOR
        function obj = NiiTypes
            
      0 None                     (Unknown bit per voxel) 
      1 Binary                         (ubit1, bitpix=1) 
      2 Unsigned char         (uchar or uint8, bitpix=8) 
      4 Signed short                  (int16, bitpix=16) 
      8 Signed integer                (int32, bitpix=32) 
     16 Floating point    (single or float32, bitpix=32) 
     32 Complex, 2 float32      (Use float32, bitpix=64) 
     64 Double precision  (double or float64, bitpix=64) 
    512 Unsigned short               (uint16, bitpix=16) 
    768 Unsigned integer             (uint32, bitpix=32) 
        end % private ctor
    end % private methods 
end % classdef NiiTypes