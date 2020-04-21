function f=get_perform(output,runs,runname)
    num=numel(runs);
    
    fig_dummie=figure;
    f = figure('Name',['Training Performance ', runname],'NumberTitle','off');

    xlim_max=[0 0];
    ylim_max=[0 0];
    %matrix dimension
    num_sr=floor(num^0.5);
    if num<=num_sr*(num_sr+1)
        rows=num_sr;
    else
        rows=num_sr+1;
    end

    if num<=num_sr^2
        cols=num_sr;
    else
        cols=num_sr+1;
    end

    % the plotting
    for row = 1:rows
        for col=1:cols
            index=(row-1)*cols+col;
            if index <= num
                c=runs(index);
                % here is the plot generated
                %---------------------------
                figure(fig_dummie);
                TR=output{c}.NN_output.TR;
                
                h = plotperform(TR);
                ax = h.CurrentAxes;
                figure(f);
                s = subplot(rows,cols,index); %create and get handle to the subplot axes
                fig = get(ax,'children'); %get handle to all the children in the figure
                copyobj(fig,s); %copy children to new parent axes i.e. the subplot axes
                title_str=get(get(ax,'title'),'string');
                title(s,title_str);

                %title_str=get(get(ax,'title'),'string');
                title(s,sprintf(['best TR perf: ',num2str(TR.best_perf),'\n at epoch ',num2str(TR.best_epoch)]));
                xlabel_str=get(get(ax,'xlabel'),'string');
                ylabel_str=get(get(ax,'ylabel'),'string');
                xlabel(s,xlabel_str);
                ylabel(s,['RUN ', num2str(c),' | ','MSE']);
                %ylabel(s,'MSE');

                %legend(s,'show');
                set(s,'yscale','log');
                axis(s,'auto');
            
                xlim_s=get(s,'xlim');
                ylim_s=get(s,'ylim');
                
                if xlim_max(1,1)>xlim_s(1,1)
                    xlim_max(1,1)=xlim_s(1,1);
                end
                if xlim_max(1,2)<xlim_s(1,2)
                    xlim_max(1,2)=xlim_s(1,2);  
                end
                
                if ylim_max(1,1)>ylim_s(1,1)
                    ylim_max(1,1)=ylim_s(1,1);
                end
                if ylim_max(1,2)<ylim_s(1,2)
                    ylim_max(1,2)=ylim_s(1,2);  
                end
                
                %--------------------------
            end
        end
    end
    close(fig_dummie)
    for i=1:num
        ax=subplot(rows,cols,i);
        xlim(ax,xlim_max);
        ylim(ax,ylim_max);
        %ylim(ax,'YScale', 'log');
        grid(ax,'on');
    end

    
end
