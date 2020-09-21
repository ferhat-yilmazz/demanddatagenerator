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
	global TIME_VECTOR;
	
	% Check for the startTime is less than the endTime; otherwise there is overday case.
	if (startTime < endTime)
		logicalVector = (TIME_VECTOR >= startTime) & (TIME_VECTOR <= endTime);
	elseif (startTime > endTime)
		logicalVector1 = TIME_VECTOR >= startTime;
		logicalVector2 = TIME_VECTOR <= endTime;
		logicalVector = logicalVector1 | logicalVector2;
	else
		logicalVector = true(1, numel(TIME_VECTOR));
	end
end
