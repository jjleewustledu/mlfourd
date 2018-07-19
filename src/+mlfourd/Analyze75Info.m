classdef Analyze75Info < mlfourd.ImagingInfo
	%% ANALYZE75INFO  

	%  $Revision$
 	%  was created 27-Jun-2018 00:34:54 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
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

	methods 

        %% GET/SET
        
        function g = get.Filename(this)
            g = this.info_.Filename;
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
		  
        function [X,untouch,hdr] = analyze75read(this)
            %% calls mlniftitools.load_nii
            
            %X = analyze75read(this.info_); % Matlab native reader
            jimmy = mlniftitools.load_nii(this.Filename); % struct
            X = jimmy.img;
            X = this.permuteX(X); % KLUDGE
            X = this.ensureDatatype(X, this.datatype_);
            untouch = 0;
            hdr = jimmy.hdr;
        end
        function nii = make_nii(this)
            [X,untouch,hdr] = analyze75read(this);    
            hdr = this.adjustHdr(hdr);
            nii = mlniftitools.make_nii( ...
                X, this.PixelDimensions, hdr.hist.originator(1:3), this.datatype_, this.Descriptor);
            nii.img = this.ensureDatatype(nii.img, this.datatype_);
            nii.hdr = this.newHdr(nii.hdr);
            nii.untouch = untouch;
        end
        
 		function this = Analyze75Info(varargin)
 			%% ANALYZE75INFO calls mlniftitools.load_untouch_header_only
 			%  @param filename is required.
 			
            this = this@mlfourd.ImagingInfo(varargin{:});
            
            % from Matlab's native analyze75info
            this.info_ = analyze75info(this.fqfilename); 
            this.info_ = this.permuteInfo(this.info_); % KLUDGE            
            this.raw_.sizeof_hdr = this.HdrFileSize;
            this.raw_.descrip = this.Descriptor;
            this.raw_.aux_file = this.AuxFile;
            this.anaraw_.ByteOrder = this.ByteOrder;
            this.anaraw_.Extents = this.Extents;
            this.anaraw_.ImgDataType = this.ImgDataType;
            this.anaraw_.GlobalMax = this.GlobalMax;
            this.anaraw_.GlobalMin = this.GlobalMin;   
            this.anaraw_.OMax = this.OMax;
            this.anaraw_.OMin = this.OMin;
            this.anaraw_.SMax = this.SMax;
            this.anaraw_.SMin = this.SMin;
            
            % from mlniftitools
            [this.hdr_,this.ext_,this.filetype_,this.machine_] = ...
                mlniftitools.load_untouch_header_only(this.fqfilename);
            this.hdr_ = this.adjustHdr(this.hdr_);            
            this.raw_.dim = this.hdr_.dime.dim;
            this.raw_.datatype = this.hdr_.dime.datatype;
            this.raw_.bitpix = this.hdr_.dime.bitpix;
            this.raw_.pixdim = this.hdr_.dime.pixdim;
            this.raw_.vox_offset = this.hdr_.dime.vox_offset;
            this.raw_.cal_max = this.hdr_.dime.cal_max;
            this.raw_.cal_min = this.hdr_.dime.cal_min;
 		end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        info_
    end
    
    methods (Access = private)
        function hdr  = adjustDime(this, hdr)
            %  KLUDGE:  mlniftitools.make_nii squeezes singleton dimensions s.t. nii.hdr.dime.dim(1) := 3 for single
            %  time frames.  However, load_nii sets nii.hdr.dime.dim(1) := 4 for single time frames.
            %  KLUDGE:  mlniftitools.make_nii populates nii.hdr.dime.pixdim := [0 1 1 1 1 1 1 1].   
            %  However, load_nii tends to set nii.hdr.dime.pixdim := [1 1 1 1 1 0 0 0].
            %  KLUDGE:  mlniftitools.make_nii  sets nii.hdr.dime.vox_offset := 0.
            
            if (this.circshiftK_ > 0 && 3 == hdr.dime.dim(1) && 1 == hdr.dime.dim(5))
                hdr.dime.dim(1) = 4;
            end
            if (0 == hdr.dime.pixdim(1))
                hdr.dime.pixdim(1) = this.circshiftK_;
            end
            if (this.circshiftK_ > 0)
                D = hdr.dime.dim(1);
                hdr.dime.pixdim(D+2:end) = 0;
            end
            hdr.dime.vox_offset = 352;
        end
        function hdr  = adjustHist(~, hdr)
            %  KLUDGE:  mlniftitools.make_nii drops nii.hdr.hist.magic := ''.
            
            hdr.hist.aux_file = '';
            hdr.hist.magic = 'n+1';
            if (isfield(hdr.hist, 'originator'))
                hdr.hist.originator = hdr.hist.originator(1:3);
            end
        end
        function hdr  = newHdr(this, hdr)
            hdr.dime.xyzt_units = 2+8; % mm, sec; see also mlniftitools.extra_nii_hdr
            hdr.hist.qform_code = 0;
            hdr.hist.sform_code = this.sform_code;
            
            %% KLUDGE
            if (this.circshiftK_ > 0)
                srow = [[hdr.dime.pixdim(2) 0 0 (1-hdr.hist.originator(1))*hdr.dime.pixdim(2)]; ...
                        [0 hdr.dime.pixdim(3) 0 (1-hdr.hist.originator(2))*hdr.dime.pixdim(3)]; ...
                        [0 0 hdr.dime.pixdim(4) (1-hdr.hist.originator(3))*hdr.dime.pixdim(4)]];
            else
                srow = -[[0 0 hdr.dime.pixdim(4) (1-hdr.hist.originator(3))*hdr.dime.pixdim(4)];
                         [hdr.dime.pixdim(2) 0 0 (1-hdr.hist.originator(1))*hdr.dime.pixdim(2)]; ...
                         [0 hdr.dime.pixdim(3) 0 (1-hdr.hist.originator(2))*hdr.dime.pixdim(3)]];
            end
            
            hdr.hist.srow_x = srow(1,:);
            hdr.hist.srow_y = srow(2,:);
            hdr.hist.srow_z = srow(3,:);            
            hdr = mlniftitools.extra_nii_hdr(hdr);
            hdr = this.adjustDime(hdr);
            hdr = this.adjustHist(hdr);
        end
        function code = sform_code(this)
            if (this.circshiftK_ > 0)
                code = 3;
            else
                code = 1;
            end
        end
        function info = permuteInfo(this, info)
            info.Width           = info.Dimensions(1);
            info.Height          = info.Dimensions(3);
            if (0 == this.circshiftK_); return; end
            info.PixelDimensions = this.permuteVec1to3(info.PixelDimensions);
            info.Dimensions      = this.permuteVec1to3(info.Dimensions);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

