for i=1:5
    clearvars;
    disp("Patient Number: #"+ i)
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
    %[TF,IC] = sysID(patient);
    [Tau_vec, Kdc, cmb_odr_TF_vec, LOCS, IC] = sysID(patient);
    for j=1:2:length(cmb_odr_TF_vec)
        %Y = step(TF,time_vec);
        Y = step(cmb_odr_TF_vec(j), time_vec);
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

        %if rmse_ref < rmse_id
        %plotSysId(time, patient_sugar_resp, ref_sugar_resp, id_sugar_resp, rmse_id, rmse_ref);
        %end
        if rmse_ref < rmse_id
            disp("Failed");
        else
            disp("Passed");
        end
        x = ["TAU%: ", cmb_odr_TF_vec(j+1), "RMSE_REF: ", rmse_ref, "RMSE_ID: ", rmse_id];
        disp(x)
    end
end