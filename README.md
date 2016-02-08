# Telegruby

[![Gem Version](https://badge.fury.io/rb/telegruby.svg)](https://badge.fury.io/rb/telegruby)

Telegram Bot Api library for Ruby. See https://core.telegram.org/bots/api.

Every method and data structure is supported.

Classes:

`Bot`: a bot associated with a token.
`Message`: a message structure returned by getUpdates.

Every data type is represented as a `OpenStruct` object.
For example, to create a `ReplyKeyboardMarkup` object to pass to `send_message`:
```
kdb = { 
  :keyboard => [[ "a" ], [ "b" ]],
  :selective => true,
  :one_time_keyboard => true,
}
bot.send_message(chat_id, text, reply_markup: kdb)
```

Methods:
    
    Mandatory arguments are given in their order; optional arguments are given as `key: value` pairs,
        e.g. send_message(chat_id, "text", reply: msg.message_id) after mandatory arguments.
    Note that `reply_to_message` is `reply` for every method.

`Bot.new(token)`: creates a new [bot](https://core.telegram.org/bots) with [authentication token](https://core.telegram.org/bots#botfather).
`send_message`: [sendMessage](https://core.telegram.org/bots/api#sendmessage)
 note: `disable_web_page_preview` is `disable_preview`
`send_photo`: [sendPhoto](https://core.telegram.org/bots/api#sendphoto)
`send_photo_bytestring(chat_id, data, reply:)`: send binary `data` as jpg image
`send_audio`: [sendAudio](https://core.telegram.org/bots/api#sendaudio)
`send_document`: [sendDocument](https://core.telegram.org/bots/api#senddocument)
`send_sticker`: [sendSticker](https://core.telegram.org/bots/api#sendsticker)
`send_video`: [sendVideo](https://core.telegram.org/bots/api#sendvideo)
`send_voice`: [sendVoice](https://core.telegram.org/bots/api#sendvoice)
`send_location`: [sendLocation](https://core.telegram.org/bots/api#sendlocation)
`send_action`: [sendChatAction](https://core.telegram.org/bots/api#sendchataction)
`get_userphotos`: [getUserProfilePhotos](https://core.telegram.org/bots/api#getuserprofilephotos)
`get_updates(callback:)`: [getUpdates](https://core.telegram.org/bots/api#getupdates)
 note: the optional argument `callback:` is called on http error with the request body as the only argument.
`set_webhook`: [setWebhook](https://core.telegram.org/bots/api#setwebhook)
`get_file`: [getFile](https://core.telegram.org/bots/api#getfile)
`answer_inline_query`: [answerInlineQuery](https://core.telegram.org/bots/api#answerinlinequery)

## Examples
See in the examples/ folder for a minimal bot using the API; also see https://github.com/webgiorno/lainbot for a full bot.
