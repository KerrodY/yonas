# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ServerConfig, type: :model do
  describe 'validations' do
    it 'is valid with a server id and registered game' do
      expect(described_class.new(server_id: '123', game: 'new_world')).to be_valid
    end

    it 'requires a server id' do
      expect(described_class.new(game: 'new_world')).not_to be_valid
    end

    it 'rejects unregistered games' do
      expect(described_class.new(server_id: '123', game: 'fortnite')).not_to be_valid
    end

    it 'rejects duplicate server ids' do
      described_class.create!(server_id: '123', game: 'new_world')

      expect(described_class.new(server_id: '123', game: 'new_world')).not_to be_valid
    end
  end

  describe '.backfill!' do
    let(:servers) { { 1 => Struct.new(:id).new(111), 2 => Struct.new(:id).new(222) } }

    it 'marks every existing server as new world when no configs exist' do
      described_class.backfill!(servers)

      expect(described_class.pluck(:server_id, :game))
        .to contain_exactly(%w[111 new_world], %w[222 new_world])
    end

    it 'does nothing once any config exists, so new servers still select' do
      described_class.create!(server_id: '999', game: 'new_world')

      expect { described_class.backfill!(servers) }.not_to change(described_class, :count)
    end
  end
end
