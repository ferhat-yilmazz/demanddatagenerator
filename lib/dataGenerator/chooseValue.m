 %% بسم الله الرحمن الرحیم 

%% ## Choose Value by Given Format ##
% 15.01.2021, Ferhat Yılmaz

%% Description
%{
  Function to choose a value randomly (PRNG) from the given list
  in given format.

>> Inputs:
  1. <valueVector> : array : Vector contains values
  2. <format> : string : Choose format

<< Outputs:
  1. <chosenValue>: single : Chosen value from value vector
%}

%%
function chosenValue = chooseValue(valueVector, format)
  % Switch according to format
  switch format
    case 'choice'
      % In this mode size of <valueVector> must greater than zero
      assert(numel(valueVector) > 0, "<chooseValue> : In 'choice' mode, size of <valueVector> must greater than zero");
      % Select one of them randomly
      chosenValue = valueVector(randi([1 numel(valueVector)]));
    case 'interval'
      % In this mode size of <valueVector> must equal to two
      assert(numel(valueVector) == 2, "<chooseValue> : In 'choice' mode, size of <valueVector> must equal to two");
      % Select a number in interval of elements in <valueVector>
      chosenValue = min(valueVector) + rand() * (max(valueVector) - min(valueVector));
    otherwise
      % There is error for undefined <format>
      error("<chooseValue> : Undefined <format>");
  end
end
