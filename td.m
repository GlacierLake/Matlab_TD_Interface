classdef td
    properties (Constant, Access = private)
        client_id = td.credentials.ConsumerKey;
        refresh_token = td.credentials.RefreshToken; 
        callback_url = td.credentials.CallbackURL;
        credentials = td.credentialsreader();
        web_options = td.start()
        
    end
    methods(Static, Access = private)         
        function credentials = credentialsreader()
            fid = fopen('credentials.json');
            raw = fread(fid,inf);
            str = char(raw');
            fclose(fid);
            credentials = jsondecode(str);
        end
        function web_options = start()
            
            urlrefresh_token = urlencode(td.refresh_token);
            url = 'https://api.tdameritrade.com/v1/oauth2/token';

            data = [...
                '&grant_type=','refresh_token',... 
                '&refresh_token=',urlrefresh_token,...
                '&access_type=',...
                '&code=',...
                '&client_id=',td.client_id,'%40AMER.OAUTHAP',...
                '&redirect_uri='] ;

            response = webwrite(url,data);
            access_token = response.access_token;
            %refresh_time = ((datetime('now'))+2/24/4); 
            
            HeaderFields = {'Authorization',['Bearer ',access_token]};
            web_options = weboptions('HeaderFields',HeaderFields,'ContentType','json');
        end
        
     end
    methods(Static) 
        
        
        function [instrument_search] = searchInstruments(search_details, search_type)
        %Search for Financial Instruments
        %search_details[string]: What you are searching for
        %search_type[string]: Has to be following
        %   'symbol-search': Retrieve instrument data of a specific symbol
        %   or cusip
        %
        %   'symbol-regex': Retrieve instrument data for all symbols
        %   matching regex. Example: search_details=XYZ.* will return all 
        %   symbols beginning with XYZ
        %
        %   'desc-search': Retreive Instrument data for instruments whose
        %   description contains the word supplied. Example:
        %   search_details=FakeCompany will return all instruments with
        %   FakeCompany in the description.
        %
        %   'desc-regex': Search description with full regex support.
        %   Example: search_details= 'XYZ[A-C]' returns all instruments
        %   whose descriptions contain a word beginning with XYZ followed
        %   by a character A through C
        %
        %   'fundamental': Returns fundamental data for a single instrument
        %   specified by exact symbol
            url = 'https://api.tdameritrade.com/v1/instruments';
                        
            instrument_search = webread(url,...
            'apikey',td.client_id,...
            'symbol',search_details,...
            'projection', search_type,...
            td.web_options);
        end
        function [cusip_search] = cusipSearch(cusip)
        %Get an instrument by CUSIP
        %cusip[string]: CUSIP number to search
            url = ['https://api.tdameritrade.com/v1/instruments/',cusip];
            
            cusip_search = webread(url,...
                'apikey=',td.client_id,...
                td.web_options);
        end
        function markethours = multipleMarketHours(markets)
        %Retrieve market hours for specified markets
        %markets[string]: 
        %   'EQUITY', 'OPTION', 'FUTURE', 'BOND', or 'FOREX'
            url = 'https://api.tdameritrade.com/v1/marketdata/hours';
            
            markethours = webread(url,...
                'apikey',td.client_id,...
                'markets', markets,...
                'date',datestr(datenum(datestr(datetime('today')),'dd-mm-yyyy'),'yyyy-mm-dd'),...
                td.web_options);
        end
        function markethours = singleMarketHours(market,date)
        %Retrieve market hours for a specified single market
        %markets[string]: 
        %   'EQUITY', 'OPTION', 'FUTURE', 'BOND', or 'FOREX'
        %date[string]: The date for which market hours information is 
        %requested.Valid ISO-8601 formats are: yyyy-MM-dd and 
        %yyyy-MM-dd'T'HH:mm:ss
        
            url = ['https://api.tdameritrade.com/v1/marketdata/',market,'/hours'];
            
            markethours = webread(url,...
                'apikey',td.client_id,...
                'date',date,...
                td.web_options);
        end
        function movers = getMovers(index,direction,change)
        %Top 10 (up or down) movers by value or percent for a particular
        %market
        %index[string]: '$COMPX', '$DJI', or '$SPX.X'
        %direction[string]: 'up' or 'down'
        %change[string]: 'percent' or 'value'
            url = ['https://api.tdameritrade.com/v1/marketdata/',index,'/movers'];
            
            movers = webread(url,...
                'apikey',td.client_id,...
                'direction',direction,...
                'change',change,...
                td.web_options);
        end
        function [optionschain] = getOptionsChain(symbol,contractType,strikeCount,includeQuotes,strategy,interval,strike,range,dateSpecifier,date,expMonth,optionType)
        %Get option chain for an optionable Symbol
        %symbol[string]: TICKR or Symbol
        %contractType[string]: Type of contracts to return in the chain. 
        %    Can be 'CAll', 'PUT', or 'ALL'
        %strikeCount[string]: The number of strikes to return above and
        %   below at-the-money price.
        %includeQuotes[string]: Include quotes for options in the option
        %   chain. Can be 'TRUE' or 'FALSE'
        %strategy[string]: Passing a value returns a Strategy Chain.
        %   Possible values are 'SINGLE', 'COVERED', 'VERTICAL',
        %   'CALENDAR', 'STRANGLE', 'STRADDLE, 'BUTTERFLY', 'CONDOR',
        %   'DIAGONAL', 'COLLAR', or 'ROLL'
        %interval[string]: Strike inteval for spread strategy chains
        %strike[string]: Proved a strike price to return options only at
        %   that strike price.
        %range[string]: Returns options for the given range. Possible 
        %   values are:
        %       'ITM': In-the-money
        %       'NTM': Near-the-money
        %       'OTM': Out-of-the-money
        %       'SAK': Strikes Above Market
        %       'SBK': Strikes Below Market
        %       'SNK': Strikes Near Market
        %       'ALL': All Strikes
        %dateSpecifier[string]: Specifies which date type you will want 
        %   'fromDate': Only returns expirations after this date. For
        %   strategies, expiration refers to the nearest term expiration in
        %   the strategy. Valid ISO-860 formats are: yyyy-MM-dd and
        %   yyyy-MM--dd'T'HH:mm:ssz
        %   'toDate': Only returns expirations before this date. For
        %   strategies, expiration refers to the nearest term expiration in
        %   the strategy. Valid ISO-860 formats are: yyyy-MM-dd and
        %   yyyy-MM--dd'T'HH:mm:ssz
        %date[string]: Specify what date to use according to dateSpecifier
        %expMonth[string]: Return only options expiring in the specified
        %   month. Month is given in three character Format. Example: 'JAN'
        %   For All Months please use 'ALL'
        %optionType[string]: Type of contracts to return. Possible values
        %   are:
        %       'S': Standard contracts
        %       'NS': Non-standard contracts
        %       'ALL': All contracts
                url =  'https://api.tdameritrade.com/v1/marketdata/chains';
            if dateSpecifier == "fromDate"
                optionschain = webread(url,...
                'apikey',td.client_id,...
                'symbol',symbol,...
                'contractType',contractType,...
                'strikeCount',strikeCount,...
                'includeQuotes',includeQuotes,...
                'Strategy',strategy,...
                'interval',interval,...
                'strike',strike,...
                'range',range,...
                'fromDate',date,...
                'expMonth',expMonth,...
                'optionType',optionType,td.web_options);
            elseif dateSpecifier == "toDate"
                optionschain = webread(url,...
                'apikey',td.client_id,...
                'symbol',symbol,...
                'contractType',contractType,...
                'strikeCount',strikeCount,...
                'includeQuotes',includeQuotes,...
                'Strategy',strategy,...
                'interval',interval,...
                'strike',strike,...
                'range',range,...
                'toDate',date,...
                'expMonth',expMonth,...
                'optionType',optionType,td.web_options);
            end
        end
        function [optionschain] = getAnalyticalOptionsChain(symbol,contractType,strikeCount,includeQuotes,interval,strike,range,dateSpecifier,date,volatility,underlyingPrice,interestRate,daysToExpiration,expMonth,optionType)
        %Get Analytical Strategy for Optionable Symbol. Allows use of the
        %volatility, underlyingPrice, interestRate, and daysToExpiration
        %params to calculate theoretical values
        %symbol[string]: TICKR or Symbol
        %contractType[string]: Type of contracts to return in the chain. 
        %   Can be 'CAll', 'PUT', or 'ALL'
        %strikeCount[string]: The number of strikes to return above and
        %   below at-the-money price.
        %includeQuotes[string]: Include quotes for options in the option
        %   chain. Can be 'TRUE' or 'FALSE'
        %interval[string]: Strike inteval for spread strategy chains
        %strike[string]: Proved a strike price to return options only at
        %   that strike price.
        %range[string]: Returns options for the given range. Possible 
        %    values are:
        %   'ITM': In-the-money
        %   'NTM': Near-the-money
        %   'OTM': Out-of-the-money
        %   'SAK': Strikes Above Market
        %   'SBK': Strikes Below Market
        %   'SNK': Strikes Near Market
        %   'ALL': All Strikes
        %dateSpecifier[string]: Specifies which date type you will want 
        %   'fromDate': Only returns expirations after this date. For
        %   strategies, expiration refers to the nearest term expiration in
        %   the strategy. Valid ISO-860 formats are: yyyy-MM-dd and
        %   yyyy-MM--dd'T'HH:mm:ssz
        %   'toDate': Only returns expirations before this date. For
        %   strategies, expiration refers to the nearest term expiration in
        %   the strategy. Valid ISO-860 formats are: yyyy-MM-dd and
        %   yyyy-MM--dd'T'HH:mm:ssz
        %date[string]: Specify what date to use according to dateSpecifier
        %volatility[string]: Volatility to use in caluclations.
        %underlyingPrice[string]: Underlying price to use in calculations
        %interestRate[string]: Interest rate to use in calculations
        %daysToExpiration[string]: Days to expiration to use in
        %   calculations
        %expMonth[string]: Return only options expiring in the specified
        %   month. Month is given in three character Format. Example: 'JAN'
        %   For All Months please use 'ALL'
        %optionType[string]: Type of contracts to return. Possible values
        %   are:
        %       'S': Standard contracts
        %       'NS': Non-standard contracts
        %       'ALL': All contracts
                url =  'https://api.tdameritrade.com/v1/marketdata/chains';
            if dateSpecifier == "fromDate"
                optionschain = webread(url,...
                'apikey',td.client_id,...
                'symbol',symbol,...
                'contractType',contractType,...
                'strikeCount',strikeCount,...
                'includeQuotes',includeQuotes,...
                'Strategy','ANALYTICAL',...
                'interval',interval,...
                'strike',strike,...
                'range',range,...
                'fromDate',date,...
                'volatility',volatility,...
                'underlyingPrice',underlyingPrice,...
                'interestRate',interestRate,...
                'daysToExpiration',daysToExpiration,...
                'expMonth',expMonth,...
                'optionType',optionType,td.web_options);
            elseif dateSpecifier == "toDate"
                optionschain = webread(url,...
                'apikey',td.client_id,...
                'symbol',symbol,...
                'contractType',contractType,...
                'strikeCount',strikeCount,...
                'includeQuotes',includeQuotes,...
                'Strategy','ANALYTICAL',...
                'interval',interval,...
                'strike',strike,...
                'range',range,...
                'toDate',date,...
                'volatility',volatility,...
                'underlyingPrice',underlyingPrice,...
                'interestRate',interestRate,...
                'daysToExpiration',daysToExpiration,...
                'expMonth',expMonth,...
                'optionType',optionType,td.web_options);
            end
        end
        function pricehistory = getPriceHistory(symbol,periodType,frequencyType,frequency,endDate,startDate,needExtendedHoursData)
            url = ['https://api.tdameritrade.com/v1/marketdata/',symbol,'/pricehistory'];
            
            pricehistory = webread(url,...
                'apikey',td.client_id,...
                'periodType',periodType,...
                'period',period,...
                'frequencyType',frequencyType,...
                'frequency',frequency,...
                'endDate',endDate,...
                'startDate',startDate,...
                'needExtendedHoursData',needExtendedHoursData,...
                td.web_options);
        end
        function quote = getQuote(symbol)
            url = ['https://api.tdameritrade.com/v1/marketdata/',symbol,'/quotes'];
            
            quote = webread(url,...
                'apikey',td.client_id,...
                td.web_options);
        end
        function quotes = getQuotes(symbol)
            url = 'https://api.tdameritrade.com/v1/marketdata/quotes';
            
            quotes = webread(url,...
                'apikey',td.client_id,...
                'symbol',symbol,...
                td.web_options);
        end
    end
        
end