function Sugar = closedLoopSim(patient,Food,Controller)

if ~isa(Food,'timeseries')
    str = ['Food must be a timeseries object'];
    error(str);
end

if ~isa(Controller,'tf')
    str = ['Controller must be a valid transfer function'];
    error(str);
end

if numel(patient)~=20
   error('Patient must be a vector of length 20 created by genPatient()'); 
end

%Opent Closed Loop Patient Model
open_system('PatientModelCL');

%Get workspace
mdlWks = get_param('PatientModelCL','ModelWorkspace');
%Assign variables to model workspace
params = mdlWks.getVariable('params');
params.Value(1:numel(patient)) = patient;
mdlWks.assignin('params',params);
C = mdlWks.getVariable('C');
mdlWks.assignin('C',Controller);

%Assign inputs
ds = Simulink.SimulationData.Dataset;
ds{1} = Food;
in = Simulink.SimulationInput('PatientModelCL');
in = in.setExternalInput(ds);
out = sim(in);
Sugar = out.yout{1}.Values;

end