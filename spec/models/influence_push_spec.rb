# frozen_string_literal: true

# require 'rspec'
require './app/models/influence_push.rb'

RSpec.describe 'InfluencePush' do
  before do
    InfluencePush.create!(player: 'zorushi', role: 'dps', armour_weight: 'light')
    InfluencePush.create!(player: 'frank', role: 'mage', armour_weight: 'medium')
    InfluencePush.create!(player: 'george', role: 'dps', armour_weight: 'heavy')
    InfluencePush.create!(player: 'bill', role: 'mage', armour_weight: 'light')
    InfluencePush.create!(player: 'willy', role: 'healer', armour_weight: 'light')
    InfluencePush.create!(player: 'hank', role: 'dps', armour_weight: 'light')
    InfluencePush.create!(player: 'jake', role: 'dps', armour_weight: 'light')
    InfluencePush.create!(player: 'jack', role: 'tank', armour_weight: 'medium')
    InfluencePush.create!(player: 'silly', role: 'dps', armour_weight: 'heavy')
    InfluencePush.create!(player: 'taylor', role: 'dps', armour_weight: 'light')
    InfluencePush.create!(player: 'gill', role: 'dps', armour_weight: 'light')
    InfluencePush.create!(player: 'gerty', role: 'dps', armour_weight: 'medium')
    InfluencePush.create!(player: 'foo', role: 'healer', armour_weight: 'heavy')
  end

  after do
    # Do nothing
  end

  context 'when condition' do
    it 'succeeds' do
      groups = InfluencePush.new.create_pvp_groups


    end
  end
end
