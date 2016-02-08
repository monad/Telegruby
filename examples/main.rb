#!/usr/bin/env ruby
# coding: utf-8
require 'telegruby'

# Please see https://github.com/webgiorno/lainbot for a full bot example.

token = "TOKEN"
botname = "BOTNAME"
bot = Telegruby::Bot.new(token)

def handle(bot, msg, pattern, cb)
  result = msg.body.match pattern
  if !result.nil?
    Thread.new {
      cb.call(bot, msg, result)
    }
  end
end

# Listener thread
while true
  # Collect messages from last update
  msgs = Telegruby::collect_msgs(bot.get_updates)
  # Process each message
  msgs.map { |msg|
    if !msg.older_than? 120 and !msg.body.nil?
      handle bot, msg, /^\/echo\s+(.*)$/i, lambda { |b,m,p|
        bot.send_message(msg.chat_id, p.last.to_s)
      }
      handle bot, msg, /^\/reply\s+(.*)$/i, lambda { |b,m,p|
        bot.send_message(msg.chat_id, p.last, reply: msg.message_id)
      }
      handle bot, msg, /^\/forward\s+(.*)$/i, lambda { |b,m,p|
        bot.forward_message(msg.chat_id, p[0].to_i, p[1])
      }
      handle bot, msg, /^\/photo\s+(.*)$/i, lambda { |b,m,p|
        bot.send_photo(msg.chat_id, file_id: 'AgADBAAD8q4xG_t1NQNr1qCkgB1z0XsJcTAABMviIGhAD2pcVcsAAgI')
      }
      handle bot, msg, /^\/document\s+(.*)$/i, lambda { |b,m,p|
       bot.send_sticker(msg.chat_id, file_id: 'BQADBAADOwAD5F8pBUmCNsa7w0MtAg')
      }
      handle bot, msg, /^\/sticker$/i, lambda { |b,m,p|
        bot.send_photo(msg.chat_id, file_id: 'BQADBAADnisAAqSBEQQwpt5aHlqUjQI')
      }
      handle bot, msg, /^\/voice$/i, lambda { |b,m,p|
        bot.send_voice(msg.chat_id, filename: 'voice.ogg')
      }
      handle bot, msg, /^\/audio$/i, lambda { |b,m,p|
        bot.send_voice(msg.chat_id, file_id: 'BQADAQADOwADzCUmCB0806CJnCuiAg')
      }
      handle bot, msg, /^\/location$/i, lambda { |b,m,p|
        bot.send_location(msg.chat_id, 53.37, 83.75)
      }
      handle bot, msg, /^\/action\s+(.*)$/i, lambda { |b,m,p|
        res = bot.send_action(msg.chat_id, p.last)
        bot.send_message(msg.chat_id, res)
      }
      handle bot, msg, /^\/version$/i, lambda { |b,m,p|
        bot.send_message(msg.chat_id, "Telegruby · http://github.com/webgiorno/telegruby")
      }
    end
  }
  # Sleep before asking for updates
  sleep 2
end
