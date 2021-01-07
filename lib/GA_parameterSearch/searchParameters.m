 %% بسم الله الرحمن الرحیم 

%% ## Search Parameters ##
% 09.10.2020, Ferhat Yılmaz

%% Description
%{
	Main loop for "genetic algorithm search" and save acquired parameters.
%}

%%
% Load configurations
ga_loadConfigurations;
% Load global variables
ga_globalVariables;
% Add path of crossover methods
addpath('./crossoverMethods');

% Initialize coefficient structure 
runprobabilityParameters = struct();

% Define information print format
fmt_bestChromosome = ['\n <Best Chromosome> :' repmat('  %4.4f  ', 1, COUNT_GENES)];
fmt_top5fitness = ['\n <Top Fitness Values> : ' repmat('  %4.4f  ', 1, 5)];

% Build main <endUsers> structure
endUserTypesStruct = buildEndUsersStruct(appliancesData,...
																				 residentalTypes,...
																				 defaultValues.weeklyRunInReal,...
																				 SAMPLE_PERIOD,...
																				 COUNT_SAMPLE_IN_DAY,...
																				 COUNT_WEEKS);

% For each end-user
for endUser_idx = 1:size(endUserTypesStruct, 2)
	% Generate <parameters> array
	parameterArray = single(zeros(size(endUserTypesStruct(endUser_idx).appliances, 2), COUNT_GENES));
	% Define user type name
	endUserType = endUserTypesStruct(endUser_idx);
	appliancesName = {endUserTypesStruct(endUser_idx).appliances(:).name};
	
	% For each appliance which belongs to the end-user type
	parfor appliance_idx = 1:size(endUserTypesStruct(endUser_idx).appliances, 2)
		% ## GENETIC ALGORITHM PROCESS ##
		% Define generation counter
		generationCounter = 1;
		
		% Generate initial population randomly
		population = generateRandomPopulation(COUNT_CHROMOSOMES, COUNT_GENES, GENE_LOW_LIMIT, GENE_UP_LIMIT, RAND_METHOD);
		% Determine fitness values for initial population
		fitnessVector = arrayfun(@(row_index) fitnessFunction(endUserType,...
																													appliance_idx,...
																													population(row_index, :),...
																													SAMPLE_PERIOD,...
																													COUNT_SAMPLE_IN_DAY,...
																													COUNT_WEEKS,...
																													DAY_PIECE,...
																													GLOB_MAX_OPERATION_LIMIT,...
																													RAND_METHOD), (1:size(population, 1))');
																												
		% Print information
		fprintf("\n »»»»»»»»»»»»»»»»»»");
		fprintf("\n <User Type> : %s", endUserType.type);
		fprintf("\n <Appliance> : %s", string(appliancesName(appliance_idx)));
		fprintf("\n <Generation> : %i", generationCounter);
		fprintf(fmt_bestChromosome, population(find(fitnessVector == min(fitnessVector), 1, 'first'),:));
		fprintf(fmt_top5fitness, fitnessVector(find(fitnessVector == min(fitnessVector), 5, 'first')));
		fprintf("\n ««««««««««««««««««\n");
			
		% Termination condition
		while ~(sum(fitnessVector <= TERMINATION_ERROR_PERCENTAGE) >= TERMINATION_CHROMOSOME_COUNT) && generationCounter <= 10
			% ## SELECTION ##
			[chosensID, elitesID] = selectionOperator(fitnessVector, COUNT_CHROMOSOMES, COUNT_CHOSENS, COUNT_ELITES);
			
			% Assign chosen chromosomes, elite chromosomes and fitness values
			chosenChromosomes = population(chosensID, :);
			eliteChromosomes = population(elitesID, :);
			chosensFitness = fitnessVector(chosensID);
			
			% ## CROSSOVER ##
			% As a result of crossover operation, a new generation (population) will be genarated
			% Add fitness values of chosen chromosomes to parameter of crossover operator
			population = crossoverOperator(chosenChromosomes,...
																		 chosensFitness,...
																		 COUNT_GENES,...
																		 COUNT_CHROMOSOMES,...
																		 COUNT_CHOSENS,...
																		 COUNT_OFFSPRINGS,...
																		 CROSSOVER_METHODS);
			
			% ## ELITISM ##
			% Assign elites to <population>
			if COUNT_ELITES > 0
				population((end-COUNT_ELITES+1):end, :) = eliteChromosomes;
			end
			
			% ## MUTATION ##
			% ** Elite chromosomes do not mutated
			population = mutationOperator(population,...
																			 COUNT_GENES,...
																			 COUNT_OFFSPRINGS,...
																			 MUTATION_CHROMOSOME_PERCENT,...
																			 MUTANT_CHROMOSOME_EFFECT,...
																			 MUTATION_GENE_PERCENT,...
																			 MUTANT_GENE_EFFECT,...
																			 MUTATION_RATE);
			
			% ## FITNESS ##
			% Determine fitness values of new population
			fitnessVector = arrayfun(@(row_index) fitnessFunction(endUserType,...
																													appliance_idx,...
																													population(row_index, :),...
																													SAMPLE_PERIOD,...
																													COUNT_SAMPLE_IN_DAY,...
																													COUNT_WEEKS,...
																													DAY_PIECE,...
																													GLOB_MAX_OPERATION_LIMIT,...
																													RAND_METHOD), (1:size(population, 1))');
			
			% Increase <generationCounter> by 1
			generationCounter = generationCounter + 1;
		
			% Print information
			fprintf("\n »»»»»»»»»»»»»»»»»»");
			fprintf("\n <User Type> : %s", endUserType.type);
			fprintf("\n <Appliance> : %s", string(appliancesName(appliance_idx)));
			fprintf("\n <Generation> : %i", generationCounter);
			fprintf(fmt_bestChromosome, population(find(fitnessVector == min(fitnessVector), 1, 'first'),:));
			fprintf(fmt_top5fitness, fitnessVector(find(fitnessVector == min(fitnessVector), 5, 'first')));
			fprintf("\n ««««««««««««««««««\n");
		end
		
		% Termination is valid!
		% Assign parameters
		parameterArray(appliance_idx, :) = population(find(fitnessVector == min(fitnessVector), 1, 'first'), :);
	end
	% Assign parameter array to <runprobabilityParameters>
	for parameter_idx = 1:size(endUserTypesStruct(endUser_idx).appliances, 2)
		runprobabilityParameters.(endUserType.type).(string(appliancesName(parameter_idx))) = parameterArray(parameter_idx, :);
	end
end
