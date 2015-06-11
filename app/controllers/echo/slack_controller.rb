class Echo::SlackController < ApplicationController
  skip_before_action :verify_authenticity_token

  def handle
    Slack.configure do |config|
      config.token = ENV["SLACK_SECRET"]
    end

    # listening = params["session"]["attributes"]["listening"]

    attributes = {  }

    # if listening.nil? || listening == false
    #   attributes["listening"] = true
    #
    #   client = Slack.realtime
    #
    #   client.on :hello do
    #     logger.info 'Successfully connected.'
    #   end
    #
    #   client.on :message do |data|
    #     render json: {
    #       "version" => "1.0",
    #       "sessionAttributes" => attributes,
    #       "response" => {
    #         "outputSpeech" => {
    #           "type" => "PlainText",
    #           "text" => data["text"]
    #         },
    #         "shouldEndSession" => false
    #       }
    #     }
    #   end
    #
    #   client.start
    # end

    request = params["request"]
    if request["type"] == "IntentRequest"
      handleIntent(Slack, request["intent"])
      message = "sent message"
    else
      message = "thanks for using slack app for echo"
    end

    render json: {
      "version" => "1.0",
      "sessionAttributes" => attributes,
      "response" => {
        "outputSpeech" => {
          "type" => "PlainText",
          "text" => message
        },
        "shouldEndSession" => false
      },
    }

  end


  private

    def handleIntent(slack, intent)
      name = intent["name"]
      message = intent["slots"]["message"]["value"]
      if name == "SendMessage"
        slack.chat_postMessage channel: '#general', text: message
      elsif name == "SendMessageToRoom"
        slack.chat_postMessage channel: "##{intent["slots"]["channelName"]["value"]}", text: message
      end
    end
end
