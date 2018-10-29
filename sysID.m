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

% Here are some potentially useful functions:
% - findpeak
% - min/max

%Find the peaks in the data, this is when the slope changes sign
[PKS,LOCS] = findpeaks(-sugar_vec,time_vec);

IC = sugar_vec(1);
FV  = sugar_vec(end); % pseudo-steady-state value
Kdc = (FV-IC);


if length(LOCS)<2
    TF = TF1;
    Tau_y_val = FV + Kdc*0.37;

    [val, index] = min(abs(sugar_vec - Tau_y_val));
    Tau = time_vec(index)/60;

    s = tf('s');
    TF = Kdc/(Tau*s + 1);
    
else
    %% our trial code
    
    % find the first order system
    Tau_y_val = FV + Kdc*0.25;

    [val, index] = min(abs(sugar_vec - Tau_y_val));
    Tau = time_vec(index)/60;

    s = tf('s');
    TF1 = Kdc/(Tau*s + 1);
    
    % find the second order system values
    data = stepinfo(sugar_vec, time_vec);
    Tp = LOCS(1);
    Ts = data.SettlingTime; 
    %z = 220;
    eta = sqrt((3.9*Tp)^2/((Ts*pi)^2 + (3.9*Tp)^2))
    wn = 3.9/(eta*Ts)
    %p = 320;
    s = tf('s');
    TF2 = (wn^2)/(s^2+ 2*eta*wn*s + wn^2);
    
    TF = TF1*TF2;
end

end