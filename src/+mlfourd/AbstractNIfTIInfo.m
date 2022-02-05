classdef (Abstract) AbstractNIfTIInfo < handle & mlfourd.ImagingInfo
	%% ABSTRACTNIFTIINFO 

	%  $Revision$
 	%  was created 24-Jul-2018 15:07:27 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
    
    methods (Abstract)
        load_info()
    end

    methods (Static)
        function e = defaultFilesuffix()
            e =  mlfourd.NIfTIInfo.FILETYPE_EXT;
        end
        function [X,hdr] = exportNiftiToFourdfp(X, hdr)
            %% provides symmetries for the app programming interface, but performs no transformations 
            %  since internal representations must be NIfTI compatible
        end
    end

    properties (Dependent)
                     Filename % : '/Users/jjlee/Tmp/sub-108293_ses-20210218081506_T1w_MPR_vNav_4e_RMS.nii.gz'
                  Filemoddate % : ''03-Feb-2022 23:34:18'
                     Filesize % : 23936412
                     Version  % : 'NIfTI1'
                  Description % : 'TE=1.8;Time=81506.050;phase=1'
                    ImageSize % : 'TE=1.8;Time=81506.050;phase=1'
              PixelDimensions % : 'TE=1.8;Time=81506.050;phase=1'
                     Datatype % : 'int16'
                 BitsPerPixel % : 16
                   SpaceUnits % : 'Millimeter'
                    TimeUnits % : 'Second'
               AdditiveOffset % : 0
        MultiplicativeScaling % : 1
                   TimeOffset % : 0
                    SliceCode % : 'Unknown'
           FrequencyDimension % : 2
               PhaseDimension % : 1
             SpatialDimension % : 3
        DisplayIntensityRange % : [0 0]
                TransformName % : 'Sform'
                    Transform % : [1×1 affine3d]
                      Qfactor % : 1
                          Raw % : [1x1 struct]
    end
    
	methods 
		  
        %% GET/SET
        
        function g = get.Filename(this)
            g = this.info_.Filename;
        end
        function g = get.Filemoddate(this)
            g = this.info_.Filemoddate;
        end
        function g = get.Filesize(this)
            g = this.info_.Filesize;
        end
        function g = get.Version(this)
            g = this.info_.Version;
        end
        function g = get.Description(this)
            g = this.info_.Description;
        end
        function g = get.ImageSize(this)
            g = this.info_.ImageSize;
        end
        function g = get.PixelDimensions(this)
            g = this.info_.PixelDimensions;
        end
        function g = get.Datatype(this)
            g = this.info_.Datatype;
        end
        function g = get.BitsPerPixel(this)
            g = this.info_.BitsPerPixel;
        end
        function g = get.SpaceUnits(this)
            g = this.info_.SpaceUnits;
        end
        function g = get.TimeUnits(this)
            g = this.info_.TimeUnits;
        end
        function g = get.AdditiveOffset(this)
            g = this.info_.AdditiveOffset;
        end
        function g = get.MultiplicativeScaling(this)
            g = this.info_.MultiplicativeScaling;
        end
        function g = get.TimeOffset(this)
            g = this.info_.TimeOffset;
        end
        function g = get.SliceCode(this)
            g = this.info_.SliceCode;
        end
        function g = get.FrequencyDimension(this)
            g = this.info_.FrequencyDimension;
        end
        function g = get.PhaseDimension(this)
            g = this.info_.PhaseDimension;
        end
        function g = get.SpatialDimension(this)
            g = this.info_.SpatialDimension;
        end
        function g = get.DisplayIntensityRange(this)
            g = this.info_.DisplayIntensityRange;
        end
        function g = get.TransformName(this)
            g = this.info_.TransformName;
        end
        function g = get.Transform(this)
            g = this.info_.Transform;
        end
        function g = get.Qfactor(this) % a.k.a. qfac
            g = this.info_.Qfactor;
        end   
        function g = get.Raw(this)
            g = this.info_.raw;
        end   
		  
        %%
        
        function nii  = apply_scl(~, nii)
            dime = nii.hdr.dime;
            if ~isfield(dime, 'scl_slope')
                return
            end
            if dime.scl_slope == 0 || (dime.scl_slope == 1 && dime.scl_inter == 0) 
                return
            end
            maxi = rescl(dime, dipmax(nii.img));
            if abs(maxi) < realmax('single')
                nii.img = rescl(dime, single(nii.img));
                nii.hdr.dime.scl_slope = 1;
                nii.hdr.dime.scl_inter = 0;
                nii.hdr.dime.glmax = dipmax(single(nii.img));
                nii.hdr.dime.datatype = 16;
                nii.hdr.dime.bitpix = 32;
                return
            else % (abs(maxi) < realmax('double'))
                nii.img = rescl(dime, double(nii.img));
                nii.hdr.dime.scl_slope = 1;
                nii.hdr.dime.scl_inter = 0;
                nii.hdr.dime.glmax = dipmax(double(nii.img));
                nii.hdr.dime.datatype = 64;
                nii.hdr.dime.bitpix = 64;
                return                
            end
            
            function x = rescl(dime, x)
                x = dime.scl_slope*x + dime.scl_inter;
            end
        end
        
 		function this = AbstractNIfTIInfo(varargin)
 			this = this@mlfourd.ImagingInfo(varargin{:});
 		end
 	end 
    
    %% PROTECTED
    
    properties (Access = protected)
        info_ % supports getters with capitalization
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

