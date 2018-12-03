% testSysID_Npatients.m 
% Run sysID.m on N number of patients (N is set by
% user). For each patient, print out literally all parameters used in
% sysID.m For failed patients, show the plot. Gives a final performance as
% percent (failed/total).

clearvars;

% prepare input signal
[time_vec, Food, InsulinRate] = inputVector();

grade_sum = 0;
rmse_id_sum = 0;
rmse_ref_sum = 0;
N = 50;

for i = 1:N
    % Generate a new random patient and simulate the open loop response of the
    % generated patient
    patient = genPatient();

    % Simulate the actual patient, then interpolate since Simulink does not
    % guarantee Sugar.Time will equal time_vec
    Sugar = openLoopSim(patient,Food,InsulinRate);
    sugar_vec = interp1(Sugar.Time,Sugar.Data,time_vec,'linear');

    % Simulate the open loop response of the system id process
    [TF, IC] = sysID(patient);
    Y = step(TF,time_vec);
    id_resp = Y+IC;

    % Simulate the reference system
    [TF_ref, IC_ref] = referenceID(patient);
    Y_ref = step(TF_ref,time_vec);
    ref_resp = Y_ref+IC_ref;

    % Preparing the data for plotting
    time = time_vec/60; % convert to hours
    patient_sugar_resp = sugar_vec(:);
    id_sugar_resp = id_resp(:);
    ref_sugar_resp = ref_resp(:);

    % Set up anon function for RMSE calculation
    rmseFct = @(x, y) sqrt(sum((normVector(x - y)).^2)/(size(x, 1)));
    rmse_id = rmseFct(patient_sugar_resp, id_sugar_resp);
    rmse_ref = rmseFct(patient_sugar_resp, ref_sugar_resp);
    
    % Record sysID error and all gathered parameters.
    
    disp("TRIAL "+ i)
    
    grade = (rmse_ref - rmse_id)/rmse_ref ;
    if grade<0 
        grade=0;
        plotSysId(time, patient_sugar_resp, ref_sugar_resp, id_sugar_resp, rmse_id, rmse_ref);
        
    end
    
    grade_sum = grade_sum + grade;
    rmse_ref_sum = rmse_ref_sum + rmse_ref;
    rmse_id_sum = rmse_id_sum + rmse_id;
    disp("rmse ref " + rmse_ref)
    disp("rmse id " + rmse_id)
    disp("Grade: " + grade*100)
    disp("")

end

% print final performance stat.
disp(" ")
disp(" ")
disp(" ")
disp("DONE N TRIALS.")
disp("FINAL AVERAGE GRADE: %"+ (grade_sum/N)*100)
disp("Average sysID RMSE: " + (rmse_id_sum/N))
disp("Average refID RMSE: " + (rmse_ref_sum/N))
