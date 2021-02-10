 %% بسم الله الرحمن الرحیم 

%% ## Random Number Picker ##
% 10.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to pick a random number from random pool vector
	of given <randStructure>. If pool is empty, the function
	calls "generateRandPool()" function to get new random
	series.

>> Inputs:
	1. <randStructure> : structure :  random number structure

<< Outputs:
	1. <randNumber> : integer : picked random number
%}

%%
function [randNumber, randStructure] = pickRandNumber(randStructure)
	% Check the <index> value, generate new pool it equals to zero
	if randStructure.index <= 0
		randStructure = generateRandPool(randStructure, randStructure.poolSize);
	end
	
	% Pick a number according to index order
	randNumber = randStructure.pool(randStructure.index);
	% Decrease index value by 1
	randStructure.index = randStructure.index - 1;

end
