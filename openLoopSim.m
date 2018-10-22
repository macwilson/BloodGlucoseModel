function Sugar = openLoopSim(patient,Food,InsulinRate)
%This function programatically simulates the PatientModelOL_DL system. 
%It opens the model, assigns the patient parameters as well as the inputs
%and runs the simulation.

modelFileName = 'PatientModelOL_DL'; % local mode
% modelFileName = 'PatientModelOL'; % Grader mode

if ~isa(Food,'timeseries') || ~isa(InsulinRate,'timeseries')
    str = sprintf(['Food and InsulinRate inputs must be timeseries objects,' ...
        ' time is represented in minutes. \n Example Usage: 24 hour response to constant insulin rate and no food' ...
        '\n \t\t\t\t %% Create 24 hour time vector' ...
        '\n \t\t\t\t time_vec = [0:1:24*60]' ... 
        '\n \t\t\t\t %% Create Food vector of zeros (no eating)' ...
        '\n \t\t\t\t food_vec = zeros(size(time_vec))'...
        '\n \t\t\t\t %% Create Food timeseries object'...
        '\n \t\t\t\t Food = timeseries(food_vec,time_vec)'...
        '\n \t\t\t\t %% Create Insulin Rate vector' ...
        '\n \t\t\t\t insl_vec = ones(size(time_vec))'...
        '\n \t\t\t\t %% Create InsulinRate timeseries object'...
        '\n \t\t\t\t InsulinRate = timeseries(insl_vec,time_vec)'...
        '\n \t\t\t\t %% Simulate Open Loop Response'...
        '\n \t\t\t\t Sugar = openLoopSim(patient,Food,InsulinRate)']);
   error(str);
end

if numel(patient)~=20
   error('Patient must be a vector of length 20 created by genPatient()'); 
end

%Opent Open Loop Patient Model
open_system(modelFileName);
%Get workspace
mdlWks = get_param(modelFileName,'ModelWorkspace');
%Assign variables to model workspace
%Works in 2018a
params = mdlWks.getVariable('params');
params.Value(1:numel(patient)) = patient;
mdlWks.assignin('params',params);
%Works in 2018b
%setVariablePart(mdlWks,'params.Value', patient);
ds = Simulink.SimulationData.Dataset;
ds{1} = Food;
ds{2} = InsulinRate;
in = Simulink.SimulationInput(modelFileName);
in = in.setExternalInput(ds);
out = sim(in);
Sugar = out.yout{1}.Values;

end