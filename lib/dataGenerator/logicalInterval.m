 %% بسم الله الرحمن الرحیم 

%% ## Logical Representetion of Given Time Interval ##
% 13.09.2020, Ferhat Yılmaz

%% Description
%{
  Function to returns a vector which describes given time interval
  as logical values in TIME_VECTOR. Limit times included.

>> Inputs:
  1. <lowerSample> : integer : Start sample value
  2. <upperSample> : integer : End sample value
  3. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day

<< Outputs:
  1. <logicalInterval> : vector : Logical vector describes given interval as true
%}

%%
function logicalVector = logicalInterval(lowerSample, upperSample, COUNT_SAMPLE_IN_DAY)  
  % Generate logical false vector
  logicalVector = false(1,COUNT_SAMPLE_IN_DAY);
  
  % Check for the <startSample> is less than the <endSample>; otherwise there is overday case.
  if (lowerSample < upperSample)
    logicalVector(lowerSample:upperSample) = true;
  elseif (lowerSample > upperSample)
    logicalVector([1:upperSample lowerSample:end]) = true;
  else
    logicalVector = ~logicalVector;
  end
end
