 %% بسم الله الرحمن الرحیم 

%% ## Local Crossover ##
% 30.12.2020, Ferhat Yılmaz

%% Description
%{
	Function to apply "local crossover". 1 offspring will be generated
	after crossover.

	Note: Local crossover method documentation is not covered in the script.

	>> Inputs:
	1. <parents> : array : Array for parents (2x[COUNT_GENES])

<< Outputs:
	1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_localCrossover(parents)
	% Count of genes in each chromosome (count of parameters)
	global COUNT_GENES;
	
	% Define <offsprings> array
	offsprings = single(zeros(1, COUNT_GENES));
	
	% For each gene select <alpha> randomly
	for gene_index = 1:COUNT_GENES
		% Select <alpha> randomly
		alpha = rand();
		% Assign offspring gene
		offsprings(1, gene_index) = (alpha*parents(1, gene_index)) + ((1-alpha)*parents(2, gene_index));
	end
end
