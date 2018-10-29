clearvars;

% prepare input signal
[time_vec, Food, InsulinRate] = inputVector();

pass_count = 0;
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
    [Tau, Kdc, eta, wn, LOCS, TF, IC] = sysID(patient);
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
    
    d = rmse_ref - rmse_id;
    x = [d, Kdc, Tau, eta, wn, LOCS];
    
    if d>0
        pass_count = pass_count + 1;
        disp(" ")
        disp(" ")
        disp("    Passed ID for ptnt #"+ i)
    else
        disp(" ")
        disp(" ")
        disp("    FAILED ID FOR PTNT #"+ i)
        
        plotSysId(time, patient_sugar_resp, ref_sugar_resp, id_sugar_resp, rmse_id, rmse_ref);
    end
    
    disp("    diff      Kdc       Tau       eta       wn        LOCS")
    disp(x)
    
end

disp(" ")
disp(" ")
disp(" ")
disp("DONE N TRIALS.")
disp("FINAL SUCCESS RATE %: "+ (pass_count/N)*100)
