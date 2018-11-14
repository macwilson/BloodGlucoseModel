function [time_vec, Food] = inputVector_fasting()
%Create time vector, assume 0 is when patient starts eating breakfast
time_vec = 0:1:24*60;

%Create food input disturbance but for now leave at zero, as if the patient
%is fasting for 24 hours.
food_vec = zeros(size(time_vec));
%Create a valid timeseries object that simulink model will take from
%workspace
Food = timeseries(food_vec,time_vec);
end