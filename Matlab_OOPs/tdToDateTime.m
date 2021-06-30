function [t] = tdToDateTime(up)
    javaDateTime = blanks(length(up.streamerInfo.tokenTimestamp));
    javaDateTime = up.streamerInfo.tokenTimestamp;
    
    year = javaDateTime(1:4);
    month = javaDateTime(6:7);
    day = javaDateTime(9:10);
    
    hour = javaDateTime(12:13);
    min = javaDateTime(15:16);
    sec = javaDateTime(18:19);
    nano = javaDateTime(21:length(javaDateTime));
    
    dateTime = [day, '-', month, '-', year, ' ', hour, ':', min, ':', sec];
    
    t = datetime(dateTime, 'InputFormat','dd-MM-yyyy HH:mm:ss');

end