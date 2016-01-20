classdef PETconverterOld < mlfourd.ModalityConverter

    %% PETconverter builds maps of CBF, CBV, MTT, OEF, CMRO2 from activity-count maps of
    %% H[^15O] C[^15O] and O[^15O].   A factory design pattern.  
    %  Usage:  [nii pcobj] = PETconverter.PETfactory(pid [, metric, msknii, blur, blocks])
    %
    % Instantiation:    obj = PETconverter.PETfactory(pid)
    %
    %                   pid:  p-number string or NIfTI object
    %
    % Created by John Lee on 2008-12-26.
    % Copyright (c) 2008 Washington University School of Medicine. All rights reserved.
    % Report bugs to bug.jjlee.wustl.edu@gmail.com.
    %
    %       Herscovitch P, Markham J, Raichle ME. Brain blood flow measured
    % with intravenous H2(15)O: I. theory and error analysis.
    % J Nucl Med 1983;24:782?789
    %
    %       Videen TO, Perlmutter JS, Herscovitch P, Raichle ME. Brain
    % blood volume, blood flow, and oxygen utilization measured with
    % O-15 radiotracers and positron emission tomography: revised metabolic
    % computations. J Cereb Blood Flow Metab 1987;7:513?516
    %
    %       Herscovitch P, Raichle ME, Kilbourn MR, Welch MJ. Positron
    % emission tomographic measurement of cerebral blood flow and
    % permeability: surface area product of water using [15O] water and
    % [11C] butanol. J Cereb Blood Flow Metab 1987;7:527?542
    %
    
    properties
        honii             = 0; % assigned by lazy initialization
        ocnii             = 0;
        oonii             = 0;
    end  
    
    properties (Access = 'protected')
        PEXPR_ = '/(?<pnum>p[0-9]+)[ho][oc]1_xr3d\.4dfp';
    end
    
    methods (Static) 
        
        function [nii obj] = PETfactory(pid, metric, msknii, blur, blocks)
        
            %% PETFACTORY produces a NIfTI object & a PETconverter object
            %  Usage: [nii obj] = PETfactory(pid [, metric, msknii, blur, isblocked])
            %          pid:       string (e.g., 'vc4437') or NIfTI object
            %          metric:    'oo', 'oc', 'ho', 'cbf', 'cbv', 'mtt', 'cmro2', 'oef'
            %          msknii:    NIfTI or [] 
            %          blur:      e.g., [16 16 16], in mm fwhh
            %                     always applied before blocking
            %          blocks:    false or [b1 b2 b3]
            %          nii:       requested NIfTI
            %          obj:       PETconverter
            %
            import mlfourd.* mlfsl.*;
            assert(nargin > 0);
            switch (nargin)
                case 0
                    obj        = PETconverter(this.reg.pid, [],     this.reg.baseBlur, this.reg.blockSize);
                    obj.metric = 'cbf';
                case 1
                    obj        = PETconverter(         pid, [],     this.reg.baseBlur, this.reg.blockSize);
                    obj.metric = 'cbf';
                case 2
                    obj        = PETconverter(         pid, [],     this.reg.baseBlur, this.reg.blockSize);
                    obj.metric = metric;
                case 3
                    if (ischar(msknii))
                        msknii = PETconverter.tryTransmissionMask;
                    end
                    obj        = PETconverter(         pid, msknii, this.reg.baseBlur, this.reg.blockSize);
                    obj.metric = metric;
                case 4
                    if (ischar(msknii))
                        msknii = PETconverter.tryTransmissionMask;
                    end
                    obj        = PETconverter(         pid, msknii, blur,                this.reg.blockSize);
                    obj.metric = metric;
                case 5
                    if (ischar(msknii))
                        msknii = PETconverter.tryTransmissionMask;
                    end
                    obj        = PETconverter(         pid, msknii, blur,                blocks);
                    obj.metric = metric;
            end
            %obj.metricThresh = [eps 1e7];
            switch (lower(metric))
                case {'petho','ho'}
                    %%obj.metricThresh = [1 1e7];
                    nii = obj.make_honii();
                case {'petco','petoc','co','oc'}
                    %%obj.metricThresh = [1 1e6];
                    nii = obj.make_ocnii();
                case {'petoo','oo'}
                    %%obj.metricThresh = [1 1e6];
                    nii = obj.make_oonii();
                case {'petcbf','pcbf','cbf'}
                    %%obj.metricThresh = [1 200];
                    nii = obj.make_cbfnii();
                case {'petcbv','pcbv','cbv'}
                    %%obj.metricThresh = [eps 20];
                    nii = obj.make_cbvnii();
                case {'petmtt','pmtt','mtt'}
                    %%obj.metricThresh = [eps 30];
                    nii = obj.make_mttnii();
                case {'petoef','poef','oef'}
                    %%obj.metricThresh = [eps 1];
                    nii = obj.make_oefnii();
                case {'petcmro2','pcmro2','cmro2'}
                    %%obj.metricThresh = [eps 200];
                    nii = obj.make_cmro2nii();
                otherwise
                    error('mlfourd:InputParamsErr', ...
                         ['PETconverter.make_nii1 could not recognize requested metric ' metric]);
            end
        end % static PETfactory
        
        function tr_mask   = tryTransmissionMask(thresh)
            import mlfourd.*;
            tr_mask = 0;
            if (~exist('thresh','var')); thresh = 300; end
            try
                tr = NIfTI.load('tr_rot');
                tr_mask = tr > thresh;
                tr_mask.fileprefix = 'tr_rot_mask';
            catch ME
                handexcept(ME);
            end
        end
    end % methods static
    
    methods
        
        function set.honii(obj, nii)
            
            %% SET.HONII
            %
            if (mlfourd.NIfTI.isNIfTI(nii))
                nii.img   = double(nii.img);
                obj.honii = nii;
            else
                ME = MException('VerifyInput:UnexpectedType', ...
                    ['set.honii.nii must satisfy mlfourd.NIfTI.isNIfTI(); class(nii) was ' class(nii)]);
                throw(ME);
            end
        end % set.honii        
        
        function set.ocnii(obj, nii)
            
            %% SET.OCNII
            %
            if (mlfourd.NIfTI.isNIfTI(nii))
                nii.img   = double(nii.img);
                obj.ocnii = nii;
            else
                ME = MException('VerifyInput:UnexpectedType', ...
                    ['set.ocnii.nii must satisfy mlfourd.NIfTI.isNIfTI(); class(nii) was ' class(nii)]);
                throw(ME);
            end
        end % set.ocnii        
        
        function set.oonii(obj, nii)
            
            %% SET.OONII
            %
            if (mlfourd.NIfTI.isNIfTI(nii))
                nii.img   = double(nii.img);
                obj.oonii = nii;
            else
                ME = MException('VerifyInput:UnexpectedType', ...
                    ['set.oonii.nii must satisfy mlfourd.NIfTI.isNIfTI(); class(nii) was ' class(nii)]);
                throw(ME);
            end
        end % set.oonii   
        
        
        
        function ho  = make_ho(obj)
            
            %% MAKE_HO
            %  Usage:  ho = obj.make_ho
            %          ho:  double image
            import mlfourd.*;
            if (mlfourd.NIfTI.isNIfTI(obj.honii))
                ho = obj.honii.img;
            else
                honii = obj.make_honii;  %#ok<*PROP>
                ho    = honii.img;
            end
        end % make_ho
        
        function nii = make_honii(obj, fname)
            
            %% MAKE_HONII
            %  Usage nii = obj.make_honii([filename])
            import mlfourd.*;
            %if (mlfourd.NIfTI.isNIfTI(obj.honii))
            %    nii = obj.honii;
            %else               
                if (~exist('fname', 'var'))
                    fname = obj.reg.h15o('fqfp', obj.reg.fslPath);
                end
                honii  = mlfourd.NIfTI.load(fname, 'H[15O]');
                honiib = mlfourd.NiiBrowser(honii, obj.reg.baseBlur);                
                if (obj.reg.blur2bool)
                    honiib = honiib.blurredBrowser(obj.reg.baseBlur);
                end
                if (obj.reg.block2bool)
                    honiib = honiib.blockedBrowser(obj.reg.blockSize);
                    honiib.fileprefix = obj.reg.h15o('fp');
                end
                obj.honii = honiib;
                nii       = honiib;
                if (obj.reg.debugging); disp('make_honii:  created:'); disp(honiib); end
            %end
        end % make_honii
        
        function cbf = make_cbf(obj)
            
            %% MAKE_CBF
            %  Usage:  cbf = obj.make_cbf
            if (mlfourd.NIfTI.isNIfTI(obj.cbfnii))
                cbf = obj.cbfnii.img;
            else
                cbfnii = obj.make_cbfnii;
                cbf = cbfnii.img;
            end           
        end % make_cbf
        
        function nii = make_cbfnii(obj)
            
            %% MAKE_CBFNII
            %
            if (mlfourd.NIfTI.isNIfTI(obj.cbfnii))
                nii  = obj.cbfnii;
            else               
                obj.cbfnii     = obj.make_honii;
                obj.cbfnii.img = obj.counts2cbf(obj.make_ho);
                obj.cbfnii.fileprefix = 'cbf_h15o';
                obj.cbfnii     = obj.cbfnii.append_descrip('CBF');
                nii            = obj.cbfnii;
            end
        end % make_cbfnii
        
        function oc  = make_oc(obj)
            
            %% MAKE_OC
            %  Usage:  oc = make_oc
            %          oc:  double image
            if (mlfourd.NIfTI.isNIfTI(obj.ocnii))
                oc = obj.ocnii.img;
            else
                ocnii = obj.make_ocnii;
                oc    = ocnii.img;
            end
        end % make_oc
        
        function nii = make_ocnii(obj, fname)
            
            %% MAKE_OCNII
            %  Usage nii = obj.make_ocnii([filename])
            if (mlfourd.NIfTI.isNIfTI(obj.ocnii))
                nii = obj.ocnii;
            else               
                if (~exist('fname', 'var'))
                    fname = obj.reg.c15o('fqfp', obj.reg.fslPath);
                end
                ocnii  = mlfourd.NIfTI.load(fname, '[15O]C');
                ocniib = mlfourd.NiiBrowser(ocnii, obj.reg.baseBlur);                
                if (obj.reg.blur2bool)
                    ocniib = ocniib.blurredBrowser(obj.reg.baseBlur);
                end
                if (obj.reg.block2bool)
                    ocniib = ocniib.blockedBrowser(obj.reg.blockSize);
                    ocniib.fileprefix = obj.reg.c15o('fp');
                end
                obj.ocnii = ocniib;
                nii       = ocniib;
                if (obj.reg.debugging); disp('make_ocnii:  created:'); disp(ocniib); end
            end
        end % make_ocnii
               
        function cbv = make_cbv(obj)
            
            %% MAKE_CBV creates a CBV map from PET CO maps using the methods of Videen, Powers, et al.
            %  Usage cbv_map = this.make_cbv;
            if (mlfourd.NIfTI.isNIfTI(obj.cbvnii))
                cbv = obj.cbvnii.img;
            else
                cbvnii = obj.make_cbvnii;
                cbv = cbvnii.img;
            end
        end % make_cbv
        
        function nii = make_cbvnii(obj)
            
            %% MAKE_CBVNII
            %
            if (mlfourd.NIfTI.isNIfTI(obj.cbvnii))
                nii  = obj.cbvnii;
            else
                obj.cbvnii     = obj.make_ocnii;
                obj.cbvnii.img = obj.counts2cbv(obj.make_oc);
                obj.cbvnii.fileprefix = 'cbv_c15o';
                obj.cbvnii     = obj.cbvnii.append_descrip('CBV');
                nii            = obj.cbvnii;
            end
        end % make_cbvnii
        
        function mtt = make_mtt(obj)
            
            %% MAKE_MTT
            %
            if (mlfourd.NIfTI.isNIfTI(obj.mttnii))
                mtt = obj.mttnii.img;
            else
                f          = obj.make_cbf;
                v          = obj.make_cbv;
                mtt        = 60 * obj.safe_quotient(v, f) .* obj.fuzzyFg(obj.reg.baseBlur);
                obj.mttnii = obj.fgnii.makeSimilarNIfTI(mtt, 'PETconverter.make_mtt');
            end
        end % make_mtt
        
        function quot = safe_quotient(obj, num, den)
        
            %% SAFE_QUOTIENT
            %  Usage:  quot = obj.safe_quotient(num, den)
            %          num, den must be numeric arrays, NIfTI, or fileprefixes
            %          quot will have same typeclass
            import mlfourd.*;            
            assert(~isempty(obj.fgnii), 'ModalityConverter.safe_quotient:  requires that foreground be assigned first');
            numType = class(num);
            switch (numType)
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                case numeric_types
                    num = NIfTI(num);
                case 'char'
                    num = NIfTI.load(num);
                otherwise
                    error('mlfourd:UnsupportedType', 'class(ModalityConverter.num) -> %s', numType);
            end
            
            num  = obj.fgnii.makeSimilarNIfTI(num, 'ModalityConverter.safe_quotient.num');
            numb = NiiBrowser(num, obj.reg.baseBlur);
            den  =       num.makeSimilarNIfTI(den, 'ModalityConverter.safe_quotient.den');
            fzfg =       num.makeSimilarNIfTI(obj.fuzzyFg, 'ModalityConverter.safe_quotient.fzfg');
            quot =  numb.safe_quotient(den, fzfg, obj.reg.baseBlur);
            switch (numType)
                case mlfourd.NIfTI.NIFTI_SUBCLASS
                    quot = NIfTI(quot);
                case numeric_types
                    quot = quot.img;
                case 'char'
                    quot = quot.fileprefix;
                otherwise
                    error('mlfourd:UnsupportedType', 'class(ModalityConverter.num) -> %s', numType);
            end
        end % safe_quotient
        
        function nii = make_mttnii(obj)
            
            %% MAKE_MTTNII
            %
            if (mlfourd.NIfTI.isNIfTI(obj.mttnii))
                nii  = obj.mttnii;
            else
                fnii       = obj.make_cbfnii;
                vnii       = obj.make_cbvnii;
                vniib      = mlfourd.NiiBrowser(vnii, obj.reg.baseBlur);
                obj.mttnii = vniib.safe_quotient(fnii, obj.fgnii, obj.reg.baseBlur, 60);
                obj.mttnii.fileprefix = 'mtt_o15o_h15o';
                obj.mttnii = obj.mttnii.append_descrip('MTT');
                nii        = obj.mttnii;
            end
        end % make_mttnii

        function oo  = make_oo(obj)
            
            %% MAKE_OO
            %  Usage:  oo = make_oo
            %          oo:  double image
            if (mlfourd.NIfTI.isNIfTI(obj.oonii))
                oo = obj.oonii.img;
            else
                oonii = obj.make_oonii;
                oo    = oonii.img;
            end
        end % make_oo
        
        function nii = make_oonii(obj, fname)
            
            %% MAKE_OONII
            %  Usage:  nii = obj.make_oonii([filename])
            if (mlfourd.NIfTI.isNIfTI(obj.oonii))
                nii = obj.oonii;
            else              
                if (~exist('fname', 'var'))
                    fname = obj.reg.o15o('fqfp', obj.reg.fslPath);
                end
                oonii  = mlfourd.NIfTI.load(fname, 'O[15O]');
                ooniib = mlfourd.NiiBrowser(oonii, obj.reg.baseBlur);                
                if (obj.reg.blur2bool)
                    ooniib = ooniib.blurredBrowser(obj.reg.baseBlur);
                end
                if (obj.reg.block2bool)
                    ooniib = ooniib.blockedBrowser(obj.reg.blockSize);
                    ooniib.fileprefix = obj.reg.o15o('fp');
                end
                obj.oonii = ooniib;
                nii       = ooniib;
                if (obj.reg.debugging); disp('make_oonii:  created:'); disp(ooniib); end
            end
        end % make_oonii
        
        function oef = make_oef(obj)
            
            %% MAKE_OEF
            %
            if (mlfourd.NIfTI.isNIfTI(obj.oefnii))
                oef  = obj.oefnii.img;
            else
                f          = obj.make_cbf;
                v          = obj.make_cbv;
                R          = 0.85; % mean ratio of small-vessel to large-vessel Hct
                D          = 1.05; % density of brain, g/mL
                w          = modelW(obj.reg.pid);
                a          = modelA(obj.reg.pid);
                ICbv       = R*(squeeze(v)*D/100)*modelIntegralO2Counts(obj.reg.pid);
                oef        = scrubNaNs( ...
                             (w * squeeze(obj.make_oo) - (a(1) * f .* f + a(2) * f) - ICbv) ./ ...
                                                        ((a(3) * f .* f + a(4) * f) - 0.835*ICbv), 1);
                msk        = double(obj.fuzzyFg) .* double(oef > 0) .* double(oef < 1);
                oef        = squeeze(oef .* msk);
                obj.fgnii  = double(obj.fgnii);
                obj.oefnii = obj.fgnii.makeSimilarNIfTI(oef, 'PETconverter.make_oef');  
            end            
        end % make_oef
        
        function nii = make_oefnii(obj)
            
            %% MAKE_OEFNII
            %
            if (mlfourd.NIfTI.isNIfTI(obj.oefnii))
                nii = obj.oefnii;
            else
                obj.fgnii = double(obj.fgnii);
                nii = obj.fgnii.makeSimilarNIfTI(obj.make_oef, 'PETconverter.make_oefnii'); 
                nii = nii.append_descrip('OEF');
                nii.fileprefix = 'oef_o15o_h15o';
                obj.oefnii = nii;
            end
        end %make_oefnii
        
        function cmro2 = make_cmro2(obj)
            
            %% MAKE_CMRO2
            %
            if (mlfourd.NIfTI.isNIfTI(obj.cmro2nii))
                cmro2 = obj.cmro2nii.img;
            else
                f            = obj.make_cbf;
                o            = obj.make_oef; 
                assert(~isempty(obj.reg.pid));
                cmro2        = o .* f * modelOxygenContent(obj.reg.pid);
                obj.cmro2nii = obj.fgnii.makeSimilarNIfTI(cmro2, 'PETconverter.make_cmro2');
            end            
        end % make_cmro2
        
        function nii = make_cmro2nii(obj)
            
            %% MAKE_CMRO2NII
            if (mlfourd.NIfTI.isNIfTI(obj.cmro2nii))
                nii = obj.cmro2nii;
            else               
                nii = obj.fgnii.makeSimilarNIfTI(obj.make_cmro2, 'PETconverter.make_cmro2nii'); 
                nii = nii.append_descrip('CMRO2');
                nii.fileprefix = 'cmro2_o15o';
                obj.cmro2nii = nii;
            end
        end % make_cmro2nii
        
        function cbf = counts2cbf(obj, cnts)
            
            %% COUNTS2CBF computes CBF in mL/min/100 g tissue
            import mlfourd.*;
            cnts = NIfTI.ensureDble(cnts);
            assert(~isempty(obj.reg.pid));
            [AFlow BFlow] = PETconverter.modelFlows(obj.reg.hdrinfo_filename('ho1'));
            cbf = cnts .* (AFlow*cnts + BFlow);
            if (mlpet.O15Builder.BUTANOL_CORRECTION) 
               cbf = linkMexFlowButanol(cbf);
            end
        end % counts_to_cbf        
        
        function cbv = counts2cbv(obj, cnts)
            %% COUNTS2CBV computes CBV in mL/100 g tissue
            %  Usage:   cbv_map = this.counts2cbv(counts_map)
            
            import mlfourd.*;
            cnts = NIfTI.ensureDble(cnts);
            assert(~isempty(obj.reg.pid));
            cbv  = squeeze(cnts * PETconverter.modelBVFactor(obj.reg.hdrinfo_filename('oc1')));
        end % counts2cbv 
   
    end % methods
    
    methods (Static)
        function cbf = count2cbf(count, hdrfile, butCorrect)
            
            %% COUNT2CBF computes CBF in mL/min/100 g tissue
            %  Usage:  cbf = PETconverter.count2cbf(count, hdrfile[, butCorrect])
            %                                       ^ double
            %                                              ^ filename string
            %                                                        ^ bool
            import mlfourd.*;
            if (~exist('butCorrect', 'var')); butCorrect = true; end
            [AFlow BFlow] = PETconverter.modelFlows(hdrfile);
            cbf           = count .* (AFlow*count + BFlow);
            if (exist('butCorrect', 'var'));
                if (butCorrect)
                    parfor f = 1:length(count)
                        cbf(f) = linkMexFlowButanol(cbf(f));
                    end
                end
            end
        end % static count2cbf
        
        function cbv = count2cbv(count, hdrfile)
            
            %% COUNT2CBV computes CBV in mL/100 g tissue
            %  Usage:  cbv = count2cbv(count, hdrfilename)
            %                          ^ double
            %                                 ^ filename string
            import mlfourd.*;
            for v = 1:length(count)
                cbv(v)  = squeeze(count(v) * PETconverter.modelBVFactor(hdrfile));
            end
        end % static counts2cbv 
        
        function [aflow bflow] = modelFlows(hdrfilename)

            %% MODELFLOWS
            %  Usage:  [aflow bflow] = modelFlows(hdrfilename)
            %           hdrfilename:   *.hdr.info text-file
            %           aflow, bflow: values from ho1 hdr files
            %
            %       Herscovitch P, Markham J, Raichle ME. Brain blood flow measured
            % with intravenous H2(15)O: I. theory and error analysis.
            % J Nucl Med 1983;24:782??789
            %       Videen TO, Perlmutter JS, Herscovitch P, Raichle ME. Brain
            % blood volume, blood flow, and oxygen utilization measured with
            % O-15 radiotracers and positron emission tomography: revised metabolic
            % computations. J Cereb Blood Flow Metab 1987;7:513??516
            %       Herscovitch P, Raichle ME, Kilbourn MR, Welch MJ. Positron
            % emission tomographic measurement of cerebral blood flow and
            % permeability: surface area product of water using [15O] water and
            % [11C] butanol. J Cereb Blood Flow Metab 1987;7:527??542
            import mlfourd.*;
            EXPRESSION = { ...
                'A Coefficient \(Flow\)\s*=\s*(?<aflow>\d+\.?\d*E-?\d*)' ...
                'B Coefficient \(Flow\)\s*=\s*(?<bflow>\d+\.?\d*E-?\d*)' };
            import mlfourd.*;
            contents = cell(1,1);
            aflow = -1; bflow = -1;
            try
                fid = fopen(hdrfilename);
                i   = 1;
                while 1
                    tline = fgetl(fid);
                    if ~ischar(tline),   break,   end
                    contents{i} = tline;
                    i = i + 1;
                end
                fclose(fid);
            catch ME
                disp(ME);
                warning('mfiles:IOErr', ['modelFlows:  could not process file ' hdrfilename ' with fid ' num2str(fid)]);
            end
            cline = '';
            try
                for j = 1:length(contents) %#ok<FORFLG>
                    cline = contents{j}; %#ok<PFTUS>
                    if (strcmp('A Coef', cline(2:7)))
                        [~, names] = regexpi(cline, EXPRESSION{1},'tokens','names'); %#ok<PFBNS>
                        aflow      = str2double(names.aflow); %#ok<PFTUS>
                    end
                    if (strcmp('B Coef', cline(2:7)))
                        [~, names] = regexpi(cline, EXPRESSION{2},'tokens','names');
                        bflow      = str2double(names.bflow); %#ok<PFTUS>
                    end
                end 
            catch ME
                disp(['modelFlows:  could not find Coeffients of flow from file ' hdrfilename]);
                disp(ME.message);
                error('mfiles:InternalDataErr', ['modelFlows:  regexpi failed for ' cline]);
            end
        end % static modelFLows
        
        function oxy           = modelBVFactor(hdrfilename)
            
            %% Usage:  oxy = modelBVFactor(hdrfilename)
            %          hdrfilename:   *.hdr.info text-file
            %          oxy:           oxygen content from oo1 hdr files
            %
            %       Herscovitch P, Markham J, Raichle ME. Brain blood flow measured
            % with intravenous H2(15)O: I. theory and error analysis.
            % J Nucl Med 1983;24:782??789
            %       Videen TO, Perlmutter JS, Herscovitch P, Raichle ME. Brain
            % blood volume, blood flow, and oxygen utilization measured with
            % O-15 radiotracers and positron emission tomography: revised metabolic
            % computations. J Cereb Blood Flow Metab 1987;7:513??516
            %       Herscovitch P, Raichle ME, Kilbourn MR, Welch MJ. Positron
            % emission tomographic measurement of cerebral blood flow and
            % permeability: surface area product of water using [15O] water and
            % [11C] butanol. J Cereb Blood Flow Metab 1987;7:527??542
            import mlfourd.* mlfsl.*;
            EXPRESSION = 'Blood Volume Factor\s*=\s*(?<bvfactor>\d+\.?\d*)';
            contents   = {0};
            try
                fid = fopen(hdrfilename);
                i = 1;
                while 1
                    tline = fgetl(fid);
                    if ~ischar(tline), break, end
                    contents{i} = tline;
                    i = i + 1;
                end
                fret = fclose(fid);
                fprintf('modelBVFactor:  fclose returned->%i\n', fret);
            catch ME %#ok<MUCTH>
                handwarning(ME, 'mfiles:IOWarning', ['modelBVFactor:  trouble with file ' hdrfilename]);
            end
            try
                cline = contents{strmatch(' Blood Volume Factor', contents)}; %#ok<MATCH2>
                [~, names] = regexpi(cline, EXPRESSION,'tokens','names');
                oxy = str2double(names.bvfactor);
                disp(['mfiles:Info:  modelBVFactor.oxy->' num2str(oxy)]);
            catch ME
                handerror(ME, 'mfiles:InternalDataErr', ...
                    ['modelBVFactor:  trouble extracting Blood Volume Factor from ' contents]);
            end
        end % static modelBVFactor
        
    end % static methods
    
    methods 
        function obj = PETconverterOld(varargin)
         
            %% CTOR
            %  Usage:  obj = PETconverter([pid, fg_filename, blur, blocks])
            %          pid:     string (e.g., 'vc4437') or
            %                   NIfTI object with filename containing the pid-string
            %          fg_filename:  NIfTI or [] to use only DBase.fg_filename
            %          blur:    e.g., [10 10 10], in mm for fwhh
            %          blocks:  true/false or [b1 b2 b3]
            %
            obj       = obj@mlfourd.ModalityConverter(varargin{:});
        end % ctor
    end 
end % classdef
