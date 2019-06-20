# Herald

## Introduction

### Concept of Telegram bots

A bot is a Telegram entity which can send messages to a channel and manage them. Tools like herald use the Telegram Bot API to interact with channels through bots.

### Creating a custom bot

Create a custom bot by starting a conversation with [@BotFather](https://telegram.me/BotFather) and provide the bot's API token as described above.

### Installation

Make sure the `heraldCore.m` file and the `private` folder are in the current workspace or have been added to PATH. It is recommended to use a wrapper around the `heraldCore()` function (see below).

On the system side, 'cURL' needs to installed. This is included in linux, macOS and Windows 10. If cURL is not available, please [install from this site](https://curl.haxx.se). For Windows, the [Chocolatey method](https://chocolatey.org/packages/curl) is recommended.

Herald works with Matlab R2007a and newer. Older versions may work but have not yet been tested.

## Syntax

The following documentation assumes you created a wrapper named `herald.m`.

### Sending a message or a plot

`herald(text)` sends the message _text_ to the channel.

`herald(figHandle)` sends the figure with handle _figHandle_ as a PNG directly to the channel.

`msg = herald(...)` returns information about the message or picture sent in the struct _msg_.

### Deleting a message

`herald([], msg)` will delete the message _msg_. This can be text or a picture.

### Updating a message

`herald(text, msg)` updates the message _msg_ with the new content _text_.

Note: updating an image is currently not supported. Consider deleting the picture and sending a new one.

## Notes on using Herald

### How to obtain a chatId (using direct chat)

After starting a conversation with your custom bot, forward a message inside that conversation to [@get_id_bot](https://telegram.me/get_id_bot) and the `chatId` will be returned to you.

### How to obtain a chatId (using channels)

The `chatId` is obtained from forwarding a random message inside the dedicated channel to [@get_id_bot](https://telegram.me/get_id_bot). This channel should have your custom bot as an administrator in order to function.

### Note about wrappers

It is recommended to build a wrapper around `heraldCore()` similar to the included `heraldWrapper()`. The wrapper will forward all requests "as is" to the core herald function along with the chat id (see above).

If you choose to not use a wrapper and instead interact with the `heraldCore()` function directly, two additional arguments must be provided as such: `heraldCore(botToken, chatId, ...)`. Detailed instructions can be obtained by running `help heraldCore` in Matlab.
