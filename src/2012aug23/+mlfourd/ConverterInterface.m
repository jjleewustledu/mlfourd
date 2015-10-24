classdef ConverterInterface 
	%% CONVERTERINTERFACE is an interface for converters of various supported imaging formats
	%  Version $Revision: 1231 $ was created $Date: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 16:21:49 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfourd/src/+mlfourd/trunk/ConverterInterface.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: ConverterInterface.m 1231 2012-08-23 21:21:49Z jjlee $ 
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
        
        modalityPath % rootpath for AbstractConverter objects   
        modalityFolder     
        unpackPath  
        unpackFolder      
        sessionPath
        sessionFolder
        studyPath
        studyFolder
    end
    
    methods (Abstract, Static)
        creation(modalPth)
        createFromModalityPath(modalPth)
        createFromSessionPath(sessionPth)
        convertStudy(studyPth, patt)
        convertSession(sessionPth)
        fixOrient(obj, o2fix)
    end
    
    methods (Abstract)
        unpack(this)
        rename(this, sourcePth, targetPth)
        modalFqFilenames(this, lbl)
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

