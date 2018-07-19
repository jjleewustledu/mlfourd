classdef WholebrainResampler < mlfourd.VoxelResampler
	%% WHOLEBRAINRESAMPLER  

	%  $Revision$
 	%  was created 17-Jun-2018 15:26:52 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.4.0.813654 (R2018a) for MACI64.  Copyright 2018 John Joowon Lee.
 	
	properties
 		
 	end

    methods (Static)
        function this = constructSampledScanner(s, varargin)
            import mlfourd.*;
            sa = s.component;
            sa.img = s.specificActivity;
            this = WholebrainResampler( ...
                'dynamic', ImagingContext(sa), ...
                'mask', ImagingContext(s.mask), ...
                varargin{:});
        end
    end
    
	methods 
		  
        function this = downsample(this)
            this.dynamicOri_ = this.dynamic_;
            this.dynamic_    = this.dynamic_.volumeAveraged(this.mask_);
            this.dynamic_.fileprefix = [this.dynamic_.fileprefix '_wb_downsmpl'];
        end 
        function this = upsample(this)
            msk = this.mask.niftid.img/this.mask.numericalNiftid.dipmax;
            img = this.dynamic_.niftid.img;
            
            sz = size(msk);
            img1 = zeros(sz(1),sz(2),sz(3),length(img));
            for i = 1:sz(1)
                for j = 1:sz(2)
                    for k = 1:sz(3)
                        img1(i,j,k,:) = msk(i,j,k) * img;
                    end
                end
            end
            
            nii = this.dynamic_.niftid;
            nii.img = img1;
            nii.fileprefix = [this.dynamicOri_.fileprefix '_wb_upsmpl'];
            this.dynamic_ = mlfourd.ImagingContext(nii);
        end
 		function this = WholebrainResampler(varargin)
 			%% WHOLEBRAINRESAMPLER
 			%  @param .

            this = this@mlfourd.VoxelResampler(varargin{:});
 		end
    end 

    %% PROTECTED
    
    properties (Access = protected)
        dynamicOri_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

