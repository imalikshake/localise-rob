function [weights, particles] = orientationProb(particles,scans,botScan,nanvalue,n)
 sensor = 5;
 if n < 5
     sensor = 10;
 end
 botScan(isnan(botScan))=nanvalue;
 weights = ones(length(particles),1);
 maxWeight = 0;
 maxIndex = 0;
for i = 1:length(particles)
   maxWeight = 0;
   maxIndex = 0;
   scanConfig = length(botScan);
   for k = 1:scanConfig
       %% Shift scan of particles by k
       shift = circshift(scans(i,:)', k);
       weights(i) = 1;

       %% Scan and check if max
       for j = 1:scanConfig
           weight = normpdf(shift(j),botScan(j),sensor);
           if isnan(weight)
              weight = 0
           end
           weights(i) = weight * weights(i);
       end
       if weights(i) > maxWeight
           maxWeight = weights(i);
           maxIndex = k;
       end
   end
   weights(i) = maxWeight;
   turn = maxIndex * 2*pi/scanConfig;
   next = particles(i).getBotAng()-turn;
   particles(i).setBotAng(next);
end

end

