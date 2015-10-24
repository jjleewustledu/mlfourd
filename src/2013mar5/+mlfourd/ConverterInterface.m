classdef ConverterInterface 
	%% CONVERTERINTERFACE is an interface for converters of various supported imaging formats
	%  Version $Revision: 2308 $ was created $Date: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-01-12 17:51:00 -0600 (Sat, 12 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ConverterInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ConverterInterface.m 2308 2013-01-12 23:51:00Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Abstract, Constant)
        modalityFolders 
    end
    
    properties (Abstract)
        allFileprefixes
        allFilenames
        allFqFilenames
        
        modalityFolder    
        modalityPath % rootpath for AbstractConverter objects  
        orients2fix
        sessionFolder    
        sessionPath
        studyFolder
        studyPath
        unpackFolder  
        unpackFolders
        unpackPath  
    end
    
    methods (Abstract, Static)
        parconvertStudy(studyPath, patt)
        convertStudy(studyPth, patt)
        convertSession(sessionPth)
        convertModalityPath(modalPth)
        createFromSessionPath(sessionPth)
        createFromModalityPath(modalPth)
        orientRepair(obj, o2fix)
    end
    
    methods (Abstract)
        copyUnpacked(this, sourcePth, targetPth)
        modalFqFilenames(this, lbl)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

