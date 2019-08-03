classdef DynamicsTool < handle & mlfourd.ImagingFormatTool
	%% DYNAMICSTOOL

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$  	 

    properties (Constant)
        AVGT_SUFFIX   = '_avgt'
        AVGXYZ_SUFFIX = '_avgxyz'
        SUMT_SUFFIX   = '_sumt'
        SUMXYZ_SUFFIX = '_sumxyz'
    end
    
	methods 
        function this = del2(this, varargin)
            this.innerImaging_.img = del2(this.innerImaging_.img, varargin{:});
            this.addLog('DynamicsTool.del2');
        end
        function this = diff(this, varargin)
            %% applies Matlab diff over time samples, time dimension will be smaller by 1.
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            img = diff(img, varargin{:});
            this.innerImaging_.img = shiftdim(img, 1);
            this.addLog('DynamicsTool.diff');
        end
        function this = gradient(this, varargin)
            %% replaces img in R^n with img in R^(n+1) such that last dim contains gradient components.
            %  E.g.,  for input in R^4, return R^5 with last dim containing gradient components [e_x e_y e_z e_t].
            
            imgz = zeros([size(this.innerImaging_.img) this.ndims]);
            if (4 == this.ndims)
                img = this.innerImaging_.img;
                [imgz(:,:,:,:,1),imgz(:,:,:,:,2),imgz(:,:,:,:,3),imgz(:,:,:,:,4)] = gradient(img, varargin{:});
                this.innerImaging_.img = imgz;
                this.addLog('DynamicsTool.gradient');
                return
            end
            if (3 == this.ndims)
                img = this.innerImaging_.img;
                [imgz(:,:,:,1),imgz(:,:,:,2),imgz(:,:,:,3)] = gradient(img, varargin{:});
                this.innerImaging_.img = imgz;
                this.addLog('DynamicsTool.gradient');
                return
            end
            error('mlfourd:RuntimeError', 'DynamicsTool.gradient.ndims->%i', this.ndims)
        end
        function this = mean(this, varargin)
            %% applies Matlab mean over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            this.innerImaging_.img = squeeze(mean(img, varargin{:}));
            this.addLog('DynamicsTool.mean');
        end
        function this = median(this, varargin)
            %% applies Matlab median over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            this.innerImaging_.img = squeeze(median(img, varargin{:}));
            this.addLog('DynamicsTool.median');
        end
        function this = mode(this, varargin)
            %% applies Matlab mode over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            this.innerImaging_.img = squeeze(mode(img, varargin{:}));
            this.addLog('DynamicsTool.mode');
        end
        
        function this = Q(this, varargin)
            %% Q is the sum of squares := \Sigma_t [this_t - ref_t]^2
            
            assert(4 == this.ndims)
            if 4 == ref.ndims
                for iT = 1:size(this.innerImaging_, 4)
                    this.innerImaging_.img(:,:,:,iT) = this.innerImaging_.img(:,:,:,iT).^2;
                end
            end
            this.addLog('DynamicsTool.Q')
        end
        function this = std(this, varargin)
            %% applies Matlab std over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            this.innerImaging_.img = squeeze(std(img, varargin{:}));
            this.addLog('DynamicsTool.std');
        end
        function this = timeAveraged(this, varargin)
            %  @param optional T \in \mathbb{N}^n, n := length(T), masks by time indices; 
            %  e.g., [1 2 ... n] or [2 3 ... (n-1)].
            %  @param taus are frame durations in sec; default := 1:size(this.innerImaging_, 4)
            
            NT = size(this.innerImaging_, 4);
            ip = inputParser;
            addOptional(ip, 'T',  1:NT, @isnumeric);
            addParameter(ip, 'taus', ones(1, NT), @isnumeric);
            parse(ip, varargin{:});
            T = ip.Results.T;
            try                
                taus = ip.Results.taus(T);
            catch ME
                handwarning(ME, ...
                    'mlfourd:RuntimeError', ...
                    'DynamicsTool.timeAveraged:  supplied taus may be inconsistent:  %s', num2str(ip.Results.taus))
                taus = ones(1, NT) * ip.Results.taus(end);
                NT1 = length(ip.Results.taus);
                taus(1:NT1) = ip.Results.taus;
            end
            wtaus = taus/sum(taus);
            assert(~isempty(T));
            assert(~isempty(taus));
            
            for iT = T
                this.innerImaging_.img(:,:,:,iT) = wtaus(iT) .* this.innerImaging_.img(:,:,:,iT);
            end
            this.innerImaging_.img = sum(this.innerImaging_.img, 4, 'omitnan');
            this.fileprefix = [this.fileprefix this.AVGT_SUFFIX];
            this.addLog('DynamicsTool.timeAveraged weighted by %s', mat2str(1./taus));
        end
        function this = timeContracted(this, varargin)
            %  @param optional T \in \mathbb{N}^n, n := length(T), masks by time indices; 
            %  e.g., [1 2 ... n] or [2 3 ... (n-1)].
            
            ip = inputParser;
            addOptional(ip, 'T', 1:size(this.innerImaging_,4), @isnumeric);
            parse(ip, varargin{:});            
            T = ip.Results.T;
            
            this.innerImaging_.img = this.innerImaging_.img(:,:,:,T);
            this.innerImaging_.img = sum(this.innerImaging_.img, 4, 'omitnan');
            if (isempty(varargin))
                this.fileprefix = [this.fileprefix this.SUMT_SUFFIX];
            else
                this.fileprefix = sprintf('%s%s%g-%g', this.fileprefix, this.SUMT_SUFFIX, T(1), T(end));
            end
            this.addLog('DynamicsTool.timeContracted over %s', mat2str(T));
        end  
        function this = var(this, varargin)
            %% applies Matlab var over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            this.innerImaging_.img = squeeze(var(img, varargin{:}));
            this.addLog('DynamicsTool.var');
        end        
        function [this,M] = volumeAveraged(this, varargin)
            %  @param optional M is a mask, max(mask) == 1, understood by ImagingContext2.
            
            [this,M] = this.volumeContracted(varargin{:});            
            this.innerImaging_.img = this.innerImaging_.img / sum(sum(sum(M.nifti.img, 'omitnan'), 'omitnan'), 'omitnan');
            this.fileprefix = [this.fileprefix this.AVGXYZ_SUFFIX];
            this.addLog('DynamicsTool.volumeAveraged');
        end
        function [this,M] = volumeContracted(this, varargin)
            %  @param optional M is a mask, max(mask) == 1, understood by ImagingContext2.
            
            sz = this.innerImaging_.size;
            ones_ = ones(sz(1:3));
            ip = inputParser;
            addOptional(ip, 'M', ones_);
            parse(ip, varargin{:});
            this.verifyMaxMaskIsUnity(ip.Results.M);
            M = mlfourd.ImagingContext2(ip.Results.M);
            
            ming = M.nifti.img;
            for t = 1:sz(4)
                this.innerImaging_.img(:,:,:,t) =  ...
                    this.innerImaging_.img(:,:,:,t) .* ming;
            end            
            this.innerImaging_.img = ...
                ensureRowVector( ...
                    squeeze( ...
                        sum(sum(sum(this.innerImaging_.img, 1, 'omitnan'), 2, 'omitnan'), 3, 'omitnan')));
            if (lstrfind(M.fileprefix, 'rand'))
                this.fileprefix = [this.fileprefix this.SUMXYZ_SUFFIX];
            else
                this.fileprefix = [this.fileprefix this.SUMXYZ_SUFFIX upper(M.fileprefix(1)) M.fileprefix(2:end)];
            end
            this.addLog('DynamicsTool.volumeContracted over %s', M.fileprefix);            
        end
        
 		function this = DynamicsTool(h, varargin)
            this = this@mlfourd.ImagingFormatTool(h, varargin{:}); 
            assert(4 == this.innerImaging_.ndims);
        end 
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function verifyMaxMaskIsUnity(this, M)
            M = mlfourd.ImagingContext2(M);
            ming = M.nifti.img;
            if (1 ~= dipmax(ming))
                this.addLog('DynamicsTool.verifyMaxMaskIsUnity dipmax(ming) == %g', dipmax(ming));
                warning('mlfourd:failedToVerify', 'DynamicsTool.verifyMaxMaskIsUnity');
            end
        end
    end
      
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

