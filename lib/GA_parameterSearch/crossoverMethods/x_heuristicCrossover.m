%% بسم الله الرحمن الرحیم 

%% ## Heuristic Crossover ##
% 03.01.2021, Ferhat Yılmaz

%% Description
%{
	Function to apply "heuristic crossover". 1 offspring will be generated
	after crossover.

	Note: Heuristic crossover method documentation is not covered in the script.

	>> Inputs:
	1. <parents> : array : Array for parents (2x[COUNT_GENES])
	2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)

<< Outputs:
	1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_heuristicCrossover(parents, COUNT_GENES)
	% Define <offsprings> array
	offsprings = single(zeros(1, COUNT_GENES));
	
	% For each gene
	for gene_index = 1:COUNT_GENES
		% Select <alpha> randomly in interval (0,1)
		alpha = rand();
		% Compare allele belong to parents
		if (parents(2, gene_index) <= parents(1, gene_index))
			% Assign offspring gene
			offsprings(1, gene_index) = parents(2, gene_index) + alpha*(parents(1, gene_index) - parents(2, gene_index));
		else
			% Assign offspring gene
			offsprings(1, gene_index) = parents(1, gene_index) + alpha*(parents(2, gene_index) - parents(1, gene_index));
		end
	end
end
