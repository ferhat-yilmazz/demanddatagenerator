 %% بسم الله الرحمن الرحیم 

%% ## Blend-alpha-beta Crossover (BLX-alpha-beta) ##
% 02.01.2021, Ferhat Yılmaz

%% Description
%{
	Function to apply "blend-alpha-beta crossover". 1 offspring will be generated
	after crossover.

	Note: Blend-alpha-beta crossover method documentation is not covered in the script.

	>> Inputs:
	1. <parents> : array : Array for parents (2x[COUNT_GENES])
	2. <parentFitness> : array : Array for fitness values of parent chromosomes (2x1)
	3. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)

<< Outputs:
	1. <offsprings> : array : Generated offsprings
%}

%%
function offsprings = x_blxAlphaBetaCrossover(parents, parentFitness, COUNT_GENES)
	% Define <offsprings> array
	offsprings = single(zeros(1, COUNT_GENES));
	
	%{
		i: index of gene
		better_parent = Parent has better fitness value
		worse_parent = Parent has worse fitness value
		d = |better_parent - worse_parent|
		alpha= 0.75
		beta = 0.25
	%}
	% Define <alpha> and <beta>
	alpha = 0.75;
	beta = 0.25;
	
	% Determine better and worse chromosomes in parents
	better_parent = parents(parentFitness == min(parentFitness), :); % Smaller fitness is BETTER
	worse_parent = parents(parentFitness == max(parentFitness), :); % Greater fitness is WORSE
	
	% For each gene
	for gene_index = 1:COUNT_GENES
		% Determine <d> value
		d = abs(better_parent(gene_index) - worse_parent(gene_index));
		% Determine <range_min> and <range_max> 
		if better_parent(gene_index) <= worse_parent(gene_index)
			range_min = better_parent(gene_index) - d*alpha;
			range_max = worse_parent(gene_index) + d*beta;
		else
			range_min = worse_parent(gene_index) - d*beta;
			range_max = better_parent(gene_index) + d*alpha;
		end
		% Assign offspring gene
		offsprings(1, gene_index) = range_min + rand()*(range_max-range_min);
		
		% DEBUG
		% fprintf("\n## gene: %i ## d = %f ## range_min = %f ## range_max = %f ## offspring(gene) = %f",...
		%																																								gene_index, d, range_min, range_max, offsprings(1, gene_index));
	end
end
