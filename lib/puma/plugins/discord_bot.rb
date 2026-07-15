# frozen_string_literal: true

require "puma/plugin"

# Starts the Discord bot and scheduled tasks once puma has booted and is
# serving requests. Running this as a puma plugin (rather than a Rails
# initializer) means the bot only ever starts alongside a real web server —
# never during rake tasks, asset precompilation, tests, or the console — and
# its slow Discord setup can't block the app from answering health checks.
Puma::Plugin.create do
  def start(launcher)
    launcher.events.on_booted do
      Thread.new do
        Rails.logger.info "Starting up New World Notifications..."
        NewWorldNotifications.new.start

        Rails.logger.info "Starting up pvp_build tasks..."
        PlayerBuildsTask.new.start

        Rails.logger.info "Starting up discord bot..."
        DiscordBot.instance
      rescue StandardError => e
        Rails.logger.error "Discord bot failed to start: #{e.class}: #{e.message}"
        Rails.logger.error e.backtrace&.join("\n")
      end
    end
  end
end
