function [x, y, newModelParameters] = positionEstimator(test_data, modelParameters)

spike_density_est = NaN;
spike_density_est1 = NaN;
tmax = 320;
new = NaN;

%Classifier
if length(test_data.spikes) < 330 %only classify if it's the first iteration...
    for i=1:98
        spike_num = 0;
        for t=1:tmax
            if test_data.spikes(i,t) == 1
                spike_num = spike_num + 1;
            end
        end
        new(i)= spike_num;
    end
    dir = mode(predict(modelParameters.model,new));
else
    dir = modelParameters.dir; %..otherwise use value from new model parameters passed on. 
end

edge_min = length(test_data.spikes)-20; %edges of bin
edge_max = length(test_data.spikes)-10;

for i = 1:98
    spike_num = 0; %spike counter
    %counts spikes within bin
    for t=edge_min-80:edge_max-80 %lag of 80ms
        if (length(test_data.spikes(i,:))) >= t
            if test_data.spikes(i,t) == 1
                spike_num = spike_num + 1;
            end
        end
    end
    spike_density_est(1,i)= 1000*spike_num./(edge_max-edge_min); %Spike rate
    
end
spike_density_est = [1 spike_density_est]; %add column of 1s for decoding


vx = spike_density_est*modelParameters.beta(:,1,dir); %get velocity from parameters
vy = spike_density_est*modelParameters.beta(:,2,dir);

if length(test_data.spikes(1,:))<330
x = test_data.startHandPos(1);
y = test_data.startHandPos(2);
else
x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:))) + vx*10 - modelParameters.Q(1,2,dir); % Previous position + velocity * binsize + error
y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:))) + vy*10 - modelParameters.Q(2,2,dir);
end

edge_min = length(test_data.spikes)-10; %edges of bin
edge_max = length(test_data.spikes);

for i = 1:98
    spike_num = 0; %spike counter
    %counts spikes within bin
    for t=edge_min-80:edge_max-80 %lag of 80ms
        if (length(test_data.spikes(i,:))) >= t
            if test_data.spikes(i,t) == 1
                spike_num = spike_num + 1;
            end
        end
    end
    spike_density_est1(1,i)= 1000*spike_num./(edge_max-edge_min); %Spike rate
    
end
spike_density_est1 = [1 spike_density_est1]; %add column of 1s for decoding


vx = spike_density_est1*modelParameters.beta(:,1,dir); %get velocity from parameters
vy = spike_density_est1*modelParameters.beta(:,2,dir);

if length(test_data.spikes(1,:))<330
x = test_data.startHandPos(1);
y = test_data.startHandPos(2);
else
x = x + vx*10 - modelParameters.Q(1,2,dir); % Previous position + velocity * binsize + error
y = y + vy*10 - modelParameters.Q(2,2,dir);
end

if length(test_data.spikes(1,:))<330 && dir == 6
    x = x-7;
end
if length(test_data.spikes(1,:))<330 && dir == 1
    y = y+5;
end
if length(test_data.spikes(1,:))<330 && dir == 2
    x = x-7;
end
if length(test_data.spikes(1,:))<330 && dir == 3
    x = x-3;
end
if length(test_data.spikes(1,:))<330 && dir == 3
    y = y+4;
end
if y<-80 && dir ==6
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if y<-85 && dir ==7 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if x>60 && dir ==7 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if x>95 && dir ==8 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if x>80 && dir ==1 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if y>95 && dir ==2 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if y>100 && dir ==3 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if x<-105 && dir ==5 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end
if x<-100 && dir ==4 
    y = test_data.decodedHandPos(2,length(test_data.decodedHandPos(2,:)));
    x = test_data.decodedHandPos(1,length(test_data.decodedHandPos(1,:)));
end

newModelParameters.dir = dir;
newModelParameters.beta = modelParameters.beta;
newModelParameters.model = modelParameters.model;
newModelParameters.Q = modelParameters.Q;

end