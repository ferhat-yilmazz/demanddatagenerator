 %% بسم الله الرحمن الرحیم 

%% ## Global Variables ##
% 15.08.2020, Ferhat Yılmaz

%% Description
%{
	Script to define global variables. These variables are used
	in all program and they are never changed (READ ONLY) in runtime.
%}

%% Declare global variables
% Count of end-users
global COUNT_END_USERS;
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
% Maximum count of EV battery statuses
global BATTERY_LEVEL_RAND_LIMIT;

%% Definition of global variables
COUNT_END_USERS = initialConditions.endUserCount;
COUNT_WEEKS = initialConditions.weekCount;
DAY_PIECE = initialConditions.dayPiece;
SAMPLE_PERIOD = minutes(double2duration(initialConditions.samplePeriod));
GLOB_MAX_OPERATION_LIMIT = duration2sample(double2duration(initialConditions.globalMaxOperationLimit));
% Check for sample period sub-multiple of minutes in a day.
msg = 'Please edit sample period as sub-multiple of minutes in a day!';
assert(mod(24*60, SAMPLE_PERIOD) == 0, msg);
COUNT_SAMPLE_IN_DAY = (24*60)/SAMPLE_PERIOD;
TIME_VECTOR = generateTimeVector;
RAND_METHOD = 'TRNG';
BATTERY_LEVEL_RAND_LIMIT = 100;
