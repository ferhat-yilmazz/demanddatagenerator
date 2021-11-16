 %% بسم الله الرحمن الرحیم 

%% ## Filter Data to Use In <errorPercent> ##
% 17.10.2021, Ferhat Yılmaz

%% Description
%{
	Function to filter generated data according to selected residental type
  and selected appliance name. Filtered data must only contain the total
  usage cycle (tuc) values of the selected appliance belongs to the each
  related residental type.

>> Inputs:
	1. <generatedData>    : structure : Generated data by te program
	2. <residentalTypeID> : integer   : ID of the selected residental type
	3. <applianceName>    : string    : Name of the selected appliance

<< Outputs:
	1. <tucData>          : array     : Filtered data
%}

%%
function tucData = dataFilter(generatedData, residentalTypeID, applianceName)
  % Filter <generatedData> according to <residentalTypeID>
  subStruct = generatedData([generatedData.typeID] == residentalTypeID);
  
  % Filter <subStruct> according to <applianceName>
  tucData = zeros(numel(subStruct),1);
  for i = 1:numel(subStruct)
    if sum([subStruct(i).appliances.applianceName] == applianceName)
      tucData(i) = subStruct(i).appliances([subStruct(i).appliances.applianceName] == applianceName).tuc;
    else
      tucData(i) = -1;
    end
  end
  
  % Truncate <tucData>
  tucData(tucData == -1) = [];
end
