require_relative 'application_record'
require 'byebug'

  class InfluencePush < ApplicationRecord

    def create_pvp_groups
      healers = get_healers.map { |record| { player: record[:player], role: record[:role] } }
      everyone_else  = get_everyone_but_healers.map { |record| { player: record[:player], role: record[:role] } }.shuffle

      total_players = healers.count + everyone_else.count

      all_players = healers + everyone_else
      needed_groups = (total_players / 5.to_f).ceil

      split_into_groups(all_players, needed_groups)
    end

    def delete_pvp_groups
      InfluencePush.destroy_all
    end

    private

    def split_into_groups(objects, num_groups)
      groups = Hash.new { |hash, key| hash[key] = [] }

      objects.each_with_index do |obj, index|
        group_index = index % num_groups
        groups[group_index] << obj
      end

      groups
    end

    def get_healers
      InfluencePush.where(role: 'healer')
    end

    def get_everyone_but_healers
      InfluencePush.where.not(role: 'healer')
    end
  end

