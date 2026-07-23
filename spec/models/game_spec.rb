# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game do
  describe '.registry' do
    it 'registers New World' do
      expect(described_class.registry).to include('new_world' => 'Game::NewWorld')
    end
  end

  describe '.find' do
    it 'returns the profile for a registered key' do
      expect(described_class.find('new_world')).to be_a(Game::NewWorld)
    end

    it 'memoizes profile instances' do
      expect(described_class.find('new_world')).to equal(described_class.find('new_world'))
    end

    it 'raises for unknown games' do
      expect { described_class.find('fortnite') }.to raise_error(ArgumentError, /Unknown game/)
    end
  end

  describe '.for' do
    it 'returns nil for a server with no game selected' do
      expect(described_class.for(123_456)).to be_nil
    end

    it 'returns the selected game profile' do
      ServerConfig.create!(server_id: '123456', game: 'new_world')

      expect(described_class.for(123_456)).to be_a(Game::NewWorld)
    end

    it 'accepts an object with an id (Discordrb server)' do
      ServerConfig.create!(server_id: '999', game: 'new_world')
      server = Struct.new(:id).new(999)

      expect(described_class.for(server)).to be_a(Game::NewWorld)
    end
  end
end
