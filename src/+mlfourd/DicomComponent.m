classdef DicomComponent < mlfourd.ImagingComponent
	%% DICOMCOMPONENT is the interface to a composite design pattern for DICOM management and
    %                 implements wrapper ImagingComponent for
    %                 a CellArrayList of dicom-query-structs
    %
    %  Version $Revision: 2608 $ was created $Date: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,
 	%  last modified $LastChangedDate: 2013-09-07 19:14:08 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/DicomComponent.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: DicomComponent.m 2608 2013-09-08 00:14:08Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    
    methods (Static)
        function this = createFromPaths(      dcmPth, targPth, cvert)
            %% CREATEFROMPATHS creates a cav of dicom-query-structs specified with path-string w/ wildcards
            %  Usage:   obj = DicomComponent.createFromPaths(dicom_path, target_path, dicom_converter)
            
            import mlfourd.* mlsurfer.*;
            assert(ischar(dcmPth) && ischar(targPth));
            if (~exist('cvert','var'))
                cvert = SurferDicomConverter(dcmPth, targPth);
            end
            query = cvert.dicomQuery;
            ca    = cell(length(query),1);
            for q = 1:length(query)  %#ok<FORFLG>
                query(q).dicom_path  = dcmPth;  %#ok<PFOUS>
                query(q).target_path = targPth;
                ca{q}                = query(q);
            end
            this = DicomComponent.createFromCells(ca);
        end % static createFromPaths 
        function this = createFromCells(        cav)
 			%% CREATEFROMCELLS 
 			%  Usage:  obj = DicomComponent.createFromCells(cav)
            %          Using a cell array vector 'cav' will populate the list with numel(cav) unique elements, 
            
            import mlfourd.*;
            assert(iscell(cav) && isvector(cav));
            cal  = mlfourd.ImagingArrayList;
            cal.add(cav);
            this = DicomComponent.createFromImagingArrayList(cal);
        end % static createFromCells
        function this = createFromImagingArrayList(cal)
            %% CREATEFROMCELLS keeps the ctor protected

            this = mlfourd.DicomComponent(cal);
        end % static createFromCells
        function cal  = dicoms2cell(          dcmPth, targPth)
            sdc = mlsurfer.SurferDicomConverter(dcmPth, targPth);
            cal = sdc.dicoms2cell;
        end % static dicoms2cell

    end % static methods
    
	methods
        function [str, infoDegeneracy] = listUniqueInfo(this, infotype)
            %% LISTUNIQUEINFO reports on infotype from this DicomComponent;
            %  Usage:  [report_string, info_degeneracy] = obj.listUniqueInfo(infotype);
            %  Uses:    regexp matches from AbstractDicomConverter
            
            thisIter = mlpatterns.CellArrayListIterator(this); % handle
            thisIter.reset;
            infoDegeneracy = containers.Map;
            while (thisIter.hasNext)                
                nextInfo = thisIter.next;
                for r = 1:length(nextInfo) %#ok<FORFLG>                    
                    try
                        akey = char(nextInfo(r).(infotype));
                        if (infoDegeneracy.isKey(akey))  
                            infoDegeneracy(      akey) = infoDegeneracy(akey) + 1;
                        else
                            infoDegeneracy(      akey) = 1;
                        end                    
                    catch ME
                        handwarning(ME);
                    end
                end
            end
            str  = '';
            keys = infoDegeneracy.keys;
            for k = 1:length(keys) %#ok<FORFLG>
                str = sprintf('%s%s %i\n', str, keys{k}, infoDegeneracy(keys{k}));  
            end
        end % listUniqueInfo
        function map                   = mapInfoToSession(this)
           
            import mlfourd.*;
            thisIter = mlpatterns.CellArrayListIterator(this);
            thisIter.reset;
            map      = containers.Map;
            naming   = NamingRegistry.instance;
            while (thisIter.hasNext)                
                nextInfo = thisIter.next;
                for r = 1:length(nextInfo) %#ok<FORFLG>                    
                    try
                        akey = char(nextInfo(r).dicom_path);
                        if (map.isKey(akey))                            
                            map(      akey) = vertcat( ...
                            map(      akey),   naming.sessionIdentifier( ...
                                      akey));     
                        else
                            map(      akey) = {naming.sessionIdentifier( ...
                                      akey)};
                        end
                    catch ME
                        handwarning(ME);
                    end
                end
            end
        end % mapInfoSession
    end
    
    methods (Access = 'protected') 
 		function this = DicomComponent(bldr, varargin) 
 			%% DICOMCOMPONENT 
 			%  Usage:  obj = DicomComponent(builder, [cal])
            %          Prefer creation methods; accepts elements of any data type as input.
            %          Using a cell array vector 'cav' will populate the list with numel(cav) unique elements, 
            %          otherwise the input will be treated as a single element.
            
            this = this@mlfourd.ImagingComponent(bldr, varargin{:});
 		end % DicomComponent (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

