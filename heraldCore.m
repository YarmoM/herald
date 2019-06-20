function res = heraldCore(botToken, chatId, message, varargin)
%HERALDCORE Communicate with Telegram channel through @herald_matlab_bot
%   heraldCore(chatId, ...) is always the most basic way of calling the
%   function, as a chatId is always required. However, it is recommended
%   to write wrapper functions with a hardcoded chatId, such as the one
%   included in the folder. All communication happens through the Telegram
%   Bot API (see *bot* below).
%   
%   S = heraldCore(...) returns the struct S converted from the JSON string
%   that the Telegram API sent as a response. If a message has been sent,
%   this struct will contain a messageId that can then be used to edit or
%   delete that message.
%   
%   heraldCore(botToken, chatId, ...) specify which botToken and
%   chatId/channelId to use. These two parameters are always necessary.
%   
%   heraldCore(..., text) sends the text message to the channel as the bot.
%   Message is formatted in markdown (see *markdown* below).
%   
%   heraldCore(..., figHandle) sends the figHandle figure as a png to the
%   channel.
%   
%   heraldCore(..., text, messageId) edits the messageId message with the
%   new text. The output S of a previous call to the heraldCore function is
%   also a valid messageId value.
%   
%   heraldCore(..., [], messageId) deletes the messageId message. The 
%   output S of a previous call to the heraldCore function is also a valid
%   messageId value.
%   
%   About the chatId (when using direct chat):
%   After starting a conversation with @herald_matlab_bot, forward a
%   message inside that conversation to @get_id_bot and the chatId will be
%   returned to you.
%   
%   About the chatId (when using channels):
%   The chatId is obtained from forwarding a random message inside the
%   dedicated channel to @get_id_bot. The dedicated channel should have
%   the bot as an administrator in order to function.
%   
%   About curl:
%   Herald uses the operating system's curl command. If this is not
%   installed, please install a binary from *curl* below.
%   
%   Links:
%   *bot*               https://core.telegram.org/bots/api
%   *markdown*          https://core.telegram.org/bots/api#markdown-style
%   *curl (info)*       https://curl.haxx.se
%   *curl (install)*	https://chocolatey.org/packages/curl
%   
%   See also system, jsondecode
    
    p = inputParser;
    p.addRequired('botToken');
    p.addRequired('chatId');
    p.addRequired('message');
    p.addOptional('messageId', [], @(x)isnumeric(x)||isstruct(x));
    p.parse(botToken, chatId, message, varargin{:});
    p = p.Results;
    
    botToken = p.botToken;
    chatId = p.chatId;
    message = p.message;
    messageId = p.messageId;
    
    % If a msg struct was provided instead of just a messageId
    if isstruct(messageId) && isfield(messageId, 'result') && isfield(messageId.result, 'message_id')
        messageId = messageId.result.message_id;
    else
        messageId = [];
    end
    
    % If message is not a string or a handle, throw an error
    if iscell(p.message) || (isnumeric(p.message) && ~ishandle(p.message))
        error('herald:messageNotChar', 'Provided message is not a string or a handle');
    end
    
    if isempty(messageId)
        % Send new content
        
        if ishandle(message)
            % Send photo
            fname = p_exportImg(message);
            res = p_sendPhoto(botToken, chatId, fname);
        else
            % Send message
            res = p_sendMessage(botToken, chatId, message);
        end
    else
        % Modify existing content
        
        if isempty(message)
            % Delete message
            res = p_deleteMessage(botToken, chatId, messageId);
        elseif ishandle(message)
            % Edit message by changing the image
            warning('herald:notSupported', 'Editing an existing image is not (yet) supported');
        else
            % Edit message by changing the text
            res = p_editMessage(botToken, chatId, message, messageId);
        end
    end

end


function fname = p_exportImg(handle)
%   Save a figure to disk and return the path

    % Save figure to disk
    fname = [tempname '.png'];
    print(handle, fname, '-dpng');

end

function s = p_jsondecode(json)
%   Make jsondecode backwards compatible
%   The included jsonDecodeLegacy is prone to error, but is decent for
%   older versions of MatLab (<R2016b) that do not have jsondecode.
%
%   Because an incorrect conversion of JSON to a struct is not impeding (in
%   fact, the message/photo will have been sent anyway), any errors at this
%   stage will be discarded and an empty struct will be returned. A warning
%   will be displayed to inform the user.

    try
        if exist('jsondecode', 'builtin')
            s = jsondecode(json);
        else
            s = jsonDecodeLegacy(json);
        end
    catch err
        warning(['An error happened during the conversion of JSON to a struct '...
                 '(JSON: ' json ')']);
        s = [];
    end

end

function res = p_sendMessage(botToken, chatId, message)
%   Call the sendMessage method of the Telegram API
%   https://core.telegram.org/bots/api#sendmessage

    urlPattern = 'https://api.telegram.org/bot%s/sendMessage';
    url = sprintf(urlPattern, botToken);

    paramsPattern = 'chat_id=%s&parse_mode=Markdown&text=%s';
    params = sprintf(paramsPattern, chatId, urlencode(message));

    command = ['curl -s -X POST -d "' params '" ' url ''];
    try
        [status res] = system(command);
    catch err
        error('You probably need to install cURL first, see documentation for instructions.');
    end
    
    res = p_jsondecode(res);

end

function res = p_sendPhoto(botToken, chatId, fname)
%   Call the sendPhoto method of the Telegram API
%   https://core.telegram.org/bots/api#sendphoto

    urlPattern = 'https://api.telegram.org/bot%s/sendPhoto';
    url = sprintf(urlPattern, botToken);

    paramsPattern = 'chat_id=%s';
    params = sprintf(paramsPattern, chatId);

    command = ['curl -s -X POST -F "' params '" -F photo="@' fname '" ' url ''];
    try
        [status res] = system(command);
    catch err
        error('You probably need to install cURL first, see documentation for instructions.');
    end
    
    res = p_jsondecode(res);

end

function res = p_editMessage(botToken, chatId, message, messageId)
%   Call the editMessageText method of the Telegram API
%   https://core.telegram.org/bots/api#editmessagetext

    urlPattern = 'https://api.telegram.org/bot%s/editMessageText';
    url = sprintf(urlPattern, botToken);

    paramsPattern = 'chat_id=%s&parse_mode=Markdown&message_id=%i&text=%s';
    params = sprintf(paramsPattern, chatId, messageId, urlencode(message));

    command = ['curl -s -X POST -d "' params '" ' url ''];
    try
        [status res] = system(command);
    catch err
        error('You probably need to install cURL first, see documentation for instructions.');
    end
    
    res = p_jsondecode(res);

end

function res = p_deleteMessage(botToken, chatId, messageId)
%   Call the deleteMessage method of the Telegram API
%   https://core.telegram.org/bots/api#deletemessage

    urlPattern = 'https://api.telegram.org/bot%s/deleteMessage';
    url = sprintf(urlPattern, botToken);

    paramsPattern = 'chat_id=%s&messageId=%i';
    params = sprintf(paramsPattern, chatId, messageId);

    command = ['curl -s -X POST -d "' params '" ' url ''];
    try
        [status res] = system(command);
    catch err
        error('You probably need to install cURL first, see documentation for instructions.');
    end
    
    res = p_jsondecode(res);

end

