 %% بسم الله الرحمن الرحیم 

%% ## Check Given Sample is in Given Interval ##
% 09.12.2020, Ferhat Yılmaz

%% Description
%{
  Function to check given sample is in the given interval.

  >> Inputs:
  1. <sample> : integer : Sample
  2. <interval_low> : integer : Lower limit of the interval
  3. <interval_up> : integer : Upper limit of the interval

<< Outputs:
  1. <result> : logical : Result
%}

%%
function result = isInInterval(sample, interval_low, interval_up)
  % Assign false initially
  result = false;
  % There are 3 cases:
  %    1) interval_low < interval_up
  %    2) interval _low > interval_up
  %    3) interval_low = interfval_up
  %
  % CASE -1
  if (interval_low < interval_up)
    % True if sample >= interval_low AND sample <= interval_up
    if (interval_low <= sample) && (sample <= interval_up)
      result = true;
    end
  %
  % CASE -2
  elseif (interval_low > interval_up)
    % True if interval_low <= sample AND interval_up <= sample
    % OR True if interval_low > sample AND sample <= interval_up
    if ((interval_low <= sample) && (sample > interval_up)) || ((interval_low > sample) && (sample <= interval_up))
      result = true;
    end
    % CASE -3
  elseif (interval_low == interval_up)
    % True always
    result = true;
  end
end
