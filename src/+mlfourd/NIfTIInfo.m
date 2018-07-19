classdef NIfTIInfo < mlfourd.ImagingInfo 
	%% NIFTIINFO emulates Matlab function niftiinfo for use with Matlab versions prior to R2017b.  
    %  See also mlfourd.Analyze75Info, mlfourdfp.FourdfpInfo.  Requires Image Processing Toolbox function affine3d.

	%  $Revision$
 	%  was created 30-Apr-2018 16:39:09 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	
    properties (Dependent)
                     Filename % : '/Users/jjlee/Tmp/T1.nii.gz'
                  Filemoddate % : '30-Apr-2018 16:33:59'
                     Filesize % : 5401810
                  Description % : 'FreeSurfer Jan 19 2017'
                    ImageSize % : [256 256 256]
              PixelDimensions % : [1 1 1]
                     Datatype % : 'uint8'
                 BitsPerPixel % : 8
                   SpaceUnits % : 'Millimeter'
                    TimeUnits % : 'Second'
               AdditiveOffset % : 0
        MultiplicativeScaling % : 0
                   TimeOffset % : 0
                    SliceCode % : 'Unknown'
           FrequencyDimension % : 0
               PhaseDimension % : 0
             SpatialDimension % : 0
        DisplayIntensityRange % : [0 0]
                TransformName % : 'Sform'
                    Transform % : [1×1 affine3d]
                      Qfactor % : -1
    end
    
	methods 
        
        %% GET/SET
        
        function g = get.Filename(this)
            g = this.fqfilename;
        end
        function g = get.Filemoddate(this)
            s = dir(this.Filename);
            g = s.date;
        end
        function g = get.Filesize(this)
            s = dir(this.Filename);
            g = s.bytes;
        end
        function g = get.Description(this)
            g = this.raw_.descrip;
        end
        function g = get.ImageSize(this)
            end_ = 1+this.raw_.dim(1);
            g = this.raw_.dim(2:end_);
        end
        function g = get.PixelDimensions(this)
            end_ = 1+this.raw_.dim(1);
            g = this.raw_.pixdim(2:end_);
        end
        function g = get.Datatype(this)
            switch (this.raw_.datatype)
                case 0
                    g = 'Unknown';
                case 1
                    g = 'ubit1';
                case 2
                    g = 'uint8';
                case 4
                    g = 'int16';
                case 8
                    g = 'int32';
                case 16
                    g = 'single';
                case 32
                    g = 'double'; % complex
                case 64
                    g = 'double';
                case 128
                    g = 'uint8'; % RGB
                case 256
                    g = 'int8';
                case 511
                    g = 'single';
                case 512
                    g = 'uint16';
                case 768
                    g = 'uint32';
                case 1024
                    g = 'int64';
                case 1280
                    g = 'uint64';
                case 1536
                    g = 'Unsupported';
                case 1792
                    g = 'float64';
                case 2048
                    g = 'Unsupported';
                otherwise
                    error('mlfourd:unsupportedSwitchcase', 'NIfTIInfo.get.Datatype');
            end
        end
        function g = get.BitsPerPixel(this)
            g = this.raw_.bitpix;
        end
        function g = get.SpaceUnits(this)
            g = this.spaceUnits_;
        end
        function g = get.TimeUnits(this)
            g = this.timeUnits_;
        end
        function g = get.AdditiveOffset(this)
            g = this.additiveOffset_;
        end
        function g = get.MultiplicativeScaling(this)
            g = this.multiplicativeScaling_;
        end
        function g = get.TimeOffset(this)
            g = this.timeOffset_;
        end
        function g = get.SliceCode(this)
            if (0 == this.raw_.slice_code)
                g = 'Unknown';
                return
            end
            g = this.raw_.slice_code;
        end
        function g = get.FrequencyDimension(this)
            g = this.frequencyDimension_;
        end
        function g = get.PhaseDimension(this)
            g = this.phaseDimension_;
        end
        function g = get.SpatialDimension(this)
            g = this.spatialDimension_;
        end
        function g = get.DisplayIntensityRange(~)
            g = [0 0];
        end
        function g = get.TransformName(~)
            %assert(1 == this.raw_.sform_code, 'mlfourd:unexpectedParamValue', 'NIfTIInfo.get.TransformName')
            g = 'Sform';
        end
        function g = get.Transform(this)
            g = affine3d(this.affineTransform_);
        end
        function g = get.Qfactor(this)
            g = this.raw_.pixdim(1); % guessing
        end   
		  
        %%
        
        function [V,untouch,hdr] = niftiread(this)
            %% calls mlniftitools.load_untouch_nii
            
            jimmy = mlniftitools.load_untouch_nii(this.Filename); % struct
            V = jimmy.img;
            V = this.permuteX(V); % KLUDGE
            V = this.ensureDatatype(V, this.datatype_);
            untouch = jimmy.untouch;
            hdr = jimmy.hdr; % update hdr.dime.{glmax,glmin}
        end
        function nii = make_nii(this)
            [X,untouch,hdr] = niftiread(this);
            hdr = this.adjustHdr(hdr);
            nii.img = this.ensureDatatype(X, this.datatype_);
            nii.hdr = hdr;
            nii.untouch = untouch;
        end
        
 		function this = NIfTIInfo(varargin)
 			%% NIFTIINFO calls mlniftitools.load_untouch_header_only
 			%  @param filename is required.
            
            this = this@mlfourd.ImagingInfo(varargin{:});
            
            [this.hdr_,this.ext_,this.filetype_,this.machine_] = ...
                mlniftitools.load_untouch_header_only(this.fqfilename);
            this.hdr_ = this.adjustHdr(this.hdr_);                
            this.raw_.sizeof_hdr = this.hdr_.hk.sizeof_hdr;
            this.raw_.dim_info = this.hdr_.hk.dim_info;
            this.raw_.dim = this.hdr_.dime.dim;
            this.raw_.intent_p1 = this.hdr_.dime.intent_p1;
            this.raw_.intent_p2 = this.hdr_.dime.intent_p2;
            this.raw_.intent_p3 = this.hdr_.dime.intent_p3;
            this.raw_.intent_code = this.hdr_.dime.intent_code;
            this.raw_.datatype = this.hdr_.dime.datatype;
            this.raw_.bitpix = this.hdr_.dime.bitpix;
            this.raw_.slice_start = this.hdr_.dime.slice_start;
            this.raw_.pixdim = this.hdr_.dime.pixdim;
            this.raw_.vox_offset = this.hdr_.dime.vox_offset;
            this.raw_.scl_slope = this.hdr_.dime.scl_slope;
            this.raw_.scl_inter = this.hdr_.dime.scl_inter;
            this.raw_.slice_end = this.hdr_.dime.slice_end;
            this.raw_.slice_code = this.hdr_.dime.slice_code;
            this.raw_.xyzt_units = this.hdr_.dime.xyzt_units;
            this.raw_.cal_max = this.hdr_.dime.cal_max;
            this.raw_.cal_min = this.hdr_.dime.cal_min;
            this.raw_.slice_duration = this.hdr_.dime.slice_duration;
            this.raw_.toffset = this.hdr_.dime.toffset;
            this.raw_.descrip = this.hdr_.hist.descrip;
            this.raw_.aux_file = this.hdr_.hist.aux_file;
            this.raw_.qform_code = this.hdr_.hist.qform_code;
            this.raw_.sform_code = this.hdr_.hist.sform_code;
            this.raw_.quatern_b = this.hdr_.hist.quatern_b;
            this.raw_.quatern_c = this.hdr_.hist.quatern_c;
            this.raw_.quatern_d = this.hdr_.hist.quatern_d;
            this.raw_.qoffset_x = this.hdr_.hist.qoffset_x;
            this.raw_.qoffset_y = this.hdr_.hist.qoffset_y;
            this.raw_.qoffset_z = this.hdr_.hist.qoffset_z;
            this.raw_.srow_x = this.hdr_.hist.srow_x;
            this.raw_.srow_y = this.hdr_.hist.srow_y;
            this.raw_.srow_z = this.hdr_.hist.srow_z;
            this.raw_.intent_name = this.hdr_.hist.intent_name;
            this.raw_.magic = this.hdr_.hist.magic;
            this.anaraw_.GlobalMax = this.hdr_.dime.glmax;
            this.anaraw_.GlobalMin = this.hdr_.dime.glmin;
            this.anaraw_.ByteOrder = this.machine_;
 		end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        affineTransform_
        additiveOffset_ = 0
        frequencyDimension_ = 0
        multiplicativeScaling_ = 0
        phaseDimension_ = 0
        spatialDimension_ = 0
        spaceUnits_ = 'Millimeter'
        timeOffset_ = 0
        timeUnits_ = 'Second'
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

