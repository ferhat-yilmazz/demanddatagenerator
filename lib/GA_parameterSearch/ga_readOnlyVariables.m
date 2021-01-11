 %% بسم الله الرحمن الرحیم 

%% ## Genetic Algorithm Read-Only Variables ##
% 10.11.2020, Ferhat Yılmaz

%% Description
%{
	Script to define read-only variables. These variables are used
	in all program and they are never changed in runtime.
%}

%% Definition of global variables
COUNT_WEEKS = uint16(geneticAlgorithm.weekCount);
DAY_PIECE = uint16(initialConditions.dayPiece);
SAMPLE_PERIOD = minutes(timeVector2duration(initialConditions.samplePeriod, '24h', 0)); % Sample period is not necessary here!
GLOB_MAX_OPERATION_LIMIT = duration2sample(timeVector2duration(initialConditions.globalMaxOperationLimit, 'inf', SAMPLE_PERIOD),...
																					 'inf',...
																					 SAMPLE_PERIOD);
% Check for <GLOB_MAX_OPERATION_LIMIT> is greater that <SAMPLE_PERIOD>
assert(GLOB_MAX_OPERATION_LIMIT >= SAMPLE_PERIOD, '<GLOB_MAX_OPERATION_LIMIT> cannot less than <SAMPLE_PERIOD>');
% Check for sample period sub-multiple of minutes in a day.
msg = 'Please edit sample period as sub-multiple of minutes in a day!';
assert(mod(24*60, SAMPLE_PERIOD) == 0, msg);
COUNT_SAMPLE_IN_DAY = uint16((24*60)/SAMPLE_PERIOD);
RAND_METHOD = geneticAlgorithm.randomizationMethod;
% Check randomization method is valid
assert(strcmp(RAND_METHOD, 'TRNG') || strcmp(RAND_METHOD, 'PRNG'), "intialConditions.json:Randomization method is not valid!");
CROSSOVER_METHODS = dir(strcat('.', filesep, 'crossoverMethods', filesep, 'x_*.m'));
COUNT_CHROMOSOMES = geneticAlgorithm.population.chromosomeCount;
COUNT_GENES = uint16(geneticAlgorithm.population.geneCount);
GENE_LOW_LIMIT = uint16(geneticAlgorithm.population.geneLowerLimit);
GENE_UP_LIMIT = uint16(geneticAlgorithm.population.geneUpperLimit);
TERMINATION_ERROR_PERCENTAGE = single(geneticAlgorithm.termination.terminationPercentage);
TERMINATION_CHROMOSOME_COUNT = uint16(geneticAlgorithm.termination.terminationChromosomeCount);
COUNT_CHOSENS = uint16(geneticAlgorithm.selection.chosensCount);
COUNT_ELITES = uint16(geneticAlgorithm.selection.elitesCount);
% Check for chosens and elites counts are valid
assert(COUNT_CHOSENS <= COUNT_CHROMOSOMES, "geneticAlgorithm.json: <chosensCount> cannot exceed <chromosomeCount>");
assert(COUNT_ELITES <= COUNT_CHROMOSOMES, "geneticAlgorithm.json: <elitesCount> cannot exceed <chromosomeCount>");
COUNT_OFFSPRINGS = COUNT_CHROMOSOMES - COUNT_ELITES;
MUTATION_CHROMOSOME_PERCENT = single(geneticAlgorithm.mutation.initialChromosomePercentage);
MUTANT_CHROMOSOME_EFFECT = single(geneticAlgorithm.mutation.effectEachChromosome);
MUTATION_GENE_PERCENT = single(geneticAlgorithm.mutation.initialGenePercentage);
MUTANT_GENE_EFFECT = single(geneticAlgorithm.mutation.effectEachGene);
MUTATION_RATE = single(geneticAlgorithm.mutation.mutationRate);

%% 
% Set random number stream
RandStream.setGlobalStream(RandStream('dsfmt19937'));
