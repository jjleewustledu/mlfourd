classdef DcmSort 
	%% DCMSORT calls routines from the 4dfp-suite to sort, parse DICOMs 
	%  Version $Revision: 1217 $ was created $Date: 2011-10-05 09:13:57 -0500 (Wed, 05 Oct 2011) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2011-10-05 09:13:57 -0500 (Wed, 05 Oct 2011) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/DcmSort.m $ 
 	%  Developed on Matlab 7.12.0.635 (R2011a) 
 	%  $Id: DcmSort.m 1217 2011-10-05 14:13:57Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 

 		function this = DcmSort() 
 			%% DCMSORT (ctor) 
 			%  Usage:  favor factory methods 
 		end % DcmSort (ctor) 
        
        function tbl = readStudiesTxt(this, fname)
            
            %% READSTUDIESTXT
            import mlfourd.*;
            EXPRESSION = { 'A Coefficient \(Flow\)\s*=\s*(?<aflow>\d+\.?\d*E-?\d*)' };
            buffer     = {[]};            
            try
                fid = fopen(fname);
                i   = 1;
                while 1
                    tline = fgetl(fid);
                    if ~ischar(tline),   break,   end
                    buffer{i} = tline;
                    i = i + 1;
                end
                fclose(fid);
            catch ME
                disp(ME);
                warning('mlfourd:IOErr', ['DcmSort.readStudiesTxt:  could not process file ' fname ' with fid ' num2str(fid)]);
            end
            
            tbl = struct();
            try
                for j = 1:length(buffer) 
                        [~, names] = regexpi(buffer{j}, EXPRESSION,'tokens','names'); 
                        aflow      = str2double(names.aflow); 
                end 
            catch ME
                handerror(ME, 'mfiles:InternalDataErr', 'DcmSort.readStudiesTxt:  regexpi failed for %s', cline);
            end
        end
 	end 

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
 	end 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
