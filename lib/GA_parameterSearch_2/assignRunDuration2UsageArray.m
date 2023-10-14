 %% بسم الله الرحمن الرحیم 

%% ## Assign Run Duration to Usage Array ##
% 15.12.2020, Ferhat Yılmaz

%% Description
%{
  Function to assign run duration of appliances to usage array.
  Samples which covered by run duration, turn FALSE.

  >> Inputs:
  1. <operationStruct> : structure : Operation structure of the appliance
  2. <usageArray> : array : Usage array which belongs to the appliance
  3. <startSample> : integer : Start sample of run duration
  4. <runtimeSample> : integer : Runtime of the applianes (for periodic appliances)
  5. <COUNT_SAMPLE_IN_DAY> : integer : Count of sample in a day
  6. <COUNT_WEEKS> : integer : Count of weeks

<< Outputs:
  1. <usageArray> : array : Manipulated usage array
%}

%%
function usageArray = assignRunDuration2UsageArray(usageArray, startSample, runtimeSample, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS)
  % Transfor usage array to vector
  mergedUsageVector = reshape(transpose(usageArray), 1, COUNT_WEEKS*7*COUNT_SAMPLE_IN_DAY);
  sizeOfMergedUsageVector = numel(mergedUsageVector);
  
  % Determine <endSample>
  endSample = startSample + runtimeSample - 1;
  
  % Assign 'false' to <mergedUsageVector> during runtime
  if endSample <= sizeOfMergedUsageVector
    mergedUsageVector(startSample:endSample) = false;
  else
    mergedUsageVector(startSample:end) = false;
  end
  
  % Re-transform <mergedUsageVector> to <usageArray>
  usageArray = transpose(reshape(mergedUsageVector, COUNT_SAMPLE_IN_DAY, COUNT_WEEKS*7));
end
