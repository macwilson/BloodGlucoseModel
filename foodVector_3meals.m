function [time_vec, Food] = inputVector_3meals()
%Now lets see what happens if a patient eats 3 times a day
time_vec = 0:1:24*60;

%Create food input disturbance but for now leave at zero, as if the patient
%is fasting for 24 hours.
food_vec = zeros(size(time_vec));
%Patient eats 30grams of sugar with breakfast in 30 minutes
food_vec(1:20) = 50/30*0.001;
%Patient eats 50grams of sugar with lunch in 30 minutes, 4 hours after
%breakfast
food_vec(4*60:4*60+30) = 50/30*0.001;
%Patient eats 50grams of sugar with dinner in 30 minutes, 9 hours after
%breakfast
food_vec(9*60:9*60+30) = 50/30*0.001;
%Create a valid timeseries object that simulink model will take from
%workspace
Food = timeseries(food_vec,time_vec);
end