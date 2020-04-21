clear all
%-------------config for testruns------------

xlsx_filename='Parameter_Input.xlsx';
path='';
runname='DoE_Experiment';%can be any name only for filename when saving
plot_on=1;
best_target_mode='performance';  %testperform or trainperform or testreg or testregfit or meansnr
%--------------------------------------------
%--------------------------------------------
disp(['##### starting test ',runname,' #####'])

disp('generating input data from xlsx')
if ~isempty(path)
    FileName_mat=[path,'\',runname,'_','NN','.mat'];
    FileName_xlsx=[path,'\',runname,'_','NN','.xlsx'];
else
    FileName_mat=[runname,'_','NN','.mat'];
    FileName_xlsx=[runname,'_','NN','.xlsx'];
end
% reading from xlsx and creating input
[~, ~, raw]=xlsread(xlsx_filename);

rawx=cellfun(@num2str, raw, 'UniformOutput', false);
[runs, rows]=size(raw);
runs=runs-1;
for row=1:24%rows %Geht alle Spalten durch
    %temp=cell2mat(rawx(2:end,row));
    temp=rawx(2:end,row);
    varname=raw(1,row);
    if ~isempty(str2num(temp{1}))
        temp= cellfun(@(x) str2num(x), temp, 'UniformOutput', false); %here strings of the xls input get converted to numbers
    end
    
    exec=['NN_input_all.',varname{1},'=','temp;'];
    eval(exec);
    
    for i=1:runs %for each row
        exec=['input{',num2str(i),',1}.NN_input.',varname{1},'=','temp{',num2str(i),',1};'];
        eval(exec); 
    end
end

% generating the different runs

for c=1:runs
    %load the dataset from the prepared mat file
    disp(['loading data for run ', num2str(c), ' of ', num2str(runs)])
    load(input{c,1}.NN_input.data_mat_file);
    eval(['data{',num2str(c),',1}=',input{c,1}.NN_input.data_varname,';']); 
    eval(['clear ',input{c,1}.NN_input.data_varname]);
   
    if isfield(input{c,1}.NN_input,'best_of')
        best_of=input{c,1}.NN_input.best_of;
    else
        best_of=1;
    end
    %do multiple tests
    clear output_temp best_perf;
    best_perf=100000;
    
    if min(size(input{c,1}.NN_input.training_intervall))>1
        disp(['******batch_training*******']);
        data_structure_flag = 'batch';
    else
        disp(['******segmented_training*******']);
        data_structure_flag = 'segmented';
    end
    disp(['*************']);
    disp(['starting run ', num2str(c), ' of ', num2str(runs)])
    if best_of > 1
        disp(['best of - mode: "',best_target_mode,'" '])
    end
    for i=1:best_of
        
        if best_of > 1
            disp(['start training ', num2str(i), ' of ', num2str(best_of)])
        end
        %##################This is the run#######################
        output_temp=f_NN(data{c,1},input{c,1}.NN_input,data_structure_flag);
        %########################################################
        
        switch best_target_mode
            case 'trainperform'
                current_perf=output_temp.TR.best_perf;
                real_perf=output_temp.TR.best_perf;
            case 'testperform'
                current_perf=output_temp.perf_test;
                real_perf=output_temp.perf_test;
            case 'testreg'
                current_perf=1-output_temp.reg_test_total;
                real_perf=output_temp.reg_test_total;
            case 'testregfit'
                current_perf=1-output_temp.reg_test_fit;
                real_perf=output_temp.reg_test_fit;
            case 'meansnr'
                current_perf=1/(10^(output_temp.mean_snr/10));
                real_perf=output_temp.mean_snr;
            case 'performance'
                current_perf = output_temp.performance;
                real_perf = output_temp.performance;
        end
        
        if (current_perf < best_perf ) || i==1
            best_perf=current_perf;
            output{c,1}.NN_output=output_temp;
            disp(['new best performance: ', num2str(real_perf), ' in ', num2str(i)])
            disp(['test regression: ', num2str(output_temp.reg_test_total)])
        end
    end
    
    save(FileName_mat,'output','input','data','NN_input_all');
    disp(['*************']);
    
end

disp('finished with testing')


clear c data NN_input_all


if plot_on==1
    disp('generating plots')
    %--------------------the plotting----------------------------
    % gernerating the execplot
    
    %Regression
    fig=get_regression(output,[1:runs],runname);
    if isempty(path)
        savefig(fig,[runname,'_NN_regression.fig']);
    else
        savefig(fig,[path,'\',runname,'_NN_regression.fig']);
    end
    clear fig
    
    %Timeseries
    fig=get_timeseries(input,output,[1:runs],runname);
    if isempty(path)
        savefig(fig,[runname,'_NN_timeseries.fig']);
    else
        savefig(fig,[path,'\',runname,'_NN_timeseries.fig']);
    end
    clear fig
    
    %Histogramm
%     fig=get_hist(output,[1:runs],runname);
%     savefig(fig,[path,'\',runname,'_NN_hist.fig']);
%     clear fig
    
    %Performance
    fig=get_perform(output,[1:runs],runname);
    if isempty(path)
        savefig(fig,[runname,'_NN_perform.fig']);
    else
        savefig(fig,[path,'\',runname,'_NN_perform.fig']);
    end
    clear fig
end   
    
disp(['##### finished with test ',runname,' #####'])

%%%% Read Results of Parameter Study %%%%
results = struct('R',zeros(length(output),1),'perf',zeros(length(output),1));
for i=1:length(output)
    results(i).R = output{i, 1}.NN_output.reg_test;
    results(i).perf = output{i, 1}.NN_output.perf_test;
    results(i).elapsedTime = output{i, 1}.NN_output.elapsedTime;
end

writetable(struct2table(results), [FileName_xlsx(1:end-5) '_results.xlsx']);


%clearing of variables
clear path FileName_mat FileName_xlsx plot_on runs runname fig 
clear output input 
clear xlsx_filename
clear path runname run_num input output data

clear exec i num rawx row rows temp txt varname
