 %% بسم الله الرحمن الرحیم 

%% ## Logical Representetion of Given Time Interval ##
% 13.09.2020, Ferhat Yılmaz

%% Description
%{
	Function which returns a vector describes given time interval
	as logical values in time vector. Limit times included.

>> Inputs:
	1. <startTime> : duration : Start time value
	2. <endTime> : duration : End time value
	3. <SAMPLE_PERIOD> : integer : Sample period in minutes
	4. <COUNT_SAMPLE_IN_DAY> : integer : Sample count in a day

<< Outputs:
	1. <logicalInterval> : vector : Logical vector describes elements located at interval
%}

%%
function logicalVector = logicalInterval(startTime, endTime, SAMPLE_PERIOD, COUNT_SAMPLE_IN_DAY)
	% Generate logical 0 vector
	logicalVector = false(1, COUNT_SAMPLE_IN_DAY);
	
	% Convert duration values to sample values
	startSample = duration2sample(startTime, '24h', SAMPLE_PERIOD);
	endSample = duration2sample(endTime, '24h', SAMPLE_PERIOD);
	
	% Check for the startTime is less than the endTime; otherwise there is overday case.
	if (startSample < endSample)
		logicalVector(startSample:endSample) = true;
	elseif (startTime > endTime)
		logicalVector([1:endSample startSample:end]) = true;
	else
		logicalVector = ~logicalVector;
	end
end
