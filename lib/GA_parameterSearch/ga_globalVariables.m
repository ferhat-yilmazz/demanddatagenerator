 %% بسم الله الرحمن الرحیم 

%% ## Genetic Algorithm Global Variables ##
% 10.11.2020, Ferhat Yılmaz

%% Description
%{
	Script to define global variables. These variables are used
	in all program and they are never changed (READ ONLY) in runtime.
%}

%% Declare global variables
% Count of weeks
global COUNT_WEEKS;
% Try limit
global DAY_PIECE;
% Sample period
global SAMPLE_PERIOD;
% Count of sample in a day
global COUNT_SAMPLE_IN_DAY;
% Sample2Time vector
global TIME_VECTOR;
% Rand method
global RAND_METHOD;
% Global maximum operation duration
global GLOB_MAX_OPERATION_LIMIT;
% Count of chromosomes(count of individuals in a population)
global COUNT_CHROMOSOME;
% Count of genes in each chromosome (count of parameters)
global COUNT_GENE;
% Lower limit of genes
global GENE_LOW_LIMIT;
% Upper limit of genes
global GENE_UP_LIMIT;
% Termination error percentage
global TERMINATION_ERROR_PERCENTAGE;
% Termination chromosome count
global TERMINATION_CHROMOSOME_COUNT;
% Count of chosens
global COUNT_CHOSENS;
% Count of elites
global COUNT_ELITES

%% Definition of global variables
COUNT_WEEKS = uint16(geneticAlgorithm.weekCount);
DAY_PIECE = uint16(initialConditions.dayPiece);
SAMPLE_PERIOD = minutes(timeVector2duration(initialConditions.samplePeriod, '24h'));
GLOB_MAX_OPERATION_LIMIT = duration2sample(timeVector2duration(initialConditions.globalMaxOperationLimit, 'inf'), 'inf');
% Check for <GLOB_MAX_OPERATION_LIMIT> is greater that <SAMPLE_PERIOD>
assert(GLOB_MAX_OPERATION_LIMIT >= SAMPLE_PERIOD, '<GLOB_MAX_OPERATION_LIMIT> cannot less than <SAMPLE_PERIOD>');
% Check for sample period sub-multiple of minutes in a day.
msg = 'Please edit sample period as sub-multiple of minutes in a day!';
assert(mod(24*60, SAMPLE_PERIOD) == 0, msg);
COUNT_SAMPLE_IN_DAY = uint16((24*60)/SAMPLE_PERIOD);
TIME_VECTOR = generateTimeVector;
RAND_METHOD = geneticAlgorithm.randomizationMethod;
% Check randomization method is valid
assert(strcmp(RAND_METHOD, 'TRNG') || strcmp(RAND_METHOD, 'PRNG'), "intialConditions.json:Randomization method is not valid!");
COUNT_CHROMOSOME = geneticAlgorithm.algorithm.chromosomeCount;
COUNT_GENE = uint16(geneticAlgorithm.algorithm.geneCount);
GENE_LOW_LIMIT = uint16(geneticAlgorithm.algorithm.geneLowerLimit);
GENE_UP_LIMIT = uint16(geneticAlgorithm.algorithm.geneUpperLimit);
TERMINATION_ERROR_PERCENTAGE = single(geneticAlgorithm.algorithm.terminationPercentage);
TERMINATION_CHROMOSOME_COUNT = uint16(geneticAlgorithm.algorithm.terminationChromosomeCount);
COUNT_CHOSENS = uint16(geneticAlgorithm.algorithm.chosensCount);
COUNT_ELITES = uint16(geneticAlgorithm.algorithm.elitesCount);
% Check for chosens and elites counts are valid
assert(COUNT_CHOSENS + COUNT_ELITES <= COUNT_CHROMOSOME, "geneticAlgorithm.json: <chosensCount> + <elitesCount> cannot exceed <chromosomeCount>");
