function f1=get_regression(output,runs,runname)

    run_count=numel(runs);
    

    exec_plot='';
    for i=1:run_count
       c=runs(i);
       [m n]=size(output{c}.NN_output.testing_outputs_as_matrix_beschnitten);
       for k=1:m
           selected_test_net_prediction_as_sequence{c,k}=output{c}.NN_output.test_net_prediction_as_sequence(k,:);
           selected_testing_outputs_as_matrix_beschnitten{c,k}=output{c}.NN_output.testing_outputs_as_matrix_beschnitten(k,:);
           exec_plot=[exec_plot, 'selected_testing_outputs_as_matrix_beschnitten{',num2str(c),',',num2str(k),'},selected_test_net_prediction_as_sequence{',num2str(c),',',num2str(k),'}, ''RUN',num2str(c),'-',num2str(k),''','];
       end 
    end
    
    exec_plot=['f1=plotregression(',exec_plot(1:end-1),');'];
    f1=figure;
    eval(exec_plot);
    set(f1,'name',['Regression ', runname],'NumberTitle','off');
    
        
    for i=1:run_count
        c=runs(i);
    
        
        testing_outputs_as_matrix_beschnitten=output{c}.NN_output.testing_outputs_as_matrix_beschnitten';
        test_net_prediction_as_sequence=output{c}.NN_output.test_net_prediction_as_sequence';

%         testing_outputs_as_matrix_beschnitten=testing_outputs_as_matrix_beschnitten(:,[2 3]);
%         selected_testing_outputs_as_matrix_beschnitten_all=selected_testing_outputs_as_matrix_beschnitten_all(:,[2 3]);
% 
%         testing_outputs_as_matrix_beschnitten_shift=testing_outputs_as_matrix_beschnitten;
%         testing_outputs_as_matrix_beschnitten_shift(:,1)=testing_outputs_as_matrix_beschnitten_shift(:,1)+1;
% 
%         selected_testing_outputs_as_matrix_beschnitten_all_shift=selected_testing_outputs_as_matrix_beschnittenp_all;
%         selected_testing_outputs_as_matrix_beschnitten_all_shift(:,1)=selected_testing_outputs_as_matrix_beschnitten_all_shift(:,1)+1;


    
        figure;
        plotregression(std_vector(testing_outputs_as_matrix_beschnitten,test_net_prediction_as_sequence),std_vector(test_net_prediction_as_sequence,testing_outputs_as_matrix_beschnitten),['NN ',num2str(c),' - fit'])
        
    
    end


end