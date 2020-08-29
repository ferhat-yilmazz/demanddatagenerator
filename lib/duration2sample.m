 %% بسم الله الرحمن الرحیم 

%% ## Sample to Array Converter ##
% 24.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to convert time duration to sample
	count.

>> Inputs:
	1. <timeDuration> : integer
<< Outputs:
	1. <sampleCount> : integer
%}

%%
function sampleCount = duration2sample(timeDuration)
	global SAMPLE_PERIOD;
	
	% Sample count of appliances determined with 'ceil' method.
	% However, time vector generated with 'floor' method.
	sampleCount = ceil(timeDuration/SAMPLE_PERIOD);
end
