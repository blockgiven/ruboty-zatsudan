require 'faraday'
require 'json'

module Ruboty
  module Zatsudan
    module Actions
      class Zatsudan < Ruboty::Actions::Base
        def call
          message.reply(zatsudan(message.body))
        rescue => e
          message.reply(e.message)
        end

        private

        def zatsudan_api_url
          'https://api.apigw.smt.docomo.ne.jp'
        end

        def zatsudan_api_key
          ENV['DOCOMO_APIKEY']
        end

        def zatsudan(utt)
          res = connection.post do |req|
            req.url "/dialogue/v1/dialogue?APIKEY=#{zatsudan_api_key}"
            req.headers['Content-Type'] = 'application/json'
            if context && mode
              req.body = JSON.generate(utt: utt, nickname: message.from_name, mode: mode, context: context)
            else
              req.body = JSON.generate(utt: utt, nickname: message.from_name)
            end
          end

          zatsudan_reply = JSON.parse(res.body)

          self.context = zatsudan_reply['context']
          self.mode    = zatsudan_reply['mode']

          zatsudan_reply['utt']
        end

        def connection
          @connection ||= Faraday.new(url: zatsudan_api_url) do |faraday|
            faraday.adapter Faraday.default_adapter
          end
        end

        def mode=(mode)
          message.robot.brain.data[::Ruboty::Zatsudan::NAMESPACE][:mode] = mode
        end

        def mode
          message.robot.brain.data[::Ruboty::Zatsudan::NAMESPACE][:mode]
        end

        def context=(context)
          message.robot.brain.data[::Ruboty::Zatsudan::NAMESPACE][:context] = context
        end

        def context
          message.robot.brain.data[::Ruboty::Zatsudan::NAMESPACE][:context]
        end
      end
    end
  end
end
