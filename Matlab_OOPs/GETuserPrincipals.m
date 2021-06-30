function [user_principals] = GETuserPrincipals(TD_Struct,weboptions)
    url = 'https://api.tdameritrade.com/v1/userprincipals';

    user_principals = webread(url,...
        'fields',TD_Struct.fields,...
        weboptions);
end