require 'rails_helper'

RSpec.describe PlayerBuild, type: :model do
  let(:valid_attributes) do
    {
      server_id: '123456',
      player: 'TestPlayer',
      weapon_1: 'Great Axe',
      weapon_2: 'War Hammer',
      armour_weight: 'heavy',
      heartrune: 'detonate',
      role: 'dps',
      discord_id: 'testuser',
      guest: false
    }
  end

  describe 'database constraints' do
    it 'is valid with all required attributes' do
      build = described_class.new(valid_attributes)
      expect(build).to be_valid
    end

    it 'enforces unique player per server' do
      described_class.create!(valid_attributes)

      duplicate = described_class.new(valid_attributes.merge(discord_id: 'otheruser'))
      expect { duplicate.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'enforces unique discord_id per server' do
      described_class.create!(valid_attributes)

      duplicate = described_class.new(valid_attributes.merge(player: 'OtherPlayer'))
      expect { duplicate.save! }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows same player name on different servers' do
      described_class.create!(valid_attributes)

      other_server = described_class.new(valid_attributes.merge(server_id: '999999', discord_id: 'otheruser'))
      expect { other_server.save! }.not_to raise_error
    end

    it 'allows same discord_id on different servers' do
      described_class.create!(valid_attributes)

      other_server = described_class.new(valid_attributes.merge(server_id: '999999', player: 'OtherPlayer'))
      expect { other_server.save! }.not_to raise_error
    end

    it 'defaults guest to false' do
      build = described_class.create!(valid_attributes.except(:guest))
      expect(build.reload.guest).to be false
    end
  end

  describe '.remove_pvp_build' do
    it 'destroys all builds for the given user and server' do
      build = described_class.create!(valid_attributes)

      event = double('event',
        user: double('user', username: 'testuser'),
        server: double('server', id: '123456')
      )

      described_class.remove_pvp_build(event)

      expect(described_class.find_by(id: build.id)).to be_nil
    end

    it 'does not destroy builds for other users' do
      described_class.create!(valid_attributes)
      other_build = described_class.create!(valid_attributes.merge(
        player: 'OtherPlayer', discord_id: 'otheruser'
      ))

      event = double('event',
        user: double('user', username: 'testuser'),
        server: double('server', id: '123456')
      )

      described_class.remove_pvp_build(event)

      expect(described_class.find_by(id: other_build.id)).not_to be_nil
    end
  end

  describe '.search_for_builds' do
    let!(:axe_hammer_build) do
      described_class.create!(valid_attributes)
    end

    let!(:bow_spear_build) do
      described_class.create!(valid_attributes.merge(
        player: 'Archer', discord_id: 'archer',
        weapon_1: 'Bow', weapon_2: 'Spear',
        role: 'ranged_dps', armour_weight: 'light'
      ))
    end

    let(:server) { double('server', id: '123456') }

    it 'searches by weapon_1 only' do
      event = double('event',
        options: { 'weapon_1' => 'Great Axe' },
        server: server
      )

      results = described_class.search_for_builds(event)

      expect(results).to include(axe_hammer_build)
      expect(results).not_to include(bow_spear_build)
    end

    it 'searches by weapon_2 only' do
      event = double('event',
        options: { 'weapon_2' => 'Spear' },
        server: server
      )

      results = described_class.search_for_builds(event)

      expect(results).to include(bow_spear_build)
    end

    it 'searches by both weapons' do
      event = double('event',
        options: { 'weapon_1' => 'Great Axe', 'weapon_2' => 'War Hammer' },
        server: server
      )

      results = described_class.search_for_builds(event)

      expect(results).to include(axe_hammer_build)
    end

    it 'searches by armour_weight' do
      event = double('event',
        options: { 'armour_weight' => 'light' },
        server: server
      )

      results = described_class.search_for_builds(event)

      expect(results).to include(bow_spear_build)
      expect(results).not_to include(axe_hammer_build)
    end

    it 'returns nil when no matches found' do
      event = double('event',
        options: { 'weapon_1' => 'Life Staff' },
        server: server
      )

      results = described_class.search_for_builds(event)

      expect(results).to be_nil
    end
  end
end

