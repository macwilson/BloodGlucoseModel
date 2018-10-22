function fig = plotSysId(time, patient_sugar_resp, ref_sugar_resp, id_sugar_resp, rmse_id, rmse_ref)
fig = figure;

plot(time,patient_sugar_resp,'LineWidth',3,'DisplayName','Patient');
hold on
plot(time,ref_sugar_resp,'LineWidth',3,'DisplayName',['Ref, RMSE = ' num2str(rmse_ref) ' mg/dl']);
plot(time,id_sugar_resp,'LineWidth',3,'DisplayName',['ID , RMSE = ' num2str(rmse_id) ' mg/dl']);
ax = gca;
ax.FontSize = 16;
ax.FontWeight = 'Bold';
xlabel('Time [hr]','FontSize',20);
ylabel('Glucose [mg/dl]','FontSize',20);
title({'Glucose Response to Step Rate Input'});
legend('show');
ylim([40 180]);