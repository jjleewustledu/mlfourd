classdef ConverterInterface 
	%% CONVERTERINTERFACE is an interface for converters of various supported imaging formats
	%  Version $Revision: 2627 $ was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/ConverterInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ConverterInterface.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Abstract, Constant)
        modalityFolders 
        orients2fix
        unpackFolders
    end
    
    properties (Abstract)
        allFileprefixes
        allFilenames
        allFqFilenames
        % consider:   allFqFileprefixes
        
        modalityFolder    
        modalityPath % rootpath for AbstractConverter objects  
        sessionId  
        sessionPath
        studyFolder
        studyPath
        unpackFolder  
        unpackPath  
    end
    
    methods (Abstract, Static)
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

