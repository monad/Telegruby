require 'httmultiparty'
require 'json'

module Telegruby
  class Bot
    attr_accessor :id

    def initialize(api_token)
      @token = api_token
      @endpoint = "https://api.telegram.org/bot#{@token}/"
      @id = 0
    end

    # See https://core.telegram.org/bots/api for the full method list

    def get_updates(options = {}, error_callback = nil)
      if options == {}
        options = {
          :offset => @id
        }
      end

      request = self.get_request("getUpdates", options)
      if request.code != 200
        return error_callback request
      end
      update = Update.new(JSON.parse(request.body, object_class: OpenStruct))
      
      if !update.result.empty?
        # there are updates, so mark them as 'seen'
        @id = (update.result.last.update_id + 1)
      end
      
      return update
    end

    # Send a plaintext message to a chat id
    def send_message(id, text, reply: nil, parse_mode: nil)
      options = {
        :chat_id => id,
        :text => text
      }

      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      if !parse_mode.nil?
        options.merge!(:parse_mode => parse_mode)
      end
      
      self.get_request("sendMessage", options)
    end

    def forward_message(id, from_id, message_id)
      options = {
        :chat_id => id,
        :from_chat_id => from_id,
        :message_id => message_id
      }

      self.get_request("forwardMessage", options)
    end
   
    # Sends a photo message to a chat id
    def send_photo(id, filename: nil, file_id: nil, reply: nil)
      options = {
        :chat_id => id,
      }
      if file_id
        options.merge!(:photo => file_id)
      else
        options.merge!(:photo => File.new(filename))
      end
     
      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      self.post_request("sendPhoto", options)
    end

    # Sends a photo from a byte string
    def send_photo_bytestring(id, str, reply: nil)
      Tempfile.open(["img", ".jpg"]) { |f|
        f.binmode
        f.write(str)
       
        self.send_photo(id, filename: f.path, reply: reply)
      }
    end

    def send_voice(id, filename: nil, file_id: nil, reply: nil)
      options = {
        :chat_id => id,
      }
      if file_id
        options.merge!(:audio => file_id)
      else
        options.merge!(:audio => File.new(filename))
      end
     
      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      self.post_request("sendVoice", options)
    end

    def send_sticker(id, file_id: nil, filename: nil, reply: nil)
      options = {
        :chat_id => id,
      }
      if file_id
        options.merge!(:sticker => file_id)
      else
        options.merge!(:sticker => File.new(filename))
      end

      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      self.post_request("sendSticker", options)
    end

    def send_audio(id, filename: nil, file_id: nil, reply: nil)
      options = {
        :chat_id => id,
      } 
      if file_id
        options.merge!(:audio => file_id)
      else
        options.merge!(:audio => File.new(filename))
      end

      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      self.post_request("sendAudio", options)
    end

    def send_video(id, filename: nil, file_id: nil, reply: nil)
      options = {
        :chat_id => id,
      }
      if file_id
        options.merge!(:video => file_id)
      else
        options.merge!(:video => File.new(filename))
      end

      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      self.post_request("sendVideo", options)
    end

    def send_location(id, lat, long, reply: nil)
      options = {
        :chat_id => id,
        :latitude => lat,
        :longitude => long
      }
      
      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      self.post_request("sendLocation", options)
    end
    
    def send_action(id, action)
      options = {
        :chat_id => id,
        :action => action
      }
      
      return self.post_request("sendChatAction", options)
    end

    # Sends a document by filename or file ID
    def send_document(id, filename: nil, file_id: nil, reply: nil)
      options = {
        :chat_id => id
      }
      
      if file_id
        options.merge!(:document => file_id)
      else
        options.merge!(:document => File.new(filename))
      end

      if !reply.nil?
        options.merge!(:reply_to_message_id => reply)
      end

      return self.post_request("sendDocument", options)
    end
    
    def get_userphoto(id, offset: nil, limit: nil)
      options = {
        :user_id => id,
        :offset => offset,
        :limit => limit
      }
      
      return self.get_request("getUserProfilePhotos", options)
    end
    
    def set_webhook(url = nil, certificate = nil)
      options = {
        :url => nil,
      }
      if certificate
        options.merge!(:certificate => File.new(certificate))
      end
      
      return self.get_request("setWebhook", options)
    end

    protected

    # Provides a generic method for GET requests.
    def get_request(name, options = {})
      HTTMultiParty::get(@endpoint + name, query: options)
    end

    # Provides a generic method for POST requests.
    def post_request(name, options = {})
      HTTMultiParty::post(@endpoint + name, query: options).body
    end
  end

  module_function

  # Reads an API token from a JSON file.
  # The result of this should be
  # passed to Telegruby::Bot.new
  def read_config(filename)
    begin
      data = JSON.parse(File.read(filename))

      if !data.key? "token"
        return false
      end

      return data
    rescue
      return false
    end
  end

  # Given an Update object, gets messages as structs.
  def collect_msgs(update)
    update.result.map { |msg|
      Message.new(msg)
    }
  end

  # Update object generated by
  # Telegruby::Bot::get_updates
  class Update < OpenStruct
    def results?
      !self.result.empty?
    end
  end

  # Message structure generated by
  # collect_msgs from an update hash.
  # Has some convenience methods.
  class Message < OpenStruct
    def initialize(hash_msg)
      super(hash_msg)
    end

    def timestamp
      self.message.date
    end

    def older_than?(secs)
      ((Time.now.to_i - self.timestamp) > secs)
    end

    def chat_id
      self.message.chat.id
    end

    def body
      self.message.text
    end

    def message_id
      self.message.message_id
    end
  end
end
