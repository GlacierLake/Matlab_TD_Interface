function [graph] = tdGraphHistory(price_history)
    price_history.candles = rmfield(price_history.candles,'datetime');
    price_history.candles = rmfield(price_history.candles,'volume');

    history = cell2mat(struct2cell(price_history.candles)');

    graph = candle(history);
  

end