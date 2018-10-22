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
[PKS,LOCS] = findpeaks(sugar_vec,time_vec);

%Find the min and max 
min_val = min(sugar_vec);
max_val = max(sugar_vec);

%% our trial code
%We know this system is:
%   - 2nd order
%   - Under-damped + stable
%   - Decaying oscillations
%   - Negative gain
%   - a^2 < 4b, eta > 1
Tp = LOCS(1);
Ts = 770;
eta = sqrt((16*Tp^2)/((Ts*pi)^2 + (4*Tp)^2));
wn = 4/(eta*Ts);
s = tf('s');
Kdc = -100;
b = wn^2;
a = 2*eta*wn;
TF = Kdc*b/(s^2+ a*s + b);
IC = sugar_vec(1);
end