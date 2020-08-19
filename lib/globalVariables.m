 %% بسم الله الرحمن الرحیم 

%% ## Global Variables ##
% 15.08.2020, Ferhat Yılmaz

%% Description
%{
	Script to define global variables. These variables are used
	in all program and they are never changed in runtime.
%}

%% Declare global variables
% Count of end-users
global COUNT_END_USERS
% Count of weeks
global COUNT_WEEKS
% Try limit
global TRY_LIMIT
% Sample period
global SAMPLE_PERIOD
% Count of sample in an hour
global COUNT_SAMPLE_IN_HOUR
% Count of sample in a day
global COUNT_SAMPLE_IN_DAY

%% Definition of global variables
COUNT_END_USERS = initialConditions.endUserCount;
COUNT_WEEKS = initialConditions.weekCount;
TRY_LIMIT = initialConditions.tryLimit;
SAMPLE_PERIOD = initialConditions.samplePeriod;
COUNT_SAMPLE_IN_HOUR = ceil(60/SAMPLE_PERIOD);
COUNT_SAMPLE_IN_DAY = 24*COUNT_SAMPLE_IN_DAY;
