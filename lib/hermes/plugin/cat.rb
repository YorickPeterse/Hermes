require_relative 'cat/yorickpeterse'
require_relative 'cat/katylava'
require_relative 'cat/nirix'
require_relative 'cat/jwa'

module Hermes
  module Plugin
    ##
    # The Cat plugin retrieves the latest cat picture or video from a list of
    # pre-defined Atom/RSS feeds.
    #
    class Cat
      include Cinch::Plugin

      set :help => 'cat [NAME] - Retrieves the latest entry of an RSS/Atom ' \
        'feed with cat pictures and/or videos.',
        :plugin_name => 'cat'

      ##
      # Hash containing the available feeds and their parsers.
      #
      # @return [Hash]
      #
      FEEDS = {
        'yorickpeterse' => Hermes::Plugin::Cat::Yorickpeterse,
        'katylava'      => Hermes::Plugin::Cat::Katylava,
        'nirix'         => Hermes::Plugin::Cat::Nirix,
        'jwa'           => Hermes::Plugin::Cat::Jwa,
      }

      match(/cat\s+(\S+)/)

      ##
      # Executes the plugin.
      #
      # @param [Cinch::Message] message
      # @param [String] feed The name of the feed to process.
      #
      def execute(message, feed)
        unless FEEDS.key?(feed)
          message.reply('The specified feed does not exist', true)

          return
        end

        unless FEEDS[feed].const_defined?(:URL)
          message.reply(
            'The specified feed does not have a URL specified',
            true
          )
        end

        response = Hermes.http.get(FEEDS[feed]::URL)

        unless response.ok?
          message.reply(
            "Failed to retrieve the feed data. HTTP response: " \
              "#{response.code} #{response.body}",
            true
          )

          return
        end

        url, title, date = FEEDS[feed].parse(response.body)

        if url and title and date
          formatted_date = date.strftime(Hermes::DATE_TIME_FORMAT)

          message.reply("#{title} at #{formatted_date}: #{url}", true)
        else
          message.reply('Failed to retrieve the URL, title and/or date', true)
        end
      end
    end # Cat
  end # Plugin
end # Hermes
