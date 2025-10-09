# frozen_string_literal: true

require 'open-uri'
require 'nokogiri'
require 'rufus-scheduler'
require './app/services/discord_bot'
require './app/models/news_article'
require './app/models/update_notification'
require './lib/data'

class NewWorldNotifications
  def initialize
    @scheduler = Rufus::Scheduler.new
    @server_status_offline = false
  end

  def start
    @scheduler.every '4m' do
      Rails.logger.info "Server status checked at #{Time.zone.now} - STATUS: #{fetch_server_status.upcase}"
      check_server_status
    end

    @scheduler.every '1h' do
      article_links = fetch_article_links
      send_notifications(article_links)
    end
  end

  private

  def fetch_server_status
    html = URI.open(DATA::WEBSITE_SERVER_STATUS)
    doc = Nokogiri::HTML(html)

    container = doc.at('div.ags-ServerStatus-content-responses')
    container.at('.ags-ServerStatus-content-responses-response-server-status')['title']
  end

  def check_server_status
    if fetch_server_status == 'Offline'
      unless @server_status_offline
        notify_server_status(false)

        @server_status_offline = true
      end
    end

    if @server_status_offline
      3.times do
        return if fetch_server_status != 'Online'

        sleep(60)
      end
    end

    notify_server_status(true) if @server_status_offline

    @server_status_offline = false
  end

  def fetch_article_links
    html = URI.open('https://www.newworld.com/en-gb/news')
    doc = Nokogiri::HTML(html)

    container = doc.css('.ags-ContainerModule-container-slotModuleContainer.js-blogContainer')

    container.css('> div').map do |article|
      {
        link: "https://www.newworld.com#{article.at_css('.ags-SlotModule-slotLink')['href']}",
        title: article.at_css('.ags-SlotModule-contentContainer-heading.ags-SlotModule-contentContainer-heading.ags-SlotModule-contentContainer-heading--blog').text.strip
      }
    end
  end

  def notify_server_status(online)
    DiscordBot.instance.bot.servers.each do |server|
      announcements_channel = server.channels.find { |channel| channel.name == DATA::CHANNELS[:ANNOUNCEMENTS][:name] }

      if announcements_channel
        message = online ? "Server is back online @here" : "Server is offline @here"
        announcements_channel.send_message(message)
      end
    end
  end

  def new_news?(article_link)
    article_link[:link] != NewsArticle.first&.url
  end

  def send_notifications(article_links)
    article_links.each do |article|
      break unless new_news?(article)

      UpdateNotification.all.find_each do |channel|
        discord_channel = DiscordBot.instance.bot.channel(channel.channel_id)
        discord_channel.send_message("[#{article[:title]}](#{article[:link]})")
      end
    end

    NewsArticle.upsert({ url: article_links.first[:link], id: 1 }, unique_by: :id)
  end
end