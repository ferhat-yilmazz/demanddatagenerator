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
global DAY_PIECE
% Sample period
global SAMPLE_PERIOD
% Count of sample in an hour
global COUNT_SAMPLE_IN_HOUR
% Count of sample in a day
global COUNT_SAMPLE_IN_DAY
% Sample2Time vector
global TIME_VECTOR

%% Definition of global variables
COUNT_END_USERS = initialConditions.endUserCount;
COUNT_WEEKS = initialConditions.weekCount;
DAY_PIECE = initialConditions.dayPiece;
SAMPLE_PERIOD = initialConditions.samplePeriod;
COUNT_SAMPLE_IN_HOUR = floor(60/SAMPLE_PERIOD);
COUNT_SAMPLE_IN_DAY = 24*COUNT_SAMPLE_IN_DAY;
TIME_VECTOR = generateTimeVector;
