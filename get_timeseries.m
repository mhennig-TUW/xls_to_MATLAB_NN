function f1=get_timeseries(input,output,runs,runname)

    % 1=vsmean 2=vssample 4=noise(2*diff/amp*100)%
    % 8=noise(diff/std*100) 16=diff^2  32=diff  64=snr
    show_error=64; 
    %---------------------------
    
    
    f1=figure('Name',['Timeresponse on selected Tag ', runname],'NumberTitle','off');
    
    num_of_plot=2;
    sp1 = subplot(num_of_plot,1,1);
    sp2 = subplot(num_of_plot,1,2);
    
    run_count=numel(runs);

    figure(f1);
    hold (sp1,'on');
    axis(sp1,'auto');
    for i=1:run_count
        c=runs(i);
        y_num=input{c}.NN_input.y_num  ;
        target=output{c}.NN_output.target;
        [m n]=size(target);
        num_outputs=m;
        
        t=[1:n]+input{c}.NN_input.testing_intervall(1,1)-1;
        if ~isnan(y_num)
            von(c)=y_num;
            bis(c)=y_num;
        else
            von(c)=1;
            bis(c)=num_outputs;
        end
        
        for j=von(c):bis(c)
            plot(sp1,t,target(j,:),'r','DisplayName',['Run ',num2str(c),'| t ',num2str(j)]);
        end
    end




    %axis(sp1,'manual')  
    hold (sp1,'on');


    hold (sp2,'on');
    axis(sp2,'auto')  


    run_count=numel(runs);

    for i=1:run_count
       c=runs(i);
       for j=von(c):bis(c) 
            
                
            selected_test_net_prediction_as_sequence=output{c}.NN_output.test_net_prediction_as_sequence(j,:);
            selected_testing_outputs_as_matrix_beschnitten=output{c}.NN_output.testing_outputs_as_matrix_beschnitten(j,:);

            delaymax=max(max(input{c}.NN_input.d1),max(input{c}.NN_input.d2)); 
            t=[1:numel(selected_test_net_prediction_as_sequence)]+delaymax+input{c}.NN_input.testing_intervall(1,1)-1;

            amp=max(selected_testing_outputs_as_matrix_beschnitten)-min(selected_testing_outputs_as_matrix_beschnitten);
            diff=selected_test_net_prediction_as_sequence-selected_testing_outputs_as_matrix_beschnitten;
            MSError=immse(selected_testing_outputs_as_matrix_beschnitten,selected_test_net_prediction_as_sequence);
            y_diff_mean=diff/mean(selected_testing_outputs_as_matrix_beschnitten)*100;
            y_diff_y=diff./selected_testing_outputs_as_matrix_beschnitten*100;
            y_noise_amp=(2.*diff)./amp*100;
            y_noise_std=(diff./(std(selected_testing_outputs_as_matrix_beschnitten)))*100;
            y_snr=abs(diff);


            plot(sp1,t,selected_test_net_prediction_as_sequence,'DisplayName',['Run ',num2str(c),'| y ',num2str(j)]);
        
        
        
            % 1=vsmean 2=vssample 4=noise(2*diff/amp*100)% 8=noise(diff/std*100)16=diff
            switch show_error

                case 1
                   mean_error=mean(abs(y_diff_mean));
                   plot(sp2,t,y_diff_mean,'DisplayName',['Run ',num2str(c),'| t ',num2str(j),' | MAE:',num2str(mean_error)]);
                   h=title(sp2,['Difference to Target vs. mean']);
                   xl=xlabel(sp2,'sample');
                   yl=ylabel(sp2,'diff / mean [%]');
                case 2
                   mean_error=mean(abs(y_diff_y));
                   plot(sp2,t,y_diff_y,'DisplayName',['Run ',num2str(c),'| t ',num2str(j),' | MAE:',num2str(mean_error)]);
                   h=title(sp2,['Difference to Target vs. Value']);
                   xl=xlabel(sp2,'sample');
                   yl=ylabel(sp2,'diff / value [%]');
                case 4
                   mean_error=mean(abs(y_noise_amp));
                   plot(sp2,t,y_noise_amp,'DisplayName',['Run ',num2str(c),'| t ',num2str(j),' | MAE:',num2str(mean_error)]);
                   h=title(sp2,['Difference to Target vs. Amplitude']);
                   xl=xlabel(sp2,'sample');
                   yl=ylabel(sp2,'2 * diff / amp [%]');
                case 8
                   mean_error=mean(abs(y_noise_std));
                   plot(sp2,t,y_noise_std,'DisplayName',['Run ',num2str(c),'| t ',num2str(j),' | MAE:',num2str(mean_error)]);
                   h=title(sp2,['Difference to Target vs. Standard Deviation']);
                   xl=xlabel(sp2,'sample');
                   yl=ylabel(sp2,'diff / stdv [%]');
                case 16
                   mean_error=mean(abs(diff.^2));
                   plot(sp2,t,diff.^2,'DisplayName',['Run ',num2str(c),'| t ',num2str(j),' | MAE:',num2str(mean_error)]);
                   h=title(sp2,['Difference']);
                   xl=xlabel(sp2,'sample');
                   yl=ylabel(sp2,'diff^2');
                case 32
                   mean_error=mean(abs(diff));
                   plot(sp2,t,diff,'DisplayName',['Run ',num2str(c),'| t ',num2str(j),' | MSE:',num2str(MSError)]);
                   h=title(sp2,['Difference']);
                   xl=xlabel(sp2,'sample');
                   yl=ylabel(sp2,'diff');
                case 64
                   selected_testing_outputs_as_matrix_beschnitten_gl=selected_testing_outputs_as_matrix_beschnitten-mean(selected_testing_outputs_as_matrix_beschnitten);
                   diff_snr=((selected_testing_outputs_as_matrix_beschnitten_gl.^2)./(diff.^2)).^0.5;
                   diff_isnr=((diff.^2)./(selected_testing_outputs_as_matrix_beschnitten_gl.^2)).^0.5;
                   y_eff=(dot(selected_testing_outputs_as_matrix_beschnitten_gl,selected_testing_outputs_as_matrix_beschnitten_gl)/numel(selected_testing_outputs_as_matrix_beschnitten))^0.5;
                   diff_eff=(dot(diff,diff)/numel(diff))^0.5;
                   y_snr=y_eff/diff_eff;
                   y_snr2=var(selected_testing_outputs_as_matrix_beschnitten_gl)/var(diff);

                   mean_error=20*log10(y_snr);
                   mean_error2=10*log10(y_snr2);

                   plot(sp2,t,y_noise_std,'DisplayName',['Run ',num2str(c),'| t ',num2str(j),' | SNR: ',num2str(round(mean_error2,3)),' dB']);
                   h=title(sp2,['Differenz/Stdv vs. Sample ']);
                   xl=xlabel(sp2,'sample');
                   yl=ylabel(sp2,'$\frac{\mathrm{Diff}}{\mathrm{Stdv}}{\left[\%\right]}$');
            end

            set(xl,'Interpreter','latex');
            set(yl,'Interpreter','latex');
            set(yl,'FontSize',18);
        end
    end
    
    
    title(sp1,'Target and Runs vs. sample');
    legend(sp1,'show','location','best');  
    grid (sp1,'on'); 
    xlabel(sp1,'sample'), ylabel(sp1,'value');
    xlim_sp1=get(sp1,'xlim');
     
    legend(sp2,'show','location','best');
    grid (sp2,'on');
    xlim(sp2,xlim_sp1);
    
    
    linkaxes([sp1, sp2], 'x');
    
end
