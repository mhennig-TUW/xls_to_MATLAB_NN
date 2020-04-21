function [output_struct] = f_NN(data,input_struct, data_structure_flag)
%Mit data_structure_falg wird entschieben ob im Training die Cluster
%Batch-weise oder als aneinanderreihung von Segmenten oder als durchgehende
%Zeitreihe jedoch mit einem zusätzlichen Clusterinfo Metakanal antrainiert
%werden soll
tic;
    v2struct(input_struct);
    
    if nargin<=2
        data_structure_flag='segmented';
    end
    
%load magdata
    %y = con2seq(y);
    %u = con2seq(u);

    %clear all;
    %load('dataTU_korr_glatt.mat');
    %data=dataTU_korr;


    %d1 = [1,2,3,4,5];              % Time delay for input ->Input Delays
    %d2 = [1,2,3,4,5];              % Time delay for output ->Feedback Delays
    %input_taglist=[2,28,35,4,19,36,38];
    %output_taglist=[8];
    %n1=(numel(input_taglist)+numel(output_taglist))*3;
    %n2=(numel(input_taglist)+numel(output_taglist))*1;
    %n=[n1,n2];                                % anzahl der hidden neurons/layer
    %max_fail                       %Maximum validation failures
    %training_intervall=[12000:32000];
    %testing_intervall=[1:12000];
    %y_num=1;                       %number of output_taglist to plot
    %trainFcn='trainbr'
    %epochs=50
    
    %(plot)yp predictions
    %(plot)y targets
    %(plot)diff_all Unterschied in Prozent

    if isnan(y_num)
        y_num=1;
    end
    
    
    d1_max=0;
    
    switch data_structure_flag
        case 'batch'
            stride=size(training_intervall,2); %Länge einer Batch Komponente
            %eine Zeile der Batch hat 3 Teile [train valid test] die alle stride lang sind. 
            if ~isnan(max_fail)  %Baut den Datenvektor aus den [train valid test] Abschnitten auf. mit einer Zeile pro Input bzw Output
                inputs_as_cells = cell(max([size(training_intervall,1), size(validation_intervall,1), size(testing_intervall,1)]) , stride * 3); %Inputs
                outputs_as_cells = cell(max([size(training_intervall,1), size(validation_intervall,1), size(testing_intervall,1)]) , stride * 3); %outputs
                testing_inputs = cell(size(testing_intervall,1) , stride );
                testing_outputs = cell(size(testing_intervall,1) , stride );
                
                for i=1:size(training_intervall,1), inputs_as_cells(i,1:stride) = con2seq(data(training_intervall(i,:),input_taglist)');  end
                for i=1:size(validation_intervall,1), inputs_as_cells(i,stride+1:stride*2) = con2seq(data(validation_intervall(i,:),input_taglist)');  end
                for i=1:size(testing_intervall,1), inputs_as_cells(i,stride*2+1:end) = con2seq(data(testing_intervall(i,:),input_taglist)');  end
                
                for i=1:size(testing_intervall,1), testing_inputs(i,1:stride) = con2seq(data(testing_intervall(i,:),input_taglist)');  end
                
                for i=1:size(training_intervall,1), outputs_as_cells(i,1:stride) = con2seq(data(training_intervall(i,:),output_taglist)');  end
                for i=1:size(validation_intervall,1), outputs_as_cells(i,stride+1:stride*2) = con2seq(data(validation_intervall(i,:),output_taglist)');  end
                for i=1:size(testing_intervall,1), outputs_as_cells(i,stride*2+1:end) = con2seq(data(testing_intervall(i,:),output_taglist)');  end
                
                for i=1:size(testing_intervall,1), testing_outputs(i,1:stride) = con2seq(data(testing_intervall(i,:),output_taglist)');  end
                temp = {NaN()};
                for i=1:max(size(inputs_as_cells{1,1}))-1, temp=[temp; NaN()]; end %Da ein NaN für jede Input Dimension gebraucht wird
                for i=find(cellfun(@isempty,inputs_as_cells))', inputs_as_cells{i} = cell2mat(temp); end
                temp = {NaN()};
                for i=1:max(size(outputs_as_cells{1,1}))-1, temp=[temp; NaN()]; end %Da ein NaN für jede Input Dimension gebraucht wird
                for i=find(cellfun(@isempty,outputs_as_cells))', outputs_as_cells{i} = cell2mat(temp); end
                %inputs_as_cells(find(cellfun(@isempty,inputs_as_cells))) = temp; %weil nicht alle Blöcke gleich viele Zeilen haben
                %outputs_as_cells(find(cellfun(@isempty,outputs_as_cells))) = temp; %~ DIMENSIONEN MÜSSEN TROTZDEM EINGEHALTEN WERDEN
                inputs_as_nested_cells = catsamples(inputs_as_cells(1,:));
                outputs_as_nested_cells = catsamples(outputs_as_cells(1,:));
                for i=2:max([size(training_intervall,1), size(validation_intervall,1), size(testing_intervall,1)])
                    outputs_as_nested_cells=catsamples(outputs_as_nested_cells, outputs_as_cells(i,:));
                    inputs_as_nested_cells=catsamples(inputs_as_nested_cells, inputs_as_cells(i,:));
                end
                
                testing_inputs_as_matrix = catsamples(testing_inputs(1,:));
                testing_outputs_as_matrix = catsamples(testing_outputs(1,:));
                for i=2:size(testing_intervall,1)
                    testing_outputs_as_matrix=catsamples(testing_outputs_as_matrix, testing_outputs(i,:));
                    testing_inputs_as_matrix=catsamples(testing_inputs_as_matrix, testing_inputs(i,:));
                end
                
                %         u = mat2cell(u_m,1:stride*3);
                %         y = mat2cell(y_m,1:stride*3);
            else %Falls max_fail nicht gesetzt ist gibt es nur Training kein Val oder Test
                inputs_as_cells = cell(size(training_intervall,1) , stride );
                outputs_as_cells = cell(size(training_intervall,1) , stride );
                
                for i=1:size(training_intervall,1), inputs_as_cells(i,1:stride) = con2seq(data(training_intervall(i,:),input_taglist)');  end
                
                for i=1:size(training_intervall,1), outputs_as_cells(i,1:stride) = con2seq(data(training_intervall(i,:),output_taglist)');  end
                inputs_as_cells(find(cellfun(@isempty,inputs_as_cells))) = {NaN()};
                outputs_as_cells(find(cellfun(@isempty,outputs_as_cells))) = {NaN()};
                inputs_as_nested_cells = mat2cell(inputs_as_cells,1:stride);
                outputs_as_nested_cells = mat2cell(outputs_as_cells,1:stride);
            end
            
        case 'segmented'
            if ~isnan(max_fail)  %Baut den Datenvektor aus den [train valid test] Abschnitten auf. mit einer Zeile pro Input bzw Output
                inputs_as_cells=[data(training_intervall,input_taglist)' data(validation_intervall,input_taglist)' data(testing_intervall,input_taglist)'];
                outputs_as_cells=[data(training_intervall,output_taglist)' data(validation_intervall,output_taglist)' data(testing_intervall,output_taglist)'];
            else %Falls max_fail nicht gesetzt ist gibt es nur Training kein Val oder Test
                inputs_as_cells=data(training_intervall,input_taglist)';
                outputs_as_cells=data(training_intervall,output_taglist)';
            end
%             MATLAB möchte für das NN Training als Input/Target jeweils nur
%             Zell-Vektoren haben. Bei mehreren Inputs/Targets besteht der Vektor jeweils
%             aus einer Zelle pro Zeitschritt.
            outputs_as_nested_cells = con2seq(outputs_as_cells);
            inputs_as_nested_cells = con2seq(inputs_as_cells);
            
            
        case 'seperate_meta'
    end
    
    if ~isnan(d1)
        d1_max=max(d1); %auch wenn nicht alle Fensterstellen genutzt werden sollten
    end

    %% Erstellt entweder ein TimeDelay Netzwerk mit Feedback (NARX) oder ohne
    %timedelaynet mit gegebenen Inputfenster und Hidden Neuronen (nur eine
    %Schicht)
    if ~isnan(d2)
        NN = narxnet(sort(d1),sort(d2),n); 
    else
        NN = timedelaynet(sort(d1),n); 
    end
    
    NN.trainFcn=trainFcn;
    NN.divideFcn = '';
    %NN.trainParam.min_grad = 1e-10;
    NN.trainParam.epochs = epochs;
    
    if ~isnan(max_fail) 
        switch divideFcn
            case 'dividerand' %Hier werden die zufällig nach dem train/valRatio Schlüssel gemischt, ohne Blöcke zu bilden
                %Daten nochmal neu zusammensetzen nur ohne Testabschnitt hinten
                inputs_as_cells=[data(training_intervall,input_taglist)' data(validation_intervall,input_taglist)'];
                outputs_as_cells=[data(training_intervall,output_taglist)' data(validation_intervall,output_taglist)'];
                outputs_as_nested_cells = con2seq(outputs_as_cells); 
                inputs_as_nested_cells = con2seq(inputs_as_cells); 
                %[temp,Q]=size(y);
                NN.divideFcn = 'dividerand'; % divided by random
                %[trainInd,valInd,testInd]=dividerand(Q,trainRatio,valRatio,1-trainRatio-valRatio); 
                testRatio=1-trainRatio-valRatio;
                NN.divideParam.trainRatio = trainRatio;
                NN.divideParam.valRatio = valRatio;
                NN.divideParam.testRatio = testRatio;
                %NN.divideParam.testRatio = 0;
                NN.trainParam.max_fail=max_fail;
                
            case 'divideind' %ist im Prinzip divideblock da die Indizes schon 
                %feststehen und in der Regel kontuniuerliche Abschnitte sind
                NN.divideFcn = 'divideind'; % divided by specific indices
%                 [~,len_training_intervall] = size(training_intervall);
%                 [~,len_validation_intervall] = size(validation_intervall);
%                 [~,len_testing_intervall] = size(testing_intervall);
%                 trainInd = [1:len_training_intervall];
%                 valInd = [len_training_intervall+1:len_training_intervall+len_validation_intervall-1];
%                 testInd = [len_training_intervall+len_validation_intervall+1:len_training_intervall+len_validation_intervall+len_testing_intervall];
                NN.trainParam.max_fail = max_fail;

                switch data_structure_flag
                    case 'batch'
                        NN.divideParam.trainInd = 1:stride; %hier werden dann nur noch die Blöcke und nicht die einzelnen Indizes übergeben
                        NN.divideParam.valInd = stride+1:stride*2;
                        NN.divideParam.testInd = stride*2+1:size(inputs_as_cells,2);
                       
                    case 'segmented'
                        NN.divideParam.trainInd = training_intervall(1:end-d1_max);
                        NN.divideParam.valInd = validation_intervall(1:end-d1_max);
                        NN.divideParam.testInd = testing_intervall(1:end-d1_max);
                    case 'seperate_meta'
                end

            otherwise
                NN.divideFcn = 'divideind'; % divided by specific indices
                [~,len_training_intervall] = size(training_intervall);
                [~,len_validation_intervall] = size(validation_intervall);
                [~,len_testing_intervall] = size(testing_intervall);
                trainInd = [1:len_training_intervall];
                valInd = [len_training_intervall+1:len_training_intervall+len_validation_intervall-1];
                testInd = [len_training_intervall+len_validation_intervall+1:len_training_intervall+len_validation_intervall+len_testing_intervall];   
                NN.divideParam.trainInd = trainInd(1:end-d1_max);
                NN.divideParam.valInd = valInd(1:end-d1_max);
                NN.divideParam.testInd = testInd(1:end-d1_max);
                NN.trainParam.max_fail=max_fail;
        end 
    end
    
    %Der MSE wird damit auf die range [-1,1] skaliert
    %If it is set to 'percent' then percentage errors are used, relative to
    %the ranges of the original target data, and errors will be mapped to
    %the range [-1,1].
    NN.performParam.normalization = 'percent';
    
    %% Hilfsfunktion zur Trainingsvorbereitung u sind Non-feedback inputs; 
    %y sind entweder Feedback Targets (wenn d2 vorhanden) oder Non-Feedback
    %Targets
    % p sind Shifted inputs  
    % Pi sin Initial input delay states
    % Ai sind Initial layer delay states
    % t sind die Shifted targets
    
    %u sind Non-feedback inputs
    %y sind Feedback bzw Non-Feedback Targets
    if ~isnan(d2)
        [p,Pi,Ai,t] = preparets(NN,inputs_as_nested_cells,{},outputs_as_nested_cells);
    else
        [p,Pi,Ai,t] = preparets(NN,inputs_as_nested_cells,outputs_as_nested_cells);
    end   
    
    %% Trainiert das Netz mit Inputs, Targets, initial Input delay
    %conditions; Initial layer delay conditions liefert das trainierte Netz
    %sowie die Trainings Results zurück
    [NN, TR] = train(NN,p,t,Pi,Ai);

    %% Testing des Ergebnisses unter Verwendung des trainierten Netzes und der Testdaten
    if ~isnan(d2);    %falls narxnet auf closed loop umstellen damit der vorhergesagte(interne) y(t) anstelle des tatsächlichen y(t) verwendet wird
        NN_test = closeloop(NN);
    else
        NN_test=NN;
    end   
    
    switch data_structure_flag
        case 'segmented'
            testing_input_data=data(testing_intervall,input_taglist)';
            testing_output_data=data(testing_intervall,output_taglist)';

            testing_outputs_as_matrix = con2seq(testing_output_data);
            testing_inputs_as_matrix = con2seq(testing_input_data);
    end

    %% Prepare Data again because the feedback might be changed from open to closed  now that it is trained
    if ~isnan(d2)
        [p1,Pi1,Ai1,t1] = preparets(NN_test,testing_inputs_as_matrix,{},testing_outputs_as_matrix);
    else
        [p1,Pi1,Ai1,t1] = preparets(NN_test,testing_inputs_as_matrix,testing_outputs_as_matrix);
    end   
    
    %Simulate the networks response to the training data
    test_net_prediction_as_cell = NN_test(p1,Pi1,Ai1);
    
    performance = perform(NN_test, t1, test_net_prediction_as_cell);
    reg_test=regression(test_net_prediction_as_cell,t1);
    perf_test=perform(NN_test,test_net_prediction_as_cell,t1);
    %reg_test_total=regression(reshape (cell2mat(test_net_prediction_as_cell),1,[]),reshape (cell2mat(t1),1,[]));
    reg_test_total = regression((test_net_prediction_as_cell),(t1),'one');
    
    
    %% Alles ab hier ist eigentlich Quatsch bis auf die letzten beiden Zeilen

    test_net_prediction_as_sequence=cell2mat(test_net_prediction_as_cell); %hier werden die Blöcke von yp1 und u1 einfach aneinander gereiht. Das FUNKTIONIERT NICHT
    
    delaymax=max(max(d1),max(d2));
    from=1;
    to=length(testing_intervall)-delaymax;
    
    switch data_structure_flag
        case 'batch'
            testing_outputs_as_matrix_beschnitten=cell2mat(testing_outputs_as_matrix(d1_max+1:end));
        case 'segmented'
            
            testing_outputs_as_matrix_beschnitten=cell2mat(testing_outputs_as_matrix); %true testing targets
            testing_outputs_as_matrix_beschnitten=testing_outputs_as_matrix_beschnitten(:,1+delaymax:end);
        case 'seperate_meta'
    end
    selected_testing_outputs_as_matrix_beschnitten=testing_outputs_as_matrix_beschnitten(y_num,:);
    
    test_net_prediction_as_sequence=test_net_prediction_as_sequence(:,1:end); %predictions
    selected_test_net_prediction_as_sequence=test_net_prediction_as_sequence(y_num,:);
    
    plot_diff_all=((test_net_prediction_as_sequence-testing_outputs_as_matrix_beschnitten)./testing_outputs_as_matrix_beschnitten)*100; %Muss wirklich mit testing_outputs_as_matrix_beschnitten punktweise skaliert werden? was wenn plot_yp_all mal größer ist, oder testing_outputs_as_matrix_beschnitten=0
    plot_diff=((selected_test_net_prediction_as_sequence-selected_testing_outputs_as_matrix_beschnitten)./selected_testing_outputs_as_matrix_beschnitten)*100;

    %plot_diff=(plot_yp-plot_y);
    %plot_yp=medfilt1(plot_yp,5);

    % generating the training performance
    y_train = NN(p,Pi,Ai);
    u_train = t;
    

    reg_train=regression(y_train,t);
    perf_train=perform(NN,y_train,t);
    reg_train_total=regression(reshape (cell2mat(y_train),1,[]),reshape (cell2mat(t),1,[]));



    reg_test_fit=regression(std_vector(testing_outputs_as_matrix_beschnitten,test_net_prediction_as_sequence),std_vector(test_net_prediction_as_sequence,testing_outputs_as_matrix_beschnitten),'one');
    
    
    y_train=cell2mat(y_train);
    u_train=cell2mat(u_train);
    
    target=cell2mat(testing_outputs_as_matrix);
    
    elapsedTime = toc; 
    output_struct=v2struct(target,reg_train,perf_train,reg_train_total,reg_test,perf_test,reg_test_total,selected_testing_outputs_as_matrix_beschnitten,testing_outputs_as_matrix_beschnitten,selected_test_net_prediction_as_sequence,test_net_prediction_as_sequence,plot_diff,plot_diff_all,y_train,u_train,elapsedTime,NN_test,TR,reg_test_fit,performance);
end

% 
% Die folgenden Variablennamen wurden geändert
% plot_y = selected_testing_outputs_as_matrix_beschnitten
% 
% plot_y_all = testing_outputs_as_matrix_beschnitten
% 
% plot_yp = selected_test_net_prediction_as_sequence
% 
% plot_yp_all = test_net_prediction_as_sequence
% 
% yp1 = test_net_prediction_as_cell
% 
% yp_m1 = test_net_prediction_as_sequence
% 
% y_test = test_net_prediction_as_cell
% 
% NN_net = NN
% 
% NN_net_test = NN_test