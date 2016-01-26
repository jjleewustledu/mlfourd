classdef InnerCellComposite < mlpatterns.CellComposite
	%% INNERCELLCOMPOSITE is a mlpatterns.CellComposite designed for use by package mlfourd. 
    %  It is designed for clarity and efficiency over safety.

	%  $Revision$
 	%  was created 16-Jan-2016 17:59:46
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfourd/src/+mlfourd.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.

	methods		  
 		function this = InnerCellComposite(varargin)
            this = this@mlpatterns.CellComposite(varargin{:});
        end
        
        %% Composite        
        
        function this = add(this, varargin)
            this = this.horzcat(varargin{:});
        end
        function this = clone(this)
            this = mlfourd.InnerCellComposite(this);
        end
        function this = horzcat(this, varargin)
            this = mlfourd.InnerCellComposite(horzcat@mlpatterns.CellComposite(this, varargin{:}));
        end
        function this = rm(this, idx)
            this = mlfourd.InnerCellComposite(rm@mlpatterns.CellComposite(this, idx));
        end
        function this = subsasgn(this, S, varargin)
            %% SUBSASGN
            %  See also:  web(fullfile(docroot, 'matlab/matlab_oop/class-with-modified-indexing.html'))
            %             web(fullfile(docroot, 'matlab/ref/numargumentsfromsubscript.html'))
            
            this = mlfourd.InnerCellComposite(subsasgn@mlpatterns.CellComposite(this, S, varargin{:}));
        end
        function this = vertcat(this, varargin)
            this = mlfourd.InnerCellComposite(vertcat@mlpatterns.CellComposite(this, varargin{:}));
        end
        
        %% New for CellComposite
        
        function c    = cellEmpty(this)
            c = cell(1, length(this.cell_));
        end
        function this = fevalThis(this, funname, varargin)
            args = this.repmat(varargin{:});
            for c = 1:this.length
                if (isempty(args))
                    this.cell_{c} = this.cell_{c}.(funname);
                elseif (length(varargin) == 1)
                    this.cell_{c} = this.cell_{c}.(funname)(args{c});
                else
                    this.cell_{c} = this.cell_{c}.(funname)(args{c}{:});
                end
            end
        end
        function        fevalNone(this, funname, varargin)
            args = this.repmat(varargin{:});
            for c = 1:this.length
                if (isempty(args))
                    tmp = this.cell_{c};
                    tmp.(funname);
                elseif (length(varargin) == 1)
                    tmp = this.cell_{c};
                    tmp.(funname)(args{c});
                else
                    tmp = this.cell_{c};
                    tmp.(funname)(args{c}{:});
                end
            end
        end
        function out = fevalOut(this, funname, varargin)
            out = this.cellEmpty;
            args = this.repmat(varargin{:});
            for c = 1:this.length
                if (isempty(args))
                    out{c} = this.cell_{c}.(funname);
                elseif (length(varargin) == 1)
                    out{c} = this.cell_{c}.(funname)(args{c});
                else
                    out{c} = this.cell_{c}.(funname)(args{c}{:});
                end
            end
        end
        function [o,o2] = fevalOut2(this, funname, varargin)
            o  = this.cellEmpty;
            o2 = this.cellEmpty;
            args = this.repmat(varargin{:});
            for c = 1:this.length
                if (isempty(args))
                    [o{c},o2{c}] = this.cell_{c}.(funname);
                elseif (length(varargin) == 1)
                    [o{c},o2{c}] = this.cell_{c}.(funname)(args{c});
                else
                    [o{c},o2{c}] = this.cell_{c}.(funname)(args{c}{:});
                end
            end
        end
        function tf = fevalIsequal(this, in)
            tf  = this.cellEmpty;
            for c = 1:this.length
                item = this.cell_{c};
                tf{c} = item.isequal(in);
            end
        end
        function out  = getter(this, fldname)
            for c = 1:this.length
                out{c} = this.cell_{c}.(fldname);
            end
        end
        function args  = repmat(this, varargin)
            if (isempty(varargin))
                args = {};
                return
            end
            if (length(varargin) == 1)
                if (isa(varargin{1}, 'mlfourd.INIfTI')) %% KLUDGE for helper function repmat
                    args = cell(1, this.length);
                    for a = 1:this.length
                        args{a} = varargin{1};
                    end
                    return
                end
                args = repmat({varargin{1}}, 1, this.length); %#ok<CCAT1> % for clarity of data structure
                return
            end
            args = repmat({varargin}, 1, this.length);
        end
        function this = setter(this, fldname, in)
            for c = 1:this.length
                this.cell_{c}.(fldname) = in{c};
            end
        end        
 	end     

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

