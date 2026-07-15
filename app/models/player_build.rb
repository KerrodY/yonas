class PlayerBuild < ApplicationRecord
  def self.remove_pvp_build(event)
    PlayerBuild.where(discord_id: event.user.username, server_id: event.server.id).destroy_all
  end

  def self.search_for_builds(event)
    params = event.options
    server_id = event.server.id
    if params["weapon1"] && params["weapon2"]
      query = build_both_weapons_query(params, server_id)
      PlayerBuild.where(query).empty? ? nil : PlayerBuild.where(query)
    elsif params["weapon1"] || params["weapon2"]
      query_1 = build_weapon1_query(params, server_id)
      query_2 = build_weapon2_query(params, server_id)
      results_1 = PlayerBuild.where(query_1)
      results_2 = PlayerBuild.where(query_2)

      results = results_1 + results_2

      results.empty? ? nil : results
    else
      query = build_weapon1_query(params, server_id)
      PlayerBuild.where(query).empty? ? nil : PlayerBuild.where(query)
    end
  end

  def self.build_weapon1_query(params, server_id)
    query = {}
    query["weapon1"] = [params["weapon1"], params["weapon2"]] if params["weapon1"] || params["weapon2"]
    query.merge(add_other_params(params, server_id))
  end

  def self.build_weapon2_query(params, server_id)
    query = {}
    query["weapon2"] =  [params["weapon1"], params["weapon2"]] if params["weapon1"] || params["weapon2"]
    query.merge(add_other_params(params, server_id))
  end

  def self.build_both_weapons_query(params, server_id)
    query = {}
    query["weapon1"] = [params["weapon1"], params["weapon2"]] if params["weapon1"] || params["weapon2"]
    query["weapon2"] =  [params["weapon1"], params["weapon2"]] if params["weapon1"] || params["weapon2"]
    query.merge(add_other_params(params, server_id))
  end

  def self.add_other_params(params, server_id, query = {})
    query["heartrune"] = params["heartrune"] if params["heartrune"]
    query["armour_weight"] = params["armour_weight"] if params["armour_weight"]
    query["player"] = params["player"].downcase if params["player"]
    query["guest"] = params["guest"] || false
    query["server_id"] = server_id

    query
  end
end
