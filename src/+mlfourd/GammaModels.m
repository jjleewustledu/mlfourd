classdef GammaModels 
	%% GAMMAMODELS simulates data using models based on the gamma-functional.
    %  Uses factory & strategy design pattersn.
    %  For help, cf. 'help GammaModels.makeModel' and 'help GammaModels.runModel'
    %
	%% Version $Revision$ was created $Date$ by $Author$  
 	%% and checked into svn repository $URL$ 
 	%% Developed on Matlab 7.10.0.499 (R2010a) 
 	%% $Id$  

    properties (Constant)
        NT = 50;
        TR = 1.5;
    end
    
	properties 
        name   = '';   % model name
        funh   = 0;    % function handle
        times  = 0;    % row-vector of measurement epochs (sec)
        params = {[]}; % variable
    end

	methods (Static)

        function gv   = gammaVariate(a, b, t0, times)
            
            gv = zeros(size(times));
            for n = 1:length(times)
                if (times(n) > t0)
                    gv(n) = (times(n) - t0)^a * exp(-b*(times(n) - t0));
                end
            end
        end % static gammaVariate
        
        function gm   = makeGammaModel
            
            import mlfourd.*;
            gm = GammaModels('mrconst', GammaModels.makeParams);
            gm.funh = @gm.localAifMrConst;
        end
        
        function pars = makeParams(pref, suff, modelName)
            
            %% MAKEPARAMS makes params cell-array from NIfTI in the current directory
            %  Usage:  mdl = GammaModels.makeParams([file_prefix, file_suffix, model_name']);
            %                                        ^ may be cell
            %                                                     ^ '_Mean.4dfp.nii.gz' default
            %                                                                  ^ 'Mr_Const' default
                import mlfourd.*;
                pipereg = PipelineRegistry.instance;
                disp(['searching for parameter data in ' pwd ' ..........']);
                if (nargin < 3); modelName =  'MrRec'; end
                if (nargin < 2); suff      =  '_Mean.4dfp.nii.gz'; end
                if (nargin < 1); pref      = {['BMIP_LocalAIF_' modelName '_'], 'BMIP_Derived'}; end
                if (~iscell(pref))
                    pref0 = pref;
                    pref  = cell(2,1);
                    pref{1} = pref0;
                    pref{2} = 'BMIP_Mean';
                end
                pars.alpha  = NIfTI.load([pref{1} 'alpha' suff]);
                pars.beta   = NIfTI.load([pref{1} 'beta'  suff]);
                pars.gamma  = NIfTI.load([pref{1} 'gamma' suff]);
                pars.cbf    = NIfTI.load([pref{1} 'cbfFirst'   suff]);
                pars.cbv    = NIfTI.load([pref{2} 'CBV'   suff]);
                pars.mtt    = NIfTI.load([pref{2} 'MTT'   suff]);
            try
                fname       = [pref{1} 'S0_Set_01' suff];
                pars.s0     = NIfTI.load(fname);
                
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no files containing', ...
                    fname);
            end
            try
                fname       = [pref{2} 'AmpInit'  suff];
                pars.s0     = NIfTI.load(fname);
                
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no files containing', ...
                    fname);
            end
            try
                fname       = [pref{2} 'AmpFinal' suff];
                pars.ampf   = NIfTI.load(fname);
                
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no files containing', ...
                    fname);
            end
            try
                fname       = [pref{1} 'cbfRecirc'   suff];
                pars.cbf2   = NIfTI.load(fname);
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no file containing', ...
                    fname);
            end
                pars.t0     = NIfTI.load([pref{1} 'T0'     suff]);
            try
                fname       = [pref{1} 'T02' suff];
                pars.t02    = NIfTI.load(fname);
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n\t%s\n','GammaModels.makeParams:  found no file containing', ...
                    fname);
            end
            try
                fname       = [pref{2} 'Const'  suff];
                pars.const  = NIfTI.load(fname);
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no file containing', ...
                    fname);
            end
            try
                fname       = [pref{1} 'ConstRecirc' suff];
                pars.const2 = NIfTI.load(fname);
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no file containing', ...
                    fname);
            end
            try
                fname       = [pref{2} 'Nu' suff];
                pars.nu     = NIfTI.load(fname);
            catch ME %#ok<NASGU>
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no file containing', ...
                    fname);
            end
            try
                fname         = 'BMIP_ProbModel_NoSignal.4dfp.nii.gz';
                pars.nosignal = NIfTI.load(fname);
            catch ME
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no files containing', ...
                    fname);
                if (pipereg.verbosity > 0.5); disp(ME); end
            end
            try
                fname          = ['BMIP_ProbModel_LocalAIF_' modelName '.4dfp.nii.gz'];
                pars.probModel = NIfTI.load(fname);
            catch ME
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no files containing', ...
                    fname);
                if (pipereg.verbosity > 0.5); disp(ME); end
            end
            try
                fname       = ['BMIP_NoiseStdDev_Set_01' suff];
                pars.noiseSD = NIfTI.load(fname);
            catch ME
                fprintf(1,'%s\n\t%s\n','GammaModels.makeParams:  found no files containing', ...
                    fname);
                if (pipereg.verbosity > 0.5); disp(ME); end
            end
        end
        
        function mdl  = makeFilesModel(name, pref, suff)
            
            %% MAKEFILESMODEL makes params cell-array, then GammaModels object, 
            %  from NIfTI in the current directory
            %  Usage:  mdl = GammaModels.makeParams(model_name, file_prefix, file_suffix);
            %  See also:   makeParams, makeModel
            import mlfourd.*;
            pars = GammaModels.makeParams(pref, suff);
            mdl  = GammaModels.makeModel( name, pars);
        end
        
        function mdl  = makeModel(name, params, t)
            
            %% MAKEMODEL returns the model object identified by name; is a factory;
            %            a row-vector of measurement epochs may be supplied.
            %            Prefer static factories for making models to
            %            retain encapsulation.
            %  Usage:  mdl  = GammaModels.makeModel(name, params [, t]);
            %                                       ^ string:     'default', 'const', 'rec', 'recconst'
            %                                         or numeric:  1       ,  2     ,  3   ,  4
            %                                             ^ struct containing:
            %                                               default:   a, b, g, cbf
            %                                               const:     ", nu, const
            %                                               rec:       a, b, g, cbf, cbf2
            %                                               recconst:  ", nu, const, const2
            %                                                       ^ row-vector of measured epochs
            %          foft = mdl.runModel(params [, p1, p2, ..., t]);
            %
            %  E.g.:   mdl     = GammaModels.makeModel('default', params-struct, t-vector)
            %          foft    = mdl.runModel;
            %          params2 = {[...]};
            %          foft    = mdl.runModel(params2);
            %
            import mlfourd.*;
            assert(logical(exist('name',   'var')));
            assert(logical(exist('params', 'var')));
            assert(isstruct(params));
            if (~exist('t', 'var'))
                t = 0:GammaModels.TR:(GammaModels.TR*GammaModels.NT);
            end
            assert(isnumeric(t));
            if (isnumeric(name)); name = num2str(name); end
            assert(ischar(name));
            mdl = GammaModels(name, params, t);
        end
        
        function dt   = dtimes(t0, t, sz)
            
            %% DTIMES = t - t0, for row-vector t, image-array t0
            %  sz is the size of the image-array at fixed time
            t0      = double(t0);
            assert(isnumeric(sz));
            assert(isnumeric(t));
            assert(isnumeric(t0));
            outersz = horzcat([1 1], sz);
            if (size(t,1) > size(t,2)); t = t'; end % ensure row vector
            lent    = length(t);
            t       = shiftdim(squeeze(repmat(t, outersz)), 1);
            outert  = horzcat([1 1 1], lent);
            t0      = repmat(t0, outert);
            dt      = t - t0;
        end % static dtimes
        
        function arg  = modelArg(params, dt)
            
            %% MODELARG = $\int_0^t d\tau C(\tau)$ for tracer concentration $C$.
            import mlfourd.*;
            assert(isfield(params, 'alpha'));
            assert(isfield(params, 'beta'));
            assert(isfield(params, 'gamma'));
            assert(isfield(params, 'cbf'));
            nt  = size(dt, 4);
            a   = repmat(double(params.alpha), [1 1 1 nt]);
            b0  = repmat(double(params.beta),  [1 1 1 nt]);
            g0  = repmat(double(params.gamma), [1 1 1 nt]);
            b   =    max(double(b0), double(g0));
            g   =    min(double(b0), double(g0));
            cbf = repmat(double(params.cbf),   [1 1 1 nt]);
            assert(isnumeric(a));
            assert(isnumeric(b));
            assert(isnumeric(g));
            assert(isnumeric(cbf));
            assert(isnumeric(dt));
            
            valid  = ~(dt < 0);
            dt     =   dt .* valid; 
            pd     = params.cbf.pixdim; pd(4) = GammaModels.TR;
            numnii = params.cbf.makeSimilar(cbf.*b.^(a+1), 'numerator',   'numerator',   pd);
            numnii = NiiBrowser(numnii, [0 0 0 0], [1 1 1 1]);
            dennii = params.cbf.makeSimilar((b-g).^(a+1),  'denominator', 'denominator', pd);
            dennii = NiiBrowser(dennii, [0 0 0 0], [1 1 1 1]);
            arg    = double(numnii.safe_quotient(dennii));
            arg    = arg .* exp(-g .* dt) .* gammainc((b-g).^dt, a+1);
        end % static modelArg
        
        function arg  = modelConst(params, dt)
            
            import mlfourd.*;
            assert(isfield(params, 'gamma'));
            assert(isfield(params, 'nu'));
            assert(isfield(params, 'const'));
            nt = size(dt, 4);
            g  = repmat(double(params.gamma), [1 1 1 nt]);
            nu = repmat(double(params.nu),    [1 1 1 nt]);
            c  = repmat(double(params.const), [1 1 1 nt]);
            assert(isnumeric(g));
            assert(isnumeric(nu));
            assert(isnumeric(c));
            assert(isnumeric(dt));
            
            valid   = ~(dt < 0);
            dt      =   dt .* valid; 
            pd      = params.const.pixdim; pd(4) = GammaModels.TR;
            numnii  = params.const.makeSimilar(1 - exp(-g .* dt), ...
                'numerator',   'numerator',   pd);
            numnii  = NiiBrowser(numnii, [0 0 0 0], [1 1 1 1]);
            dennii  = params.const.makeSimilar(g, ...
                'denominator', 'denominator', pd);
            dennii  = NiiBrowser(dennii, [0 0 0 0], [1 1 1 1]);
            arg     = double(numnii.safe_quotient(dennii));
            numnii2 = params.const.makeSimilar(exp(-nu .* dt) - exp(-g .* dt), ...
                'numerator2',   'numerator2',   pd);
            numnii2 = NiiBrowser(numnii2, [0 0 0 0], [1 1 1 1]);
            dennii2 = params.const.makeSimilar(nu - g, ...
                'denominator2', 'denominator2', pd);
            dennii2 = NiiBrowser(dennii2, [0 0 0 0], [1 1 1 1]);
            arg2    = double(numnii2.safe_quotient(dennii2));
            arg    = c .* arg + c .* arg2;
        end % static modelConst
    end % static methods
    
        
    methods 

        function foft = runModel(this, params, varargin)
            
            %% RUNMODEL is the preferred public accessor of models
            %  Usage:   mdl  = GammaModels.makeModel(name, params[, t])
            %           foft = mdl.runModel([params, cbf, const, ..., t])
            %                                ^ struct
            %                                        ^ additional parameters
            switch (lower(this.name))
                case {'localaifmr',         'mr',         'default',                              '1', '0'}
                    this.funh = @this.localAifMr;
                case {'localaifmrconst',    'mrconst',    'mr_const',     'const',                '2'}
                    this.funh = @this.localAifMrConst;
                case {'localaifmrrec',      'mrrec',      'mr_rec',       'rec',                  '3'}
                    this.funh = @this.localAifMrRec;
                case {'localaifmrrecconst', 'mrrecconst', 'mr_rec_const', 'recconst', 'constrec', '4'}
                    this.funh = @this.localAifMrRecConst;
                otherwise
                    paramError(this, 'this.name', this.name);
            end
            if (exist('params', 'var'))
                assert(isstruct(params));
                this.params = params;
            end
            foft = this.funh(this.params, varargin{:});
        end
        
        function n    = nt(this)
            
            %% NT returns the length of the samples in time
            if (~isempty(this.times))
                n = length(this.times);
            else
                n = this.NT;
            end
        end
        
        function mask = postbolus(this, t0)
            
            %% POSTBOLUS returns a mask of voxels (x) epochs which are post-bolus-arrival
            %  Usage:   postbolus_mask = obj.postbolus(t0_map)
            %           ^ empty if all t0 come before the first sampled epoch
            t0 = double(t0);
            if (all(t0 < this.times(1)))
                mask = [];
                return
            end
            mask = zeros(size(repmat(t0, [1 1 1 this.nt])));
            for t = 1:this.nt
                mask(:,:,:,t) = ~(t0 > this.times(t));
            end
        end
        
        function        paramsShowDipimg(this)
            fields = fieldnames(this.params);
            for p  = 1:length(this.params)
                this.params.(fields{p}).dipshow;
            end
        end
    end % public methods
       
    methods %(Access='protected') 

        function [foft,this] = localAifMr(this, params, cbf, t)
            
            %% LOCALAIFMR
            %  Usage:   obj  = makeModel('localAifMrRec');
            %           foft = obj.runModel(params, cbf);
            import mlfourd.*;
            assert(isstruct(params));
            assert(isfield( params, 's0'));
            assert(isfield( params, 't0'));
            this.params =   params;
            if (exist('cbf', 'var') && isnumeric(cbf)); this.params.cbf = cbf; end
            if (exist('t',   'var') && isnumeric(t)  ); this.times      = t; end
            
            s0        = repmat(double(       params.s0), [1 1 1 this.nt]);
            dt        = GammaModels.dtimes(  params.t0,  this.times, size(params.s0));
            arg       = GammaModels.modelArg(params,          dt);
            postbolus = this.postbolus(      params.t0);
            if (~isempty(postbolus))
                arg   = arg .* postbolus; end
            foft      = s0 .* exp(-arg);
        end % protected localAifMr
        
        function [foft,this] = localAifMrConst(this, params, cbf, const, t)
            
            %% LOCALAIFMRCONST
            %  Usage:   obj  = makeModel('localAifMrConst');
            %           foft = obj.runModel(this, params);
            %           struct params must have numeric:  a,b,g,cbf,t0
            %           which may be NIfTI, but are used as double internally
            import mlfourd.*;
            assert(isstruct(params));
            assert(isfield( params, 's0'));
            assert(isfield( params, 't0'));
            this.params  = params;
            if (exist('cbf',  'var') && isnumeric(cbf)  ); this.params.cbf   = cbf; end
            if (exist('const','var') && isnumeric(const)); this.params.const = const; end
            if (exist('t',    'var') && isnumeric(t)    ); this.times        = t; end
            
            s0        = repmat(double(         params.s0), [1 1 1 this.nt]);
            dt        = GammaModels.dtimes(    params.t0,  this.times, size(params.s0));
            arg       = GammaModels.modelArg(  params,          dt) + ...
                        GammaModels.modelConst(params,          dt);
            postbolus = this.postbolus(        params.t0);
            if (~isempty(postbolus))
                arg   = arg .* postbolus; end
            foft      = s0 .* exp(-arg);
            assert(size(foft,4) == this.nt);
        end % protected localAifMrConst
        
        function [foft,this] = localAifMrRec(this, params, cbf, cbf2, t)
            
            %% LOCALAIFMRREC
            %  Usage:   obj  = makeModel('localAifMrRec');
            %           foft = obj.runModel(this, params);
            %           struct params must have numeric:  a,b,g,cbf,t0
            %           which may be NIfTI, but are used as double internally
            import mlfourd.*;
            assert(isstruct(params));
            assert(isfield( params, 's0'));
            assert(isfield( params, 't0'));
            assert(isfield( params, 't02'));            
            this.params  = params;
            if (exist('cbf',  'var') && isnumeric(cbf) ); this.params.cbf  = cbf; end
            if (exist('cbf2', 'var') && isnumeric(cbf2)); this.params.cbf2 = cbf2; end
            if (exist('t',    'var') && isnumeric(t)   ); this.times       = t; end
            
            s0         = repmat(double(       params.s0),  [1 1 1 this.nt]);
            dt         = GammaModels.dtimes(  params.t0,   this.times, size(params.s0));
            dt2        = GammaModels.dtimes(  params.t02,  this.times, size(params.s0));
            arg        = GammaModels.modelArg(params,           dt);
            postbolus  = this.postbolus(      params.t0);
            if (~isempty(postbolus))
                arg    = arg .* postbolus; end
            arg2       = GammaModels.modelArg(params,           dt2);
            postbolus2 = this.postbolus(      params.t02);
            if (~isempty(postbolus2))
                arg2   = arg2 .* postbolus2; end
            foft       = s0 .* exp(-arg-arg2);
            assert(size(foft,4) == nt);
        end % protected localAifMrRec
        
        function [foft,this] = localAifMrRecConst(this, params, cbf, cbf2, const, const2, t)
            
            %% LOCALAIFMRREC
            %  Usage:   obj  = makeModel('localAifMrRecConst');
            %           foft = obj.runModel(this, params);
            %           struct params must have numeric:  a,b,g,cbf,t0
            %           which may be NIfTI, but are used as double internally
            import mlfourd.*;
            assert(isstruct(params));
            assert(isfield( params, 's0'));
            assert(isfield( params, 't0'));
            assert(isfield( params, 't02'));            
            this.params  = params;
            if (exist('cbf',    'var') && isnumeric(cbf)   ); this.params.cbf    = cbf; end
            if (exist('cbf2',   'var') && isnumeric(cbf2)  ); this.params.cbf2   = cbf2; end
            if (exist('const',  'var') && isnumeric(const) ); this.params.const  = const; end
            if (exist('const2', 'var') && isnumeric(const2)); this.params.const2 = const2; end
            if (exist('t',      'var') && isnumeric(t)     ); this.times         = t; end
            
            s0         = repmat(double(         params.s0),  [1 1 1 this.nt]);
            dt         = GammaModels.dtimes(    params.t0,   this.times, size(params.s0));
            dt2        = GammaModels.dtimes(    params.t02,  this.times, size(params.s0)); 
            arg        = GammaModels.modelArg(  params,           dt) + ...
                         GammaModels.modelConst(params,           dt);
            postbolus  = this.postbolus(        params.t0);
            if (~isempty(postbolus))
                arg    = arg .* postbolus; end
            arg2       = GammaModels.modelArg(  params,           dt2) + ...
                         GammaModels.modelConst(params,           dt2);
            postbolus2 = this.postbolus(        params.t02);
            if (~isempty(postbolus2))
                arg2   = arg2 .* postbolus2; end
            foft       = s0 .* exp(-arg-arg2);
            assert(size(foft,4) == this.nt);
        end % protected localAiflMrRecConst
        
 		function this = GammaModels(name, params, t)
 			%% GAMMAMODELS (ctor) 
 			%  Usage:  ctor is best kept private/protected; 
            %          try:
            %          pars = {['p1', p1value [, ...]]};
            %          t    = 0:1.5:75;
            %          mdl  = GammaModels.makeModel('default', pars, t) % static factory 
            %          plot(t, mdl.runModel)
            this.name = name;
            this.params = params;
            if (exist('t', 'var') && isnumeric(t))
                this.times = t;
            else
                this.times = 0:this.TR:this.TR*this.NT;
            end
 		end % GammaModels (ctor) 
 	end % protected methods
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
