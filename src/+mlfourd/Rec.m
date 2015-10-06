classdef Rec < mlio.LogParser 
	%% REC supports *.img.rec files from the 4dfp framework.

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.5.0.197613 (R2015a) 
 	%  $Id$  	 

	properties (Dependent)
        scanDate
 	end 

	methods %% GET
        function sd = get.scanDate(this)
            fileStem = [strtok(this.fileprefix, '.') '.v'];
            lineStr  = this.findNextCell(fileStem, 5);
            try
                expr = sprintf('%s\\s+(?<date>\\d+(/|-)\\d+(/|-)\\d+)', fileStem);
                names = regexp(lineStr, expr, 'names');
                sd = names.date;
            catch ME
                handexcept(ME);
            end
        end
    end 

    methods (Static)        
        function this = load(fn)
            assert(lexist(fn, 'file'));
            [pth, fp, fext] = fileparts(fn); 
            if (lstrfind(fext, mlfourd.Rec.FILETYPE_EXT) || ...
                isempty(fext))
                this = mlfourd.Rec.loadText(fn); 
                this.filepath_   = pth;
                this.fileprefix_ = fp;
                this.filesuffix_ = fext;
                return 
            end
            error('mlfourd:unsupportedParam', 'Rec.load does not support file-extension .%s', fext);
        end
        function this = loadx(fn, ext)
            if (~lstrfind(fn, ext))
                if (~strcmp('.', ext(1)))
                    ext = ['.' ext];
                end
                fn = [fn ext];
            end
            assert(lexist(fn, 'file'));
            [pth, fp, fext] = filepartsx(fn, ext); 
            this = mlfourd.Rec.loadText(fn);
            this.filepath_   = pth;
            this.fileprefix_ = fp;
            this.filesuffix_ = fext;
        end
    end
    
    %% PROTECTED
    
    methods (Static, Access = 'protected')
        function this = loadText(fn)
            import mlfourd.*;
            this = Rec;
            this.cellContents_ = Rec.textfileToCell(fn);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

