 %% بسم الله الرحمن الرحیم 

%% ## Read-Only Variables ##
% 15.08.2020, Ferhat Yılmaz

%% Description
%{
  Script to define read-only variables. These variables are used
  in all program and they are never changed in runtime.
%}

%% Definition of variables
COUNT_END_USERS = initialConditions.endUserCount;
COUNT_WEEKS = initialConditions.weekCount;
COUNT_DAYS = COUNT_WEEKS * 7;
DAY_PIECE = initialConditions.dayPiece;
SAMPLE_PERIOD = minutes(timeVector2duration(initialConditions.samplePeriod, 0, '24h'));
GLOB_MAX_OPERATION_LIMIT = duration2sample(timeVector2duration(initialConditions.globalMaxOperationLimit, SAMPLE_PERIOD, 'inf'), SAMPLE_PERIOD, 'inf');
% Check for sample period sub-multiple of minutes in a day.
msg = 'Please edit sample period as sub-multiple of minutes in a day!';
assert(mod(24*60, SAMPLE_PERIOD) == 0, msg);
COUNT_SAMPLE_IN_DAY = (24*60)/SAMPLE_PERIOD;
RAND_METHOD = initialConditions.randomizationMethod;
%%
% Set random number stream
RandStream.setGlobalStream(RandStream('dsfmt19937'));
