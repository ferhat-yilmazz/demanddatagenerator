 %% بسم الله الرحمن الرحیم 

%% ## Separate Appliances ##
% 18.08.2020, Ferhat Yılmaz

%% Description
%{
	Function to separate appliances as 'dependent appliances' and
	'independent' appliances.

>> Inputs:
	1. <applianceList> : cellArray : Appliances will be seperated
	2. <appliancesData> : structure . "appliancesData.json" config structure

<< Outputs:
	1. <independentAppliances> : cellArray : List of independent appliances
	2. <dependentAppliances> : cellArray : List of dependent appliances
%}

%%
function [independentAppliances, dependentAppliances] = separateAppliances(applianceList, appliancesData)
		% Dependent appliances vector:
		dependentVector = cellfun(@(x) appliancesData.(string(x)).dependency.case == 1, applianceList);
		% Dependent appliances
		dependentAppliances = applianceList(dependentVector);
		% Independent appliances
		independentAppliances = applianceList(~dependentVector);
end
