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
        function this = coeffvar(this, varargin)
            s = std(copy(this), varargin{:});
            m = mean(copy(this), varargin{:});
            this.innerImaging_.img = s.innerImaging_.img ./ m.innerImaging_.img;
            this.addLog('DynamicsTool.coeffvar');
        end
        function this = del2(this, varargin)
            this.innerImaging_.img = del2(this.innerImaging_.img, varargin{:});
            this.addLog('DynamicsTool.del2');
        end
        function this = diff(this, varargin)
            %% DIFF applies Matlab diff over time samples, time dimension will be smaller by 1.
            %  See also:  Matlab diff.
            
            img = shiftdim(this.innerImaging_.img, this.ndims-1); % t is leftmost
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
        function this = interp1(this, varargin)
            ip = inputParser;
            addRequired(ip, 'times0', @isnumeric)
            addRequired(ip, 'times1', @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            img = this.innerImaging_.img;
            sz = size(img);
            img = reshape(img, [sz(1)*sz(2)*sz(3) sz(4)]);
            img = interp1(ipr.times0, img, ipr.times1);
            img = reshape(img, [sz(1) sz(2) sz(3) length(ipr.times1)]);
            this.innerImaging_.img = img;            
            this.fileprefix = [this.fileprefix '_interp1'];
        end
        function this = makima(this, varargin)
            ip = inputParser;
            addRequired(ip, 'times0', @isnumeric)
            addRequired(ip, 'times1', @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            img = this.innerImaging_.img;
            sz = size(img);
            img = reshape(img, [sz(1)*sz(2)*sz(3) sz(4)]);
            img = makima(ipr.times0, img, ipr.times1);
            img = reshape(img, [sz(1) sz(2) sz(3) length(ipr.times1)]);
            this.innerImaging_.img = img;            
            this.fileprefix = [this.fileprefix '_makima'];
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
        function this = pchip(this, varargin)
            ip = inputParser;
            addRequired(ip, 'times0', @isnumeric)
            addRequired(ip, 'times1', @isnumeric)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            img = this.innerImaging_.img;
            sz = size(img);
            img = reshape(img, [sz(1)*sz(2)*sz(3) sz(4)]);
            img = pchip(ipr.times0, img, ipr.times1);
            img = reshape(img, [sz(1) sz(2) sz(3) length(ipr.times1)]);
            this.innerImaging_.img = img;            
            this.fileprefix = [this.fileprefix '_pchip'];
        end  
        function this = Q(this, varargin)
            %% Q is the sum of squares of time series := \Sigma_t this_t.^2.
            
            assert(4 == this.ndims)
            for iT = 1:size(this.innerImaging_, 4)
                this.innerImaging_.img(:,:,:,iT) = this.innerImaging_.img(:,:,:,iT).^2;
            end
            this.innerImaging_.img = sum(this.innerImaging_, 4, 'omitnan');
            this.addLog('DynamicsTool.Q')
        end
        function this = std(this, varargin)
            %% applies Matlab std over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            this.innerImaging_.img = squeeze(std(img, varargin{:}));
            this.addLog('DynamicsTool.std');
        end
        function [this,T] = timeAveraged(this, varargin)
            %  @param optional T \in \mathbb{N}^length(T), masks by time indices; 
            %  e.g., [1 2 ... n] or [2 3 ... (n-1)].
            %  @param weights for each time \in T.
            %  @param taus => weights := taus / sum(taus), superceding other requests for weights.
            
            Nt = size(this.innerImaging_, 4);
            ip = inputParser;
            addOptional(ip, 'T',  1:Nt, @isnumeric);
            addParameter(ip, 'weights', [], @isnumeric)
            addParameter(ip, 'taus', [], @isnumeric);
            parse(ip, varargin{:});
            ipr = ip.Results;
            T = ipr.T;
            if ~isempty(ipr.weights)
                try                
                    ipr.weights = ipr.weights(T);                
                catch ME
                    handexcept(ME, ...
                        'mlfourd:RuntimeError', ...
                        'DynamicsTool.timeAveraged:  supplied weights may be inconsistent:  %s', num2str(ipr.weights))
                end 
            end
            
            if ~isempty(ipr.taus)
                try                    
                    ipr.weights = ipr.taus / sum(ipr.taus);
                    ipr.weights = ipr.weights(T);                
                catch ME
                    handexcept(ME, ...
                        'mlfourd:RuntimeError', ...
                        'DynamicsTool.timeAveraged:  supplied weights may be inconsistent:  %s', num2str(ipr.weights))
                end 
            end
            
            if isempty(ipr.weights)               
                this.innerImaging_.img = sum(this.innerImaging_.img(:,:,:,T), 4, 'omitnan') / length(T);
                namesAndLogging()
                return
            end
                       
            this.innerImaging_.img = this.innerImaging_.img(:,:,:,T); % truncate series
            for it = 1:length(T)
                this.innerImaging_.img(:,:,:,it) = ipr.weights(it) * this.innerImaging_.img(:,:,:,it); % weight series
            end
            this.innerImaging_.img = sum(this.innerImaging_.img, 4, 'omitnan'); % sum series
            namesAndLogging()                        
            
            function namesAndLogging()
                this.fileprefix = [this.fileprefix this.AVGT_SUFFIX];
                if length(T) ~= Nt
                    this.fileprefix = [this.fileprefix sprintf('%i-%i', T(1), T(end))];
                end
                this.addLog('DynamicsTool.timeAveraged weighted by %s', mat2str(ipr.taus/sum(ipr.taus)));
            end
        end
        function [this,T] = timeContracted(this, varargin)
            %  @param optional T \in \mathbb{N}^length(T), masks by time indices; 
            %  e.g., [1 2 ... n] or [2 3 ... (n-1)].
            
            ip = inputParser;
            addOptional(ip, 'T', 1:size(this.innerImaging_,4), @isnumeric);
            parse(ip, varargin{:});            
            T = ip.Results.T;
            
            this.innerImaging_.img = this.innerImaging_.img(:,:,:,T);
            this.innerImaging_.img = sum(this.innerImaging_.img, 4, 'omitnan');
            
            % names & logging
            this.fileprefix = [this.fileprefix this.SUMT_SUFFIX];
            if ~isempty(varargin)
                this.fileprefix = sprintf('%s%g-%g', this.fileprefix, T(1), T(end));
            end
            this.addLog('DynamicsTool.timeContracted over %s', mat2str(T));
        end  
        function [times,this] = timeShifted(this, times, Dt)
            %% TIMESHIFTED
            %  @param required times is numeric, possibly nonuniform.
            %  @param required Dt is scalar.
            %  @return times & this shifted forwards (Dt > 0) or backwards (Dt < 0) in time.
            
            assert(isnumeric(times))
            assert(isscalar(Dt))
            
            [times,this.innerImaging_.img] = shiftNumeric(times, this.innerImaging_.img, Dt);
            
            % names & logging
            this.fileprefix = sprintf('%s_timeShifted%g', this.fileprefix, Dt);
            this.addLog('DynamicsTool.timeShifted by %g', Dt);
        end  
        function this = var(this, varargin)
            %% applies Matlab var over time samples
            
            assert(4 == this.ndims)
            img = shiftdim(this.innerImaging_.img, 3); % t is leftmost
            this.innerImaging_.img = squeeze(var(img, varargin{:}));
            this.addLog('DynamicsTool.var');
        end        
        function [this,M] = volumeAveraged(this, varargin)
            %  @param optional mask | max(mask) == 1, understood by ImagingContext2.
            
            [this,M] = this.volumeContracted(varargin{:});    
            boolM = M.logical;
            dbleM = double(boolM);
            this.innerImaging_.img = this.innerImaging_.img / sum(dbleM(dbleM > 0), 'omitnan');
            
            % names & logging
            this.fileprefix = strrep(this.fileprefix, this.SUMXYZ_SUFFIX, this.AVGXYZ_SUFFIX);
            this.addLog('DynamicsTool.volumeAveraged');
        end
        function [this,M] = volumeContracted(this, varargin)
            %  @param optional  mask | max(mask) == 1, understood by ImagingContext2.
            
            sz = this.innerImaging_.size;
            ip = inputParser;
            addOptional(ip, 'M', ones(sz(1:3)));
            parse(ip, varargin{:});
            M = mlfourd.ImagingContext2(ip.Results.M);
            boolM = M.logical;
            
            if 4 == length(sz)
                img = zeros(1,sz(4));
                for t = 1:sz(4)
                    iiimg = this.innerImaging_.img(:,:,:,t);
                    img(t) = sum(iiimg(boolM), 'omitnan');
                end
                this.innerImaging_.img = img;
            else
                this.innerImaging_.img = sum(this.innerImaging_.img(boolM), 'omitnan');
            end
            
            % names & logging
            this.fileprefix = [this.fileprefix this.SUMXYZ_SUFFIX];
            if (~lstrfind(M.fileprefix, 'rand'))
                this.fileprefix = [this.fileprefix upper(M.fileprefix(1)) M.fileprefix(2:end)];
            end
            this.addLog('DynamicsTool.volumeContracted over %s', M.fileprefix);            
        end
        
 		function this = DynamicsTool(h, varargin)
            this = this@mlfourd.ImagingFormatTool(h, varargin{:}); 
        end 
    end
      
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

