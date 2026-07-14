require 'rails_helper'

RSpec.describe PvpEvents, type: :model do
  describe 'persistence' do
    it 'saves with player and role' do
      event = described_class.create!(player: 'TestPlayer', role: 'dps')
      expect(event).to be_persisted
      expect(event.player).to eq('TestPlayer')
      expect(event.role).to eq('dps')
    end

    it 'saves with optional armour_weight' do
      event = described_class.create!(player: 'TestPlayer', role: 'tank', armour_weight: 'heavy')
      expect(event.reload.armour_weight).to eq('heavy')
    end
  end

  describe '#split_into_groups' do
    let(:pvp_event) { described_class.new }

    it 'splits 10 players into 2 groups of 5' do
      participants = (1..10).map { |i| { player: "Player#{i}", role: 'dps' } }

      groups = pvp_event.send(:split_into_groups, participants)

      expect(groups.keys.size).to eq(2)
      expect(groups.values.map(&:size)).to all(eq(5))
    end

    it 'splits 5 players into 1 group' do
      participants = (1..5).map { |i| { player: "Player#{i}", role: 'dps' } }

      groups = pvp_event.send(:split_into_groups, participants)

      expect(groups.keys.size).to eq(1)
      expect(groups[0].size).to eq(5)
    end

    it 'handles uneven player counts' do
      participants = (1..7).map { |i| { player: "Player#{i}", role: 'dps' } }

      groups = pvp_event.send(:split_into_groups, participants)

      total_players = groups.values.sum(&:size)
      expect(total_players).to eq(7)
    end

    it 'returns empty hash for no participants' do
      groups = pvp_event.send(:split_into_groups, [])

      expect(groups).to be_empty
    end
  end

  describe 'role queries' do
    let(:pvp_event) { described_class.new }

    before do
      described_class.create!(player: 'Healer1', role: 'healer')
      described_class.create!(player: 'Healer2', role: 'healer')
      described_class.create!(player: 'Tank1', role: 'tank')
      described_class.create!(player: 'DPS1', role: 'dps')
      described_class.create!(player: 'RangedDPS1', role: 'ranged_dps')
      described_class.create!(player: 'Mage1', role: 'mage')
    end

    it 'fetches healers' do
      healers = pvp_event.send(:get_healers)
      expect(healers.count).to eq(2)
      expect(healers.map(&:player)).to contain_exactly('Healer1', 'Healer2')
    end

    it 'fetches tanks' do
      tanks = pvp_event.send(:get_tanks)
      expect(tanks.count).to eq(1)
      expect(tanks.first.player).to eq('Tank1')
    end

    it 'fetches mages' do
      mages = pvp_event.send(:get_mages)
      expect(mages.count).to eq(1)
      expect(mages.first.player).to eq('Mage1')
    end
  end
end
