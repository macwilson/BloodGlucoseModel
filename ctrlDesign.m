function Controller = ctrlDesign(patient, time_vec, Food)
% Use this template to design an close-loop system controller to stablize the 
% patient sugar response

%% system identification (open loop sim)
% The input response is loaded here and used to simulate the patient to produce 
% the step response. Feel free to alter this section as needed to try different
% types of inputs that may help with the identification process
[TF,IC] = sysID(patient); % REPLACE THIS FUNCTION (AT THE BOTTOM) WITH YOURS

%% system identification (close loop sim)
% Simulate the open loop response of the generated patient
Controller = tf(0); % setting a null controller to get the closed loop response without a controller
Sugar_closeloop = closedLoopSim(patient,Food,Controller);

% Get Sugar values at time_vec time. This is basic linear interpolation and
% is nessesary because Simulink does not guarantee Sugar.Time will equal time_vec
sugar_vec_closeloop = interp1(Sugar_closeloop.Time,Sugar_closeloop.Data,time_vec,'linear');

%% controller design
s = tf('s');
%Controller = tf(-0.8/(s+2));
Ki = -0.005;
Kp = -0.5;
Kd = -7;
Controller = Kp + Ki/s  + (Kd*s)/(0.01*s+1)

end

function [TF, IC] = sysID(patient) % update this function as appropriate
%% input response
[time_vec, Food, InsulinRate] = inputVector();
Sugar = openLoopSim(patient,Food,InsulinRate);
sugar_vec = interp1(Sugar.Time,Sugar.Data,time_vec,'linear');

%% system identification

%Find the peaks in the data, this is when the slope changes sign
[PKS ,LOCS] = findpeaks(-sugar_vec,time_vec);

IC = sugar_vec(1);
FV  = sugar_vec(end); % pseudo-steady-state value
Kdc = (FV-IC);
Tau_y_val = FV + Kdc*0.37;
[val , index] = min(abs(sugar_vec - Tau_y_val));
Tau = time_vec(index)/6;

%% If too few oscillations just use first order 
if (length(LOCS)<2) 
    s = tf('s');
    TF = Kdc/(Tau*s + 1);


else
    %% Second order system
    
    % If tau and gain are funky, the model will undershoot too much on its
    % first oscillation. Bump Tau to a higher value to avoid this. 
    if (Tau < 150) && (abs(Kdc) <55)
        Tau = 190;
    end
    
    s = tf('s');
    TF1 = Kdc/(Tau*s + 1);
    
    % find the second order system values
    data = stepinfo(sugar_vec, time_vec);
    Tp = LOCS(1);
    Ts = data.SettlingTime; 
    eta = sqrt((3.9*Tp)^2/((Ts*pi)^2 + (3.9*Tp)^2));
    wn = 3.9/(eta*Ts);
    s = tf('s');
    TF2 = (Kdc*wn^2)/(s^2+ 2*eta*wn*s + wn^2);
    
    % average for final TF
    TF = (TF2+TF1)*0.5;
end
end