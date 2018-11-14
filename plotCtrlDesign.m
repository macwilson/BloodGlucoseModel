function fig = plotCtrlDesign(time, patient_sugar_resp, steadystate_desired, dangerous)
    desired_matrix = [0 steadystate_desired(1) time(end) steadystate_desired(2)-steadystate_desired(1)];
    dangerous_matrix1 = [0 0 time(end) dangerous(1)];
    dangerous_matrix2 = [0 dangerous(2) time(end) 1000];

    %Plot our performance
    fig = figure;
    plot([0 0], [0 0], 'Color', [124 186 150]/255,'LineWidth',3);
    hold on;
    plot([0 0], [0 0], 'Color', [210 38 48]/255,'LineWidth',3);
    rectangle('Position', desired_matrix, 'FaceColor', [124 186 150]/255, 'EdgeColor', 'None');
    rectangle('Position', dangerous_matrix1, 'FaceColor', [210 38 48]/255, 'EdgeColor', 'None');
    rectangle('Position', dangerous_matrix2, 'FaceColor', [210 38 48]/255, 'EdgeColor', 'None');
    plot(time,patient_sugar_resp,'LineWidth',3);
    xlabel('Time [hr]','FontSize',20);
    ylabel('Glucose [mg/dl]','FontSize',20);
    leg = legend('Desired SS','Dangerous','Glucose');
    leg.FontSize = 16;
    ax = gca;
    ax.FontSize = 16;
    ax.FontWeight = 'bold';
    ylim([0 max(patient_sugar_resp)+1]);
    title('Glucose Response');
