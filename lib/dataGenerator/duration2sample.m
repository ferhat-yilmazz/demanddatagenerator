 %% بسم الله الرحمن الرحیم 

%% ## Sample to Array Converter ##
% 24.08.2020, Ferhat Yılmaz

%% Description
%{
  Function to convert time duration to sample
  count.

>> Inputs:
  1. <timeDuration> : integer
  2. <mode> : string : Mode for '24h' or 'inf'
  3. <SAMPLE_PERIOD> : integer : Period of a sample in minutes

<< Outputs:
  1. <sampleCount> : integer
%}

%%
function sampleCount = duration2sample(timeDuration, SAMPLE_PERIOD, mode)
  % Sample count of appliances determined with 'ceil' method.
  % However, time vector generated with 'floor' method.
  sampleCount = single(ceil(minutes(timeDuration)/SAMPLE_PERIOD));
  
  if strcmp(mode, '24h')
    % If <sampleCount> equals to 0 (zero), then increae by one.
    % MATLAB does not accept zero based indexing.
    if sampleCount == 0
      sampleCount = single(1);
    end
  elseif ~strcmp(mode, 'inf')
    error('duration2sample(): Undefined <mode>');
  end
end
