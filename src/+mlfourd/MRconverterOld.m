classdef MRconverter < mlfourd.ModalityConverter

    properties (Constant)
        MR0 = 1;
        MR1 = 2;
    end
    
    methods (Static)
        
        function [nii obj] = MRfactory(pid, metric, msknii, blur, blocks)
            
            %% MRFACTORY produces a NIfTI object & a PETconverter object
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
            db = Np797Registry.instance(pid);
            switch (nargin)
                case 1
                    obj        = MRconverter(pid, [],     db.baseBlur, db.blockSize);
                    obj.metric = 'cbf';
                case 2
                    obj        = MRconverter(pid, [],     db.baseBlur, db.blockSize);
                    obj.metric = metric;
                case 3
                    obj        = MRconverter(pid, msknii, db.baseBlur, db.blockSize);
                    obj.metric = metric;
                case 4
                    obj        = MRconverter(pid, msknii, blur,        db.blockSize);
                    obj.metric = metric;
                case 5
                    obj        = MRconverter(pid, msknii, blur,        blocks);
                    obj.metric = metric;
            end
            assert(ischar(metric));
            switch (lower(metric))
                case {'mrcbf','mr1cbf','qcbf','cbf'}
                    %obj.metricThresh = [1 200];
                    nii = obj.make_metric_nii(obj.MR1);
                case {'mrcbv','mr1cbv','qcbv','cbv'}
                    %obj.metricThresh = [eps 20];
                    nii = obj.make_metric_nii(obj.MR1);
                case {'mrmtt','mr1mtt','qmtt','mtt'}
                    %obj.metricThresh = [eps 30];
                    nii = obj.make_metric_nii(obj.MR1);
                case {'mr0cbf','scbf'}
                    %obj.metricThresh = [1 200];
                    nii = obj.make_metric_nii(obj.MR0);
                case {'mr0cbv','scbv'}
                    %obj.metricThresh = [eps 20];
                    nii = obj.make_metric_nii(obj.MR0);
                case {'mr0mtt','smtt'}
                    %obj.metricThresh = [eps 30];
                    nii = obj.make_metric_nii(obj.MR0);
                otherwise
                    error('mlfourd:InputParamsErr', ...
                         ['MRfactory could not recognize requested metric ' metric]);
            end
        end % static MRfactory       
    end % methods static
    
    methods
        
        function obj = MRconverter(varargin)
            
            %% CTOR
            %  Usage:  obj = MRconverter(pid)
            %          pid:     string
            %          msknii:  NIfTI or [] 
            %          blur:    e.g., [10 10 10], in mm for fwhh
            %          blocks:  false or [b1 b2 b3], in #voxels
            %
            obj = obj@mlfourd.ModalityConverter(varargin{:});
            obj.cbfnii = cell(1,2);
            obj.cbvnii = cell(1,2);
            obj.mttnii = cell(1,2);
        end 

        function nii = make_metric_nii(obj, idx)
            
            %% MAKE_METRIC_NII
            %  Usage:  idx -> 0 for comparator, >0 for new methods
            %               
            metric_nii  = mlfourd.NIfTI.load(obj.reg.mr_filename(obj.metric,1,0,0), ['MR' num2str(idx-1)]);
            metric_niib = mlfourd.NiiBrowser(metric_nii, obj.reg.baseBlur);                
            if (obj.reg.blur2bool)
                metric_niib = metric_niib.blurredBrowser(obj.reg.baseBlur, obj.fgnii);
            end
            if (obj.reg.block2bool)
                metric_niib = metric_niib.blockedBrowser(obj.reg.blockSize, obj.fgnii);
            end
            metric_niib.fileprefix = obj.reg.mr_filename(obj.metric, -1);
            nii = metric_niib;
            if (obj.reg.debugging)
                disp('make_metric_nii:  created:'); disp(metric_niib);
            end
            
            if     (findstr('cbf', obj.metric)) 
                obj.cbfnii{idx} = metric_niib;
            elseif (findstr('cbv', obj.metric)) 
                obj.cbvnii{idx} = metric_niib;
            elseif (findstr('mtt', obj.metric)) 
                obj.mttnii{idx} = metric_niib;
            else
                error('mlfourd:UnknownParam', ['MRconverter.metric->' obj.metric]);
            end
        end
        
    end % methods
end
