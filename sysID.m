function [TF, IC] = sysID(patient)
% Use this template to design an open-loop system identification routine given
% the step time response of the patient. 

% http://ctms.engin.umich.edu/CTMS/index.php?example=Introduction&section=SystemAnalysis
% https://link.springer.com/content/pdf/10.1007%2F978-1-4612-1768-8.pdf

%% input response
% The input response is loaded here and used to simulate the patient to produce 
% the step response. Feel free to alter this section as needed to try different
% types of inputs that may help with the identification process
[time_vec, Food, InsulinRate] = inputVector();

% Simulate the open loop response of the generated patient
Sugar = openLoopSim(patient,Food,InsulinRate);

% Get Sugar values at time_vec time. This is basic linear interpolation and
% is nessesary because Simulink does not guarantee Sugar.Time will equal time_vec
sugar_vec = interp1(Sugar.Time,Sugar.Data,time_vec,'linear');

%% system identification
[PKS ,LOCS] = findpeaks(-sugar_vec,time_vec);

IC = sugar_vec(1);
FV  = sugar_vec(end); % pseudo-steady-state value
Kdc = (FV-IC);
Tau_y_val = FV + Kdc*0.37;
[val , index] = min(abs(sugar_vec - Tau_y_val));
Tau = time_vec(index)/6;
    
if (length(LOCS)>0) % USE HIGHER ORDER APPROXIMATION COMPONENTS
    % Find the second order system values
    data = stepinfo(sugar_vec, time_vec);
    Tp = LOCS(1);
    Ts = data.SettlingTime; 
    eta = sqrt((3.9*Tp)^2/((Ts*pi)^2 + (3.9*Tp)^2));
    wn = 3.9/(eta*Ts);
    s = tf('s');
    TF1 = (Kdc*wn^2)/(s^2+ 2*eta*wn*s + wn^2); % to average later
    
    % Subtract the previous model from the patient, and model residual
    [y,t] = step(TF1, time_vec/60);
    residual = sugar_vec - y(1);
    
    IC = residual(1);
    FV  = residual(end); % pseudo-steady-state value
    Kdc = (FV-IC);
    
    % Model the residual with another second order component
    data = stepinfo(residual, time_vec);
    Tp = LOCS(1);
    Ts = data.SettlingTime; 
    eta = sqrt((3.9*Tp)^2/((Ts*pi)^2 + (3.9*Tp)^2));
    wn = 3.9/(eta*Ts);
    s = tf('s');
    TF2 = (Kdc*wn^2)/(s^2+ 2*eta*wn*s + wn^2); % to average later

    TF3 = (TF1+TF2)/2; % just to sim step response

    % Find remaining residual, and model with first order component
    [y,t] = step(TF3, time_vec/60);
    residual2 = residual - y(1);
    
    IC = residual2(1);
    FV  = residual2(end); % pseudo-steady-state value
    Kdc = (FV-IC);
    Tau_y_val = FV + Kdc*0.37;
    
    [val , index] = min(abs(residual2 - Tau_y_val));
    Tau = time_vec(index)/6;
    % sometimes Tau and K are just not working, so fix them 
    if (Tau < 150) && (abs(Kdc) <55)
        Tau = 190;
    end
    s = tf('s');
    TF4 = Kdc/(Tau*s + 1); % to average later
    
    TF5 = (TF1+TF2+TF4)/3; % just to simulate step response
    
    % Find remaining residual and model with another FO-comp
    [y,t] = step(TF5, time_vec/60);
    residual3 = residual2 - y(1);
    
    IC = residual3(1);
    FV  = residual3(end); % pseudo-steady-state value
    Kdc = (FV-IC);
    Tau_y_val = FV + Kdc*0.37;
    
    [val , index] = min(abs(residual3 - Tau_y_val));
    Tau = time_vec(index)/6;
    % check tau
    if (Tau < 150) && (abs(Kdc) <55)
        Tau = 190;
    end
    s = tf('s');
    TF6 = Kdc/(Tau*s + 1); % to average
    
    TF7 = (TF1+TF2+TF4+TF6)/4; % to simulate

    % Find remaining residual and model again with FO-comp
    [y,t] = step(TF7, time_vec/60);
    residual4 = residual3 - y(1);
    
    IC = residual4(1);
    FV  = residual4(end); % pseudo-steady-state value
    Kdc = (FV-IC);
    Tau_y_val = FV + Kdc*0.37;
    
    [val , index] = min(abs(residual4 - Tau_y_val));
    Tau = time_vec(index)/6;
    % check tau
    if (Tau < 150) && (abs(Kdc) <55)
        Tau = 190;
    end
    s = tf('s');
    TF8 = Kdc/(Tau*s + 1); % to average
    
    TF = (TF1+TF2+TF4+TF6+TF8)/5; % final transfer function
    % combinned as if they are all partial fractions
    % division by 5 is to make gain the expected value
    
    
else % System is best approximated by only first-order components
    % Transfer function 1
    s = tf('s');
    TF1 = Kdc/(Tau*s + 1);
    
    % Find residual not modelled by TF1
    [y,t] = step(TF1, time_vec/60);
    residual = sugar_vec - y(1);
    
    IC = residual(1);
    FV  = residual(end); % pseudo-steady-state value
    Kdc = (FV-IC);
    Tau_y_val = FV + Kdc*0.37;
    
    % Find first order approximation of residual 
    [val , index] = min(abs(residual - Tau_y_val));
    Tau = time_vec(index)/6;
    s = tf('s');
    % Second transfer function
    TF2 = Kdc/(Tau*s + 1);
    
    % Average them as if they were partial fractions
    TF = (TF1+TF2)/2;
end


end