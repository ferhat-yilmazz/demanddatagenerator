 %% بسم الله الرحمن الرحیم 

%% ## Sample to Array Converter ##
% 24.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to convert time duration to sample
	count.

>> Inputs:
	1. <timeDuration> : duration
	2. <mode> : string : Mode for '24h' or 'inf'
	3. <SAMPLE_PERIOD> : Sample period in minutes
<< Outputs:
	1. <sampleCount> : integer
%}

%%
function sampleCount = duration2sample(timeDuration, mode, SAMPLE_PERIOD)
	% Sample count of appliances determined with 'ceil' method.
	% However, time vector generated with 'floor' method.
	sampleCount = uint16(ceil(minutes(timeDuration)/SAMPLE_PERIOD));
	
	if strcmp(mode, '24h')
		% If <sampleCount> equals to 0 (zero), then increae by one.
		% MATLAB does not accept zero based indexing.
		if sampleCount == 0
			sampleCount = uint16(1);
		end
	elseif ~strcmp(mode, 'inf')
		error('duration2sample(): Undefined <mode>');
	end
end
