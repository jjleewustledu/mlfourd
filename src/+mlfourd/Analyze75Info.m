classdef Analyze75Info < handle & mlfourd.ImagingInfo
	%% ANALYZE75INFO  

	%  $Revision$
 	%  was created 27-Jun-2018 00:34:54 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
    properties (Constant) 
        ANALYZE75_EXT = '.hdr';
    end
    
	properties (Dependent)
            Filename % : '/Users/jjlee/Tmp/T1.4dfp.hdr'
         FileModDate % : '02-Jun-2018 18:17:24'
         HdrFileSize % : 348
         ImgFileSize % : 67108864
              Format % : 'Analyze'
       FormatVersion % : '7.5'
               Width % : 256
              Height % : 256
            BitDepth % : 32
           ColorType % : 'grayscale'
           ByteOrder % : 'ieee-le'
         HdrDataType % : ''
        DatabaseName % : ''
             Extents % : 16384
        SessionError % : 0
             Regular % : 1
          Dimensions % : [256 256 256 1]
          VoxelUnits % : ''
    CalibrationUnits % : ''
         ImgDataType % : 'DT_FLOAT'
     PixelDimensions % : [1 1 1]
         VoxelOffset % : 0
      CalibrationMax % : 0
      CalibrationMin % : 0
          Compressed % : 0
            Verified % : 0
           GlobalMax % : 0
           GlobalMin % : 0
          Descriptor % : ''
             AuxFile % : ''
         Orientation % : 'Transverse unflipped'
          Originator % : 'jjlee'
           Generated % : '2018'
          Scannumber % : ''
           PatientID % : ''
        ExposureDate % : 'SatJun2'
        ExposureTime % : '18:17:24'
               Views % : 0
        VolumesAdded % : 0
          StartField % : 0
           FieldSkip % : 0
                OMax % : 0
                OMin % : 0
                SMax % : 0
                SMin % : 0 		
 	end
    
    methods (Static)
        function e = defaultFilesuffix
            e =  mlfourd.Analyze75Info.ANALYZE75_EXT;
        end
    end

	methods 

        %% GET/SET
        
        function g = get.Filename(this)
            g = this.filename;
        end
        function g = get.FileModDate(this)
            g = this.info_.FileModDate;
        end
        function g = get.HdrFileSize(this)
            g = this.info_.HdrFileSize;
        end
        function g = get.ImgFileSize(this)
            g = this.info_.ImgFileSize;
        end
        function g = get.Format(this)
            g = this.info_.Format;
        end
        function g = get.FormatVersion(this)
            g = this.info_.FormatVersion;
        end
        function g = get.Width(this)
            g = this.info_.Width;
        end
        function g = get.Height(this)
            g = this.info_.Height;
        end
        function g = get.BitDepth(this)
            g = this.info_.BitDepth;
        end
        function g = get.ColorType(this)
            g = this.info_.ColorType;
        end
        function g = get.ByteOrder(this)
            g = this.info_.ByteOrder;
        end
        function g = get.HdrDataType(this)
            g = this.info_.HdrDataType;
        end
        function g = get.DatabaseName(this)
            g = this.info_.DatabaseName;
        end
        function g = get.Extents(this)
            g = this.info_.Extents;
        end
        function g = get.SessionError(this)
            g = this.info_.SessionError;
        end
        function g = get.Regular(this)
            g = this.info_.Regular;
        end
        function g = get.Dimensions(this)
            g = this.info_.Dimensions;
        end
        function g = get.VoxelUnits(this)
            g = this.info_.VoxelUnits;
        end
        function g = get.CalibrationUnits(this)
            g = this.info_.CalibrationUnits;
        end
        function g = get.ImgDataType(this)
            g = this.info_.ImgDataType;
        end
        function g = get.PixelDimensions(this)
            g = this.info_.PixelDimensions;
        end        
        function g = get.VoxelOffset(this)
            g = this.info_.VoxelOffset;
        end
        function g = get.CalibrationMax(this)
            g = this.info_.CalibrationMax;
        end
        function g = get.CalibrationMin(this)
            g = this.info_.CalibrationMin;
        end
        function g = get.Compressed(this)
            g = this.info_.Compressed;
        end
        function g = get.Verified(this)
            g = this.info_.Verified;
        end
        function g = get.GlobalMax(this)
            g = this.info_.GlobalMax;
        end
        function g = get.GlobalMin(this)
            g = this.info_.GlobalMin;
        end
        function g = get.Descriptor(this)
            g = this.info_.Descriptor;
        end
        function g = get.AuxFile(this)
            g = this.info_.AuxFile;
        end
        function g = get.Orientation(this)
            if (isempty(this.info_))
                in_ = analyze75info(this.fqfilename); % Matlab's native
                in_ = this.permuteInfo(in_); % KLUDGE
                g = in_.Orientation;
                return
            end
            g = this.info_.Orientation;
        end
        function g = get.Originator(this)
            g = this.info_.Originator;
        end
        function g = get.Generated(this)
            g = this.info_.Generated;
        end
        function g = get.Scannumber(this)
            g = this.info_.Scannumber;
        end
        function g = get.PatientID(this)
            g = this.info_.PatientID;
        end
        function g = get.ExposureDate(this)
            g = this.info_.ExposureDate;
        end
        function g = get.ExposureTime(this)
            g = this.info_.ExposureTime;
        end
        function g = get.Views(this)
            g = this.info_.Views;
        end
        function g = get.VolumesAdded(this)
            g = this.info_.VolumesAdded;
        end
        function g = get.StartField(this)
            g = this.info_.StartField;
        end
        function g = get.FieldSkip(this)
            g = this.info_.FieldSkip;
        end
        function g = get.OMax(this)
            g = this.info_.OMax;
        end
        function g = get.OMin(this)
            g = this.info_.OMin;
        end
        function g = get.SMax(this)
            g = this.info_.SMax;
        end
        function g = get.SMin(this)
            g = this.info_.SMin;
        end
        
        %%        
		  
        function fqfn = fqfileprefix_hdr(this)
            fqfn = strcat(this.fqfileprefix, '.hdr');
        end
        function fqfn = fqfileprefix_img(this)
            fqfn = strcat(this.fqfileprefix, '.img');
        end
        
 		function this = Analyze75Info(varargin)
 			%% ANALYZE75INFO calls mlniftitools.load_untouch_header_only
 			%  @param filename is required.
 			
            this = this@mlfourd.ImagingInfo(varargin{:});                
            
%             if (~isfile(this.fqfilename))
%                 return
%             end            
%             this.info_ = analyze75info(this.fqfilename); % Matlab's native 
%             this.info_ = this.permuteInfo(this.info_); % KLUDGE
%             
%             % from mlniftitools
%             [this.hdr_,this.ext_,this.filetype_,this.machine_] = this.load_untouch_header_only;
        end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        info_ % supports getters with capitalization
    end

    methods (Access = protected)
        function a = anarawLocal(this)
            assert(~isempty(this.hdr_));
            a = struct( ...
                'ByteOrder', this.ByteOrder, ...
                'Extents', this.Extents, ...
                'ImgDataType', this.ImgDataType, ...
                'GlobalMax', this.GlobalMax, ...
                'GlobalMin', this.GlobalMin, ...
                'OMax', this.OMax, ...
                'Omin', this.OMin, ...
                'SMax', this.SMax, ...
                'SMin', this.SMin); 
        end
    end

    %% PRIVATE

    methods (Access = private)
        function info = permuteInfo(this, info)
            info.Width           = info.Dimensions(1);
            info.Height          = info.Dimensions(3);
            if (0 == this.circshiftK_)
                return
            end
            info.PixelDimensions = this.permuteCircshiftVec(info.PixelDimensions);
            info.Dimensions      = this.permuteCircshiftVec(info.Dimensions);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

