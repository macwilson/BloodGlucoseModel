% testSysID_Npatients.m 
% Run sysID.m on N number of patients (N is set by
% user) for a variety of Tau values. Get average performance.

clearvars;

% prepare input signal
[time_vec, Food, InsulinRate] = inputVector();

pass_count = 0;
N = 30;
Taus = 0.2:0.05:0.5;
differences = zeros(length(Taus), N);

for i = 1:N
    % Generate a new random patient and simulate the open loop response of the
    % generated patient
    patient = genPatient();
    
    for j = 1:length(Taus)
        
        % Simulate the actual patient, then interpolate since Simulink does not
        % guarantee Sugar.Time will equal time_vec
        Sugar = openLoopSim(patient,Food,InsulinRate);
        sugar_vec = interp1(Sugar.Time,Sugar.Data,time_vec,'linear');

        % Simulate the open loop response of the system id process
        [TF, IC] = sysID(patient, Taus(j));
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
        d = rmse_ref - rmse_id;
        differences(j, i) = d;

    end
    
    
end

% print final performance stat.
disp("DONE");
for i = 1:length(Taus)
    disp(" ")
    disp("Tau = " + Taus(i, 1));
    disp("# fails = " + sum(Taus(i,2:end) > 0));
end
