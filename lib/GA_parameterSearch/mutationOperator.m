 %% بسم الله الرحمن الرحیم 

%% ## Mutation Operator ##
% 04.01.2021, Ferhat Yılmaz

%% Description
%{
	Function to realise mutation process fo population. Possibility rates
	of which chromosomes will mutate or which genes will mutate, are specified
	in "geneticAlgorithm.json" configuration files. There are dynamic rates.

	>> Inputs:
	1. <population> : array : Population array which contains chromosomes
																(except elite chromosomes)
	2. <COUNT_GENES> : integer : Count of genes in each chromosome (count of parameters)
	3. <COUNT_OFFSPRINGS> : integer : Count of offsprings
	4. <MUTATION_CHROMOSOME_PERCENT> : single : Initial mutation possibility of chromosomes (%)
	5. <MUTANT_CHROMOSOME_EFFECT> : single : Mutant chromosome effect to possibility
	6. <MUTANT_GENE_PERCENT> : single : Initial mutation possibility of genes (%)
	7. <MUTANT_GENE_EFFECT> : single : Mutant gene effect to possibility
	8. <MUTATION_RATE> : single : Rate of mutation (%)

<< Outputs:
	1. <mutantPopulation> : array : Mutant population array (except elite chromosomes)
%}

%%
function population = mutationOperator(population,...
																			 COUNT_GENES,...
																			 COUNT_OFFSPRINGS,...
																			 MUTATION_CHROMOSOME_PERCENT,...
																			 MUTANT_CHROMOSOME_EFFECT,...
																			 MUTATION_GENE_PERCENT,...
																			 MUTANT_GENE_EFFECT,...
																			 MUTATION_RATE)
	% Randomize chromosome IDs
	randomChromosomeIDs = randperm(COUNT_OFFSPRINGS);
	
	% Define mutant chromosome counter
	mutantChromosomeCounter = 0;
	
	% For each chromosome, check for mutation probability
	for chromosome_index = randomChromosomeIDs
		% Determine probability of mutation for the chromosome
		chromosomeMutationProbability = MUTATION_CHROMOSOME_PERCENT - mutantChromosomeCounter*MUTANT_CHROMOSOME_EFFECT;
		% Select a random reel number in interval (0,100)
		randNumber_chromosome = rand()*100;
		% If <randNumber_chromosome> is less than or equal to <chromosomeMutationProbability>,
		% then it is possible to mutate the chromosome
		if randNumber_chromosome <= chromosomeMutationProbability
			% Increae <mutantChromosomeCounter> by 1
			mutantChromosomeCounter = mutantChromosomeCounter + 1;
			% Define mutant gene counter
			mutantGeneCounter = 0;
			
			% Randomize gene IDs
			randomGeneIDs = randperm(COUNT_GENES);
			
			% For each gene of the selected chromosome, check for mutation probability
			for gene_index = randomGeneIDs
				% Determine mutation probability for the gene
				geneMutationProbability = MUTATION_GENE_PERCENT - mutantGeneCounter*MUTANT_GENE_EFFECT;
				% Select a random reel number in interval (0,100)
				randNumber_gene = rand()*100;
				% If <randNumber_gene> is less than or equal to <geneMutationProbability>,
				% then mutation is occured for the gene
				if randNumber_gene <= geneMutationProbability
					% Increase <mutantGeneCounter> by 1
					mutantGeneCounter = mutantGeneCounter + 1;
					% ## MUTATION ##
					% Select mutation rate randomly with limited defined bound
					mutationRate = -MUTATION_RATE + rand()*(2*MUTATION_RATE);
					% Mutation equation
					population(chromosome_index, gene_index) = population(chromosome_index, gene_index)...
																																										+ ((population(chromosome_index, gene_index)*mutationRate)/100);
				end
			end
		end
	end
end
