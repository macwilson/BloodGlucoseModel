function [time_vec, Food, InsulinRate] = inputVector()
% Set the input signal for the system identification. This function can be
% altered to observe the impact of the input signal to the 

% Create the Time vector [minutes]
time_vec = 0:1:24*60;

% Create Food vector of zeros (no eating) and timeseries object
food_vec = zeros(size(time_vec));
Food = timeseries(food_vec,time_vec);

% Create Insulin Rate vector and timeseries object
insl_vec = ones(size(time_vec));
InsulinRate = timeseries(insl_vec,time_vec);
end