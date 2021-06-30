function [web_options,refresh_time] = accesstoken(Client_Details)
    urlrefresh_token = urlencode(Client_Details.refresh_token);
    url = 'https://api.tdameritrade.com/v1/oauth2/token';

        data = [...
            '&grant_type=','refresh_token',... 
            '&refresh_token=',urlrefresh_token,...
            '&access_type=',...
            '&code=',...
            '&client_id=',Client_Details.client_id,'%40AMER.OAUTHAP',...
            '&redirect_uri='] ;

    response = webwrite(url,data);
    access_token = response.access_token;
    refresh_time = ((datetime('now'))+2/24/4); 
    display(refresh_time);

    HeaderFields = {'Authorization',['Bearer ',access_token]};
    web_options = weboptions('HeaderFields',HeaderFields,'ContentType','json');
    
end