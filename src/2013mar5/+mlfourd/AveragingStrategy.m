classdef AveragingStrategy < handle
% AVERAGINGSTRATEGY Summary of this class goes here
%   Detailed explanation goes here

   properties (Dependent)
       strategyType
       blur
   end

   methods %% set/get
       function st = get.strategyType(this)
           st = this.strategyType_;
       end
       function      set.blur(this, bl)
           this.strategyType_.blur = bl;
       end
       function bl = get.blur(this)
           bl = this.strategyType.blur_;
       end
   end
   
   methods
       function this  = AveragingStrategy(choice, blur)
           this.setAveragingStrategy(choice);
           if (exist('blur', 'var'))
               this.blur = blur;
           else
               this.blur = mlfsl.O15Builder.petFwhh;
           end
       end % ctor
       
       function         setAveragingStrategy(this, choice)
           if     (ischar(choice))
               this.strategyType_ = mlfourd.AveragingType.newType(choice);
           elseif (isa(choice, 'mlfourd.AveragingType'))
               this.strategyType_ = choice;
           else
               error('mlfourd:UnsupportedType', 'class(AveragingStrategy.choice)->%s', class(choice));
           end 
       end       
       function imobj = average(this, imobj)
           imobj = this.strategyType.average(imobj);
       end
   end

   %% PRIVATE
   
   properties (Access = 'private')
       strategyType_ = {};
   end

end
%EOF
