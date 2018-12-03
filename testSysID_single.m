clearvars;

% prepare input signal
[time_vec, Food, InsulinRate] = inputVector();

% Generate a new random patient and simulate the open loop response of the
% generated patient
patient = genPatient();

% Simulate the actual patient, then interpolate since Simulink does not
% guarantee Sugar.Time will equal time_vec
Sugar = openLoopSim(patient,Food,InsulinRate);
sugar_vec = interp1(Sugar.Time,Sugar.Data,time_vec,'linear');

% Simulate the open loop response of the system id process
[TF,IC] = sysID(patient);
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

plotSysId(time, patient_sugar_resp, ref_sugar_resp, id_sugar_resp, rmse_id, rmse_ref);

% CALCULATE GRADE
%display(((rmse_ref - rmse_id)/rmse_ref )*100)
