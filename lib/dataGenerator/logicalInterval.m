 %% بسم الله الرحمن الرحیم 

%% ## Logical Representetion of Given Time Interval ##
% 13.09.2020, Ferhat Yılmaz

%% Description
%{
	Function to returns a vector which describes given time interval
	as logical values in TIME_VECTOR. Limit times included.

>> Inputs:
	1. <startTime> : duration : Start time value
	2. <endTime> : duration : End time value

<< Outputs:
	1. <logicalInterval> : vector : Logical vector describes elements located at interval
%}

%%
function logicalVector = logicalInterval(startTime, endTime)
	% Time vector
	global COUNT_SAMPLE_IN_DAY;
	
	% Generate logical 0 vector
	logicalVector = ~logical(1:COUNT_SAMPLE_IN_DAY);
	
	% Convert duration values to sample values
	startSample = duration2sample(startTime);
	endSample = duration2sample(endTime);
	
	% Check for the startTime is less than the endTime; otherwise there is overday case.
	if (startSample < endSample)
		logicalVector(startSample:endSample) = true;
	elseif (startTime > endTime)
		logicalVector([1:endSample startSample:end]) = true;
	else
		logicalVector = ~logicalVector;
	end
end
