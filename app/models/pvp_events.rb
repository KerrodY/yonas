class PvpEvents < ApplicationRecord


  def create_pvp_groups(event)
    PvpEvents.destroy_all!

    create_pvpers(event)

    healers = get_healers.map { |record| { player: record[:player], role: record[:role]}}.shuffle
    melee_dps = get_melee_dps.map { |record| { player: record[:player], role: record[:role]}}.shuffle
    ranged_dps = get_ranged_dps.map { |record| { player: record[:player], role: record[:role]}}.shuffle
    mages = get_mages.map { |record| { player: record[:player], role: record[:role]}}.shuffle
    tanks = get_tanks.map { |record| { player: record[:player], role: record[:role]}}.shuffle

    all_players = healers + melee_dps + ranged_dps + mages + tanks

    split_into_groups(all_players)
  end

    private

  def create_pvpers(event)
    user_channel = event.user.voice_channel
    unless user_channel
      event.channel.send_message("You need to be in a voice channel to create PvP groups.")

      return
    end

    user_channel.users.each do |user|
      player_build = PlayerBuild.find_by(discord_id: user.username)
      if player_build
        PvpEvents.create!(player: player_build.player, role: player_build.role)
      else
        event.channel.send_message("#{user.display_name} does not have a registered build, skipping them.")
      end
    end
  end

  def split_into_groups(participants)
    groups = Hash.new { |hash, key| hash[key] = [] }

    participants.each_with_index do |obj, index|
      group_index = index % (participants.count / 5.0).ceil

      groups[group_index] << obj
    end

    groups
  end

  def get_healers
    PvpEvents.where(role: 'healer')
  end

  def get_ranged_dps
    PvpEvents.where(role: 'dps')
  end

  def get_melee_dps
    PvpEvents.where(role: 'ranged_dps')
  end

  def get_mages
    PvpEvents.where(role: 'mage')
  end

  def get_tanks
    PvpEvents.where(role: 'tank')
  end
end
