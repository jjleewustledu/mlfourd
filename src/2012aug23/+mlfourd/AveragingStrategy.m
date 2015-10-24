classdef AveragingStrategy < handle
% AVERAGINGSTRATEGY Summary of this class goes here
%   Detailed explanation goes here

   properties
       strategyType = {};
   end

   methods
       function this = AveragingStrategy(choice)
           this.SetAveragingStrategy(choice);
       end
       
       function SetAveragingStrategy(this, choice)
           if     (ischar(choice))
               this.strategyType = mlfourd.AveragingType.newType(choice);
           elseif (isa(choice, 'mlfourd.AveragingType'))
               this.strategyType = choice;
           else
               error('mlfourd:UnsupportedType', 'class(AveragingStrategy.choice)->%s', class(choice));
           end 
       end
       
       function imgcmp = average(this, imgcmp)
           imgcmp = this.strategyType.average(imgcmp);
       end
   end
end 

%EOF
