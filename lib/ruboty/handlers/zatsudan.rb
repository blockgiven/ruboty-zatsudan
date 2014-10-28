require 'securerandom'
require "ruboty/zatsudan/actions/zatsudan"

module Ruboty
  module Handlers
    class Zatsudan < Base
      env :DOCOMO_APIKEY, 'Docomo API key'

      on /.*/,        name: 'zatsudan', description: 'receive any 雑談', all: true, hidden: true
      on /雑談しよ/,    name: 'zatsudan_start', description: 'start 雑談'
      on /雑談もういい/, name: 'zatsudan_end',   description: 'end 雑談'

      def zatsudan_start(message)
        message.robot.brain.data[::Ruboty::Zatsudan::NAMESPACE] = {zatsudan: true}
        message.reply("OK")
      end

      def zatsudan_end(message)
        message.robot.brain.data[::Ruboty::Zatsudan::NAMESPACE] = {zatsudan: false}
        message.reply("BYE")
      end

      def zatsudan(message)
        if zatsudan?(robot)
          Ruboty::Zatsudan::Actions::Zatsudan.new(message).call
        end
      end

      def zatsudan?(robot)
        zatsudan = robot.brain.data[::Ruboty::Zatsudan::NAMESPACE] || {}
        zatsudan[:zatsudan]
      end
    end
  end
end
