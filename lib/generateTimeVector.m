 %% بسم الله الرحمن الرحیم 

%% ## Time Vector Generation ##
% 24.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to generate a time vector according to
	sample period.

>> Inputs:

<< Outputs:
	1. <timeVector> : matrix : Time vector of the data
%}

%%
function timeVector = generateTimeVector()
	global SAMPLE_PERIOD;
	
	timeVector = [];
	minVector_string = [];
	
	% Total minute in a day
	minInDay = 24*60;
	
	% Check for sample period is less than total
	% minute in a day
	assert(SAMPLE_PERIOD <= minInDay, 'Sample period not fit in a day!');
	
	% Convert minute vector to string vector
	for m = 0:SAMPLE_PERIOD:minInDay
		minVector_string = [minVector_string, strcat(string(m), ':0')];
	end
	
	% Generate time vector of data
	for m = minVector_string
		timeVector = [timeVector duration(m,'InputFormat', 'mm:ss')];
end
