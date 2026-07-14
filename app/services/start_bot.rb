# frozen_string_literal: true

class StartBot
  attr_reader :bot

  def initialize
    # Load the Discord bot token from Rails credentials
    bot_token = Rails.configuration.discord_bot_api_key
    @bot = Discordrb::Commands::CommandBot.new token: bot_token, prefix: '/'

    @bot.ready do
      Rails.logger.info "Bot is online and ready as #{@bot.profile.username}"
      Rails.logger.debug "Bot is online and ready as #{@bot.profile.username}"
    end

    @bot.run(true)
  end
end
