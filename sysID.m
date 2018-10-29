function [Tau, Kdc, eta, wn, LOCS, TF, IC] = sysID(patient)
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

%Find the peaks in the data, this is when the slope changes sign
[PKS ,LOCS] = findpeaks(-sugar_vec,time_vec);

IC = sugar_vec(1);
FV  = sugar_vec(end); % pseudo-steady-state value
Kdc = (FV-IC);
Tau_y_val = FV + Kdc*0.37;
[val , index] = min(abs(sugar_vec - Tau_y_val));
Tau = time_vec(index)/6;

% If too few oscillations or funky gain/tau, just use first order 
if (length(LOCS)<2) 
    s = tf('s');
    TF = Kdc/(Tau*s + 1);
    eta = 0;
    wn = 0;


    
else
    %% our trial code

    % first order system
    
    % If tau and gain are funky, the model will fail so bump them
    if (Tau < 149) && (abs(Kdc) <53)
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