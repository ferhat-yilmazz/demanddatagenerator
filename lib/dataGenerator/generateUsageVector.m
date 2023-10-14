 %% بسم الله الرحمن الرحیم 

%% ## Usage Vector Generator ##
% 21.08.2020, Ferhat Yılmaz

%% Description
%{
  Function to generate the usage vector which will contain
  power consumption values relatively samples.
  Size of the vector determined by sample period.

>> Inputs:
  1. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day

<< Outputs:
  1. <usageVector> : matrix : Generated usage vector
%}

%%
function usageVector = generateUsageVector(COUNT_SAMPLE_IN_DAY)
  % Generate usage vector filled by zero
  usageVector = single(zeros(1, COUNT_SAMPLE_IN_DAY));
end
