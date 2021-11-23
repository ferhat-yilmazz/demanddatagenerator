 %% بسم الله الرحمن الرحیم 

%% ## Calculate Error Rate Generated&Real Data ##
% 17.10.2021, Ferhat Yılmaz

%% Description
%{
	Function to determine rate of error between generated data and
  real data. Residental type and appliance name will be given as
  parameters. Then the function calculate error rate the related
  type and the related appliance.

>> Inputs:
	1. <applianceData>    : structure : "appliancesData.json" configuration file structure
	2. <residentalData>   : structure : "residentalTypes.json" configuration file structure
	3. <tucdata>          : structure : Filtered generated data

<< Outputs:
	1. <resultArray>      : array     : [<realWeeklyUsage>, <generatedWeeklyMeanUsage>, <errorPercent>]
%}

%%

function resultArray = errorPercent(applianceRealUsageData, residentalData, tucData, SAMPLE_PERIOD)
  % ########### DETERMINE REAL WEEKLY USAGE VALUE ###############
  % #############################################################
  % Get real usage value of the appliance in minutes for the end-user type (weekly usage)
	residentalType_personCount = residentalData.nonemployedCount + residentalData.employedCount;
	
	% Determine real weekly usage value
	remainedPerson = residentalType_personCount - applianceRealUsageData.personCount;
	if remainedPerson > 0
		realWeeklyUsageInMinute = minutes(timeVector2duration(applianceRealUsageData.value, SAMPLE_PERIOD, 'inf'));
		% Add duration for each remained person
		realWeeklyUsageInMinute = double(realWeeklyUsageInMinute +...
		 (remainedPerson * (minutes(timeVector2duration(applianceRealUsageData.additionEachPerson, SAMPLE_PERIOD, 'inf')))));
	elseif remainedPerson == 0
			realWeeklyUsageInMinute = double(minutes(timeVector2duration(applianceRealUsageData.value, SAMPLE_PERIOD, 'inf')));
	elseif remainedPerson < 0
		realWeeklyUsageInMinute = double((residentalType_personCount/applianceRealUsageData.personCount) *...
																			 minutes(timeVector2duration(applianceRealUsageData.value, SAMPLE_PERIOD, 'inf')));
  end
  
  % ########### DETERMINE GENERATED WEEKLY USAGE MEAN VALUE ###############
  % #######################################################################
  generatedWeeklyMeanUsageInMinute = mean(tucData) * SAMPLE_PERIOD;
  
  % ########### RESULT ###############
  % ##################################
  resultArray = [single(realWeeklyUsageInMinute), single(generatedWeeklyMeanUsageInMinute),...
                 single(abs(((realWeeklyUsageInMinute - generatedWeeklyMeanUsageInMinute) / realWeeklyUsageInMinute) * 100))];
end


