 %% بسم الله الرحمن الرحیم 

%% ## Double to Duration Converter ##
% 13.09.2020, Ferhat Yılmaz

%% Description
%{
	Function to convert given double value to duration.

>> Inputs:
	1. <timeInDouble> : double : Double value represents time.

<< Outputs:
	1. <timeInDuration> : duration : Duration value
%}

%%
function timeInDuration = double2duration(timeInDouble, format)
	% Get the sample period
	global SAMPLE_PERIOD;
	
	hourPart = fix(timeInDouble);
	minutePart = fix(timeInDouble*100) - (hourPart*100);
	
	if hourPart == -1
		hourPart = 0;
		minutePart = SAMPLE_PERIOD;
	elseif hourPart == -2
		hourPart = 0;
		minutePart = 0;
	end
	
	% If <format> = '24h', then assume that 0 <= hourPart <= 23 AND 0 <= minutePart <= 59
	if strcmp(format, '24h')
		assert((0 <= hourPart && hourPart <= 23) && (0 <= minutePart && minutePart <= 59), 'Given value does not represent a time!');
	elseif ~strcmp(format, 'inf')
		% If <format> ~= '24h' and <format> ~= 'inf', then return an error
		error('double2duration() : <format> error!');
	end
	
	% Convert minute:
	timeInMinute = hourPart*60 + minutePart;
	
	% Convert duration
	timeInDuration = duration(strcat(string(timeInMinute), ':0'), 'InputFormat', 'mm:ss');
end
