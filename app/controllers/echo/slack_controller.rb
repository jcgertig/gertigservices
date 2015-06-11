class Echo::SlackController < ApplicationController
  def handle
    Slack.configure do |config|
      config.token = ENV["SLACK_SECRET"]
    end

    listening = params["session"]["attributes"]["listening"]

    attributes = { "listening": listening }

    if listening.nil? || listening == false
      attributes["listening"] = true

      client = Slack.realtime

      client.on :hello do
        logger.info 'Successfully connected.'
      end

      client.on :message do |data|
        render json: {
          "version": "1.0",
          "sessionAttributes": attributes,
          "response": {
            "outputSpeech": {
              "type": "PlainText",
              "text": data["text"]
            },
            "shouldEndSession": false
          }
        }
      end

      client.start
    end

    request = params["request"]
    if request["type"] == "IntentRequest"
      handleIntent(Slack, request["intent"])
      message = "sent message"
    else
      message = "thanks for using slack app for echo"
    end

    render json: {
      "version": "1.0",
      "sessionAttributes": attributes,
      "response": {
        "outputSpeech": {
          "type": "PlainText",
          "text": message
        },
        "shouldEndSession": false
      },
    }

  end


  private

    def handleIntent(Slack, intent)
      name = intent["name"]
      message = intent["slots"]["message"]["value"]
      if name == "SendMessage"
        Slack.chat_postMessage text: message
      elsif name == "SendMessageToRoom"
        Slack.chat_postMessage channel: intent["slots"]["channelName"]["value"], text: message
      end
    end
end
