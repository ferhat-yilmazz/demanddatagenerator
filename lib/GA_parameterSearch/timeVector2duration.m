 %% بسم الله الرحمن الرحیم 

%% ## Converter: Time Vector to Duration ##
% 22.12.2020, Ferhat Yılmaz

%% Description
%{
	Function to convert given time vector to duration value.
	Time vector contains two items: First for hour value and
	second for minute value. İtems must be an integer.

	If time vecor has one item and it is -1, than time is equal to
	sample period.

>> Inputs:
	1. <timeVector> : vector : Time vector such that [<hour>, <minute>] OR [-1]
	2. <SAMPLE_PERIOD> : integer : Sample period in minutes

<< Outputs:
	1. <timeInDuration> : duration : Duration value
	2. <mode> : string : '24h' or 'inf'
%}

%%
function timeInDuration = timeVector2duration(timeVector, mode, SAMPLE_PERIOD)	
	% Check for how many item contained at <timeVector>
	if numel(timeVector) == 1
		if timeVector == -1
			% Then given time value equal to the sample period
			hourPart = uint16(0);
			minutePart = SAMPLE_PERIOD;
		else
			error('timeVector2Duration(): Undefined value in <timeVector>');
		end
	elseif numel(timeVector) == 2
		% Decode time vector as <hourPart> and <minutePart>
		hourPart = uint16(fix(timeVector(1)));
		minutePart = uint16(fix(timeVector(2)));
	else
		error('<timeVector> format is undefined!');
	end
	
	timeInMinute = (hourPart * 60) + minutePart;
	
	timeInDuration = duration(strcat(string(timeInMinute), ':0'), 'InputFormat', 'mm:ss');
	
	% According to <mode>, determine duration
	if strcmp(mode, '24h')
		assert(timeInDuration <= duration('23:59', 'InputFormat', 'hh:mm'), 'Given value does not represent a 24h time format!');
	elseif ~strcmp(mode, 'inf')
		error('timeVector2Duration(): Undefined <mode>');
	end
end
