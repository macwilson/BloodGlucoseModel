steadystate_desired(1) = 3.5*18; % convert mmol/l to mg/dl 
steadystate_desired(2) = 7*18; % convert mmol/l to mg/dl 
peak_dangerous(1) = 2.2*18; % convert mmol/l to mg/dl 
peak_dangerous(2) = 16.6*18; % convert mmol/l to mg/dl 

%Generate a patient
patient = genPatient();

% comment whichever appropriate one as needed 
%[time_vec, food] = foodVector_fasting(); % simulate fasting response
[time_vec, food] = foodVector_3meals(); % simulate 3 meals

%Create a Controller
Controller = ctrlDesign(patient, time_vec, food);

%Simulate closed loop system
Sugar = closedLoopSim(patient,food,Controller);

time = Sugar.Time/60;
patient_sugar_resp = Sugar.Data(:);

%Analyze performance
time_success = length(patient_sugar_resp) - sum(patient_sugar_resp > steadystate_desired(2)) - sum(patient_sugar_resp < steadystate_desired(1));
patient_dead = sum(patient_sugar_resp >= peak_dangerous(2)) > 0 || sum(patient_sugar_resp <= peak_dangerous(1)) > 0;
if patient_dead grade = 0
else
    grade = min(100,((time_success/(length(patient_sugar_resp)*20/24))*100))
end


%Plot results
fig = plotCtrlDesign(time, patient_sugar_resp, steadystate_desired, peak_dangerous);