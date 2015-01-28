classdef DicomComposite < mlfourd.DicomComponent
	%% DICOMCOMPOSITE is the concrete composite in a composite design pattern
    %
    %  Version $Revision: 2627 $ was created $Date: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ by $Author: jjlee $,
 	%  last modified $LastChangedDate: 2013-09-16 01:18:10 -0500 (Mon, 16 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/DicomComposite.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: DicomComposite.m 2627 2013-09-16 06:18:10Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    methods (Static)
        
        function this    = createFromPaths( nppth, ~)
            %% CREATEFROMPATHS
            
            import mlfourd.*;
            this = DicomComposite;
            this = DicomComposite.traverseNPPath(this, nppth, @DicomComponent.createFromPaths);
        end % static createFromPaths
        function           renameSurfer4fsl(nppth, ~)
            mlfourd.DicomComposite.renameSurfer4NPPath(nppth);
        end % static renameSurfer4fsl
        function           renameSurfer4NPPath( nppth)
            import mlfourd.*;
            DicomComposite.traverseNPPath2([], nppth, @DicomComponent.renameSurfer4fsl);
        end % static renameSurfer4NPPath
    end % static methods
    
    %% PROTECTED
    
    methods (Static, Access = 'protected')        
        function list = traverseNPPath(list, nppth, fhandle)
            %% TRAVERSENPPATHS
            %  Usage:  list = DicomComposite.traverseNPPath(list, nppth, func_handle)
            %          ^ mlpatterns.List                          ^ NP/study path
            %                                                            ^ @function(dicom_path, target_path)
            
            import mlfourd.*;
            assert(isa(fhandle, 'function_handle'));
            
            nplist   = mlsystem.DirTool(nppth);
            sessions = nplist.fqdns;
            mrs      = AbstractDicomConverter.modalityFolders;
            dcms     = AbstractDicomConverter.dicomFolders;
            for s = 1:length(sessions) %#ok<FORFLG>
                for m = 1:length(mrs)
                    
                    targpth = expandPaths(fullfile(sessions{s}, mrs{m}, list.unpackFolder, '')); 
                    for t = 1:length(targpth)
                        for d = 1:length(dcms)

                            dcmpths = expandPaths(fullfile(sessions{s}, mrs{m}, dcms{d}, ''));
                            for d2 = 1:length(dcmpths)
                                if (lexist(dcmpths{d2}, 'dir'))
                                    try

                                        component = fhandle(dcmpths{d2}, targpth{t}); 
                                        if (isa(list, 'mlpatterns.List'))
                                            for c = 1:length(component) 
                                                list.add(component.get(c)); 
                                            end
                                            fprintf('DicomComposite.traverseNPPath:  add from->%s\n', dcmpths{d2});
                                        end
                                    catch ME
                                        %disp(ME);
                                        fprintf('DicomComposite.traverseNPPath:  %s  Skipping folder %s\n', ME.message, dcmpths{d2});
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end % static traverseNPPath
        function        traverseNPPath2(~,   nppth, fhandle)
            %% TRAVERSENPPATHS
            %  Usage:  list = DicomComposite.traverseNPPath2(list, nppth, func_handle)
            %          ^ mlpatterns.List                           ^ NP/study path
            %                                                             ^ @function(unpack_path, fsl_path)
            %          updates target/unpacking folder via NamingRegistry
            
            assert(isa(fhandle, 'function_handle'));
            nplist   = mlsystem.DirTool(nppth);
            sessions = nplist.fqdns;
            mrs      = mlfourd.AbstractDicomConverter.modalityFolders;
            
            for s = 1:length(sessions) %#ok<FORFLG>
                fslpth = ensureFolderExists( ...
                         fullfile(sessions{s}, mlfsl.FslRegistry.instance.fslFolder, '')); 
                for m = 1:length(mrs)                    
                    for f = 1:length(this.unpackFolders)
                        targpth = fullfile(sessions{s}, mrs{m}, this.unpackFolders{f}, ''); 
                        for t = 1:length(targpth)
                            if (lexist(targpth, 'dir'))
                                try
                                    fhandle(targpth, fslpth); 
                                catch ME
                                    disp(ME);
                                    fprintf('DicomComposite.traverseNPPath2:  %s  Skipping folder %s\n', ME.message, targpth);
                                end
                            end                           
                        end
                    end
                end
            end
        end % static traverseNPPath2
    end % static, protected methods
    
	methods (Access = 'protected') 
 		function this = DicomComposite(bldr, varargin) 
 			%% DICOMCOMPOSITE 
 			%  Usage:  obj = DicomComposite(builder)
			 
            this = this@mlfourd.DicomComponent(bldr, varargin{:});
 		end % DicomComposite (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

