
function [modelParameters] = positionEstimatorTraining(training_data)

% LINEAR REGRESSION

binsize = 15; %size of bins/windows in ms


spike_density = zeros(1,98,1);
spike_density_temp = zeros(1,98,1);


yposition = NaN;
yposition_temp = NaN;
xposition = NaN;
xposition_temp = NaN;

for k = 1:8
    for n=1:length(training_data)
        for i = 1:98
           % Calculate maximum t value for every neuron for the nth trial
            tmax = 1;

            if length(training_data(n,k).spikes(i,:)) > tmax;
                tmax = length(training_data(n,k).spikes(i,:))-80;
            end
            nbins = ceil((tmax-300)./binsize); %total number of bins
        end
        
        edge_min = 300; %lower edge of current bin/window
        edge_max = edge_min + binsize; %upper edge of bin
        
        
        for b= 1:nbins
            for i = 1:98
                spike_num = 0; %spike counter
                %counts spike within bin
                for t=edge_min-80:edge_max-80 %lag of 80ms
                    if (length(training_data(n,k).spikes(i,:))-80) >= t
                        if training_data(n,k).spikes(i,t) == 1
                            spike_num = spike_num + 1;
                        end
                    end
                end
                spike_density_temp(b,i,k)= 1000*spike_num./(edge_max-edge_min);
            end
            % positions are calculated subtracting the position at the
            % maximum t value for the current bin minus the value at the
            % minimum t for that bin
            xposition_temp(b,1,k) = training_data(n,k).handPos(1,edge_max)-training_data(n,k).handPos(1,edge_min); 
            yposition_temp(b,1,k) = training_data(n,k).handPos(2,edge_max)-training_data(n,k).handPos(2,edge_min);

            % update edges for next bin
            edge_min = edge_max;
            edge_max = edge_min + binsize;
            if edge_max > (length(training_data(n,k).handPos(1,:))-80) % ensuring edges don't go out of bound
                edge_max = length(training_data(n,k).handPos(1,:))-80;
            end
        end
        if n==1
            xposition(1,1,k) = xposition_temp(1,1,k);
            yposition(1,1,k) = yposition_temp(1,1,k);
            
            spike_density(1,:,k) = spike_density_temp(1,:,k);
            
            for sd=2:nbins
                spike_density(sd,:,k) = spike_density_temp(sd,:,k);
                xposition(sd,1,k) = xposition_temp(sd,1,k);
                yposition(sd,1,k) = yposition_temp(sd,1,k);
                
            end
            current_length = nbins;
        else
            current_length = current_length+nbins;
            for sd=1:nbins
                xposition(current_length+sd,:,k) = xposition_temp(sd,:,k);
                yposition(current_length+sd,:,k) = yposition_temp(sd,:,k);
                spike_density(current_length+sd,:,k) = spike_density_temp(sd,:,k);

            end
        end        
    end   
end

response = [ones(length(spike_density),1,8) spike_density]; %add a column of ones 
xvel = xposition./binsize; %velocity from position
yvel = yposition./binsize;

%position = [xposition yposition];
velocity = [xvel yvel]; 

%linear regression
beta = pinv(response(:,:,1))*velocity(:,:,1);

for k=2:8
    beta_temp = pinv(response(:,:,k))*velocity(:,:,k);
    beta = cat(3,beta,beta_temp);
end

%Covariance
Q = (velocity(:,:,1)-response(:,:,1)*beta(:,:,1))'*(velocity(:,:,1)-response(:,:,1)*beta(:,:,1))/length(velocity(:,:,1));
for k=2:8
Q_temp = (velocity(:,:,k)-response(:,:,k)*beta(:,:,k))'*(velocity(:,:,k)-response(:,:,k)*beta(:,:,k))/length(velocity(:,:,k));
Q = cat(3,Q,Q_temp);
end


% Classification model (KNN)
spike_count = NaN;

response_2 = NaN;

for i = 1:98
    count =1;
    for k=1:8        
        for n=1:length(training_data);   
            tmax = 320;
            spike_num = 0;
            for t=1:tmax
                if training_data(n,k).spikes(i,t) == 1
                    spike_num = spike_num + 1;
                end
            end
            spike_count(count,i)= spike_num;
            response_2(count) = k;
            count = count +1;
        end
    end
end
Mdl = fitcknn(spike_count,response_2,'NumNeighbors',10,'NSMethod','exhaustive','Distance','cosine');


modelParameters = struct('beta',beta,'Q',Q,'model',Mdl);  

end