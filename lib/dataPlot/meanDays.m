% Determine means of given days
function meanArray = meanDays(endUsers, typeID)
  % Get data belong to the ned-user type
  typeData = endUsers([endUsers.typeID] == typeID);
  % Get size of dataStructure
  typeData_size = size(typeData, 2);
  
  % Define <meanVector>
  meanArray = zeros(7, size(typeData(1).totalUsage, 2));
  
  for day_idx = 1:7
    for row_idx = 1:typeData_size
      meanArray(day_idx, :) = meanArray(day_idx, :) + typeData(row_idx).totalUsage(day_idx, :);
    end
    % Transform to kW
    meanArray(day_idx, :) = meanArray(day_idx, :) ./ 1000;
    meanArray(day_idx, :) = meanArray(day_idx, :) ./ typeData_size;
  end
end
