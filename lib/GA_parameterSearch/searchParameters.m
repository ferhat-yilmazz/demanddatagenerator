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
outcomeParameters = struct();

% Define information print format
fmt_bestChromosome = ['\n <Best Chromosome> :' repmat('  %4.4f  ', 1, COUNT_GENES)];
fmt_top5fitness = ['\n <Top 5 Fitness> : ' repmat('  %4.4f  ', 1, 5)];

% Build main <endUsers> structure
endUserTypesStruct = buildEndUsersStruct(appliancesData, residentalTypes, defaultValues.weeklyRunInReal);
endUserTypes = transpose(fieldnames(endUserTypesStruct));

% For each end-user
for endUserType = endUserTypes
	% Get appliances whic belong to the end-user type
	applianceList = transpose(fieldnames(endUserTypesStruct.(string(endUserType)).appliances));
	% For each appliance which belongs to the end-user type
	for appliance = applianceList
		% ## GENETIC ALGORITHM PROCESS ##
		% Define generation counter
		generationCounter = 1;
		
		% Generate initial population randomly
		population = generateRandomPopulation(COUNT_CHROMOSOMES, COUNT_GENES, GENE_LOW_LIMIT, GENE_UP_LIMIT);
		% Determine fitness values for initial population
		fitnessVector = arrayfun(@(row_index) fitnessFunction(endUserTypesStruct.(string(endUserType)), string(appliance),...
																																															population(row_index, :)), (1:size(population, 1))');
		
		% Print information
		fprintf("\n »»»»»»»»»»»»»»»»»»");
		fprintf("\n <User Type> : %s", string(endUserType));
		fprintf("\n <Appliance> : %s", string(appliance));
		fprintf("\n <Generation> : %i", generationCounter);
		fprintf(fmt_bestChromosome, population(find(fitnessVector == min(fitnessVector), 1, 'first'),:));
		fprintf(fmt_top5fitness, fitnessVector(find(fitnessVector == min(fitnessVector), 5, 'first')));
		fprintf("\n ««««««««««««««««««\n");
			
		% Termination condition
		while ~(sum(fitnessVector <= TERMINATION_ERROR_PERCENTAGE) >= TERMINATION_CHROMOSOME_COUNT)
			% ## SELECTION ##
			[chosensID, elitesID] = selectionOperator(fitnessVector);
			
			% Assign chosen chromosomes, elite chromosomes and fitness values
			chosenChromosomes = population(chosensID, :);
			eliteChromosomes = population(elitesID, :);
			chosensFitness = fitnessVector(chosensID);
			
			% ## CROSSOVER ##
			% As a result of crossover operation, a new generation (population) will be genarated
			% Add fitness values of chosen chromosomes to parameter of crossover operator
			population = crossoverOperator(chosenChromosomes, chosensFitness);
			
			% ## ELITISM ##
			% Assign elites to <population>
			if COUNT_ELITES > 0
				population((end-COUNT_ELITES+1):end, :) = eliteChromosomes;
			end
			
			% ## MUTATION ##
			% ** Elite chromosomes do not mutated
			population = mutationOperator(population);
			
			% ## FITNESS ##
			% Determine fitness values of new population
			fitnessVector = arrayfun(@(row_index) fitnessFunction(endUserTypesStruct.(string(endUserType)), string(appliance),...
																																															population(row_index, :)), (1:size(population, 1))');
			
			% Increase <generationCounter> by 1
			generationCounter = generationCounter + 1;
		
			% Print information
			fprintf("\n »»»»»»»»»»»»»»»»»»");
			fprintf("\n <User Type> : %s", string(endUserType));
			fprintf("\n <Appliance> : %s", string(appliance));
			fprintf("\n <Generation> : %i", generationCounter);
			fprintf(fmt_bestChromosome, population(find(fitnessVector == min(fitnessVector), 1, 'first'),:));
			fprintf(fmt_top5fitness, fitnessVector(find(fitnessVector == min(fitnessVector), 5, 'first')));
			fprintf("\n ««««««««««««««««««\n");
		end
		
		% Termination is valid!
		% Assign parameters
		outcomeParameters.(string(endUserType)).(string(appliance)) = population(fitnessVector == min(fitnessVector), :);
	end
end



%% Clear Unnecessary variables
clear PATH_applianceData PATH_residentalTypes PATH_electricVehicles...
			PATH_defaultCoefficients PATH_initialConditions msg
		
%% Clear Global Variables
clear global COUNT_END_USERS global COUNT_SAMPLE_IN_DAY global COUNT_WEEKS...
	global SAMPLE_PERIOD global TRY_LIMIT global RAND_METHOD global DAY_PIECE...
	global BATTERY_LEVEL_RAND_LIMIT global GLOB_MAX_OPERATION_LIMIT

