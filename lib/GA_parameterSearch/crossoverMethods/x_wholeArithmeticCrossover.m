 %% بسم الله الرحمن الرحیم 

%% ## Whole Arithmetic Crossover ##
% 30.12.2020, Ferhat Yılmaz

%% Description
%{
	Function to apply "whole arithmetic crossover". 2 offsprings will be generated
	after crossover.

	Note: Whole arithmetic crossover method documentation is not covered in the script.

	>> Inputs:
	1. <parents> : array : Array for parents (2x[COUNT_GENES])

<< Outputs:
	1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_wholeArithmeticCrossover(parents)
	% Count of genes in each chromosome (count of parameters)
	global COUNT_GENES;
	
	% Define <offsprings> array
	offsprings = single(zeros(2, COUNT_GENES));
	
	% Select <alpha> randomly
	alpha = rand();

	% Offspring-1
	% Take arithmetic of parents with <alpha> weight for all genes
	offsprings(1, :) = (alpha*parents(1, :)) + ((1-alpha)*parents(2, :));
	
	% Offspring-2
	% Take arithmetic of parents with <alpha> weight for all genes
	offsprings(2, :) = (alpha*parents(2, :)) + ((1-alpha)*parents(1, :));
end
