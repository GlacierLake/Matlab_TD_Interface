function [optionschain] = tdOptionsChain(TD_Structure,client_details,weboptions)
    url =  'https://api.tdameritrade.com/v1/marketdata/chains';
    optionschain = webread(url,...
        'apikey',client_details.client_id,...
        'symbol',TD_Structure.symbol,...
        'contractType',TD_Structure.contract_type,...
        'strikeCount',TD_Structure.strike_count,...
        'includeQuotes',TD_Structure.include_quotes,...
        'Strategy',TD_Structure.strategy,...
        'interval',TD_Structure.interval,...
        'range',TD_Structure.range,...
        'fromDate',TD_Structure.fromDate,...
        'toDate',TD_Structure.toDate,...
        'expMonth',TD_Structure.expMonth,...
        'optionType',TD_Structure.optionType,weboptions);
end