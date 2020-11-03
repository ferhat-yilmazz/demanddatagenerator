 %% بسم الله الرحمن الرحیم 

%% ## Reset Daily Usage Counter and Weekly Usage Counter ##
% 12.10.2020, Ferhat Yılmaz

%% Description
%{
	Function to reset "appliance daily usage counter (duc)" and
	"appliance weekly usage counter (wuc)" optionally.  

>> Inputs:
	1. <endUser>: structure : A structure which describes the end-user
	2. <option> : string : "duc" or "wuc" to reset (make zero)

<< Outputs:
	1. <endUser>: structure : A structure which describes the end-user
%}

%%
function endUser = resetApplianceUsageCounter(endUser, option)
	% Get appliances list
	appliances = fieldnames(endUser.appliances);
	
	% If the appliance is periodic and continuous, pass it. <duc> and <wuc> are disabled for this
	% type appliances
	
	switch option
		case 'duc'
			for appliance_index = 1:numel(appliances)
				if isfield(endUser.appliances.(string(appliances(appliance_index))), 'duc')
					endUser.appliances.(string(appliances(appliance_index))).duc = uint16(0);
				end
			end
		case 'wuc'
			for appliance_index = 1:numel(appliances)
				if isfield(endUser.appliances.(string(appliances(appliance_index))), 'wuc')
					endUser.appliances.(string(appliances(appliance_index))).wuc = uint16(0);
				end
			end
		otherwise
			error('Undefined option given!!');
	end
end
