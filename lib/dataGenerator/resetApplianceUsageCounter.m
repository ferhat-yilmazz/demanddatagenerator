 %% بسم الله الرحمن الرحیم 

%% ## Reset Daily Usage Counter and Weekly Usage Counter ##
% 12.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to reset "appliance daily usage counter (duc)" and
	"appliance weekly usage counter (wuc)" optionally.  

>> Inputs:
	1. <endUserAppliances>: structure : A structure of appliances belong to the end-user
	2. <option> : string : "duc" or "wuc" to reset (make zero)

<< Outputs:
	1. <endUserAppliances>: structure : A structure of appliances belong to the end-user
%}

%%
function endUserAppliances = resetApplianceUsageCounter(endUserAppliances, option)
	% Get count of appliances
	appliancesCount = size(endUserAppliances, 2);
	
	switch option
		case 'duc'
			for appliance_index = 1:appliancesCount
				endUserAppliances(appliance_index).duc = single(0);
			end
		case 'wuc'
			for appliance_index = 1:appliancesCount
				endUserAppliances(appliance_index).wuc = single(0);
			end
		otherwise
			error('Undefined option given!!');
	end
end
