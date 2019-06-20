function res = heraldWrapper(message, varargin)
%HERALDWRAPPER Communicate with Telegram channel
%   S = heraldWrapper(...) is a wrapper for the herald function. See herald
%   for a guide on how to use it.
%   
%   See also heraldCore
    
    % Please replace the placeholder token below
    botToken = 'API_KEY';
    chatId = 'CHAT_ID';
    
    % Parse input
    p = inputParser;
    p.addRequired('message');
    p.addOptional('messageId', [], @(x)isnumeric(x)||isstruct(x));
    p.parse(message, varargin{:});
    p = p.Results;
    
    % Call the heraldCore function
    res = heraldCore(botToken, chatId, p.message, p.messageId);

end

