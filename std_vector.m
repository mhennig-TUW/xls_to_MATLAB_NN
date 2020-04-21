
function B=std_vector(A,C,nSTD,flag)
% Vermutlich: Diese Funktion nimmt zwei Matrizen und z-normiert sie
% zusammen und gibt dann den ersten wieder zurück
    if nargin<=2
        nSTD=1;
    end
    [rows, cols]=size(A);

    for i=1:cols
        v=A(:,i);
        if nargin>=2 && ~isempty(C)
            v_help=vertcat(A(:,i),C(:,i));
            mittel=mean(v_help);
            stdabw=std(v_help);
            if nargin==4 && strcmp('var',flag) %falls Varianz gefragt ist?
                stdabw=(std(A(:,i))*std(C(:,i)))^0.5;
            else
               stdabw=std(v_help); 
            end
            
        else
            mittel=mean(v);
            stdabw=std(v);
        end
        
        
        k=1/(nSTD*stdabw);
        d=-mittel*k;
        y=k.*v+d;
        B(:,i)= y;
    end
end
