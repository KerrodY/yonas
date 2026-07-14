require 'rails_helper'

RSpec.describe InfluencePushRegistration, type: :model do
  let(:valid_attributes) do
    {
      discord_id: 'testuser',
      server_id: '123456',
      territory: 'Everfall',
      time: Time.zone.today
    }
  end

  describe 'persistence' do
    it 'saves with all attributes' do
      registration = described_class.create!(valid_attributes)
      expect(registration).to be_persisted
    end

    it 'stores territory and time correctly' do
      registration = described_class.create!(valid_attributes)
      reloaded = described_class.find(registration.id)

      expect(reloaded.territory).to eq('Everfall')
      expect(reloaded.time).to eq(Time.zone.today)
    end
  end

  describe 'querying' do
    before do
      described_class.create!(valid_attributes)
      described_class.create!(valid_attributes.merge(discord_id: 'otheruser'))
      described_class.create!(valid_attributes.merge(territory: 'Windsward'))
      described_class.create!(valid_attributes.merge(server_id: '999999'))
    end

    it 'filters by server_id' do
      results = described_class.where(server_id: '123456')
      expect(results.count).to eq(3)
    end

    it 'filters by territory' do
      results = described_class.where(territory: 'Everfall')
      expect(results.count).to eq(3)
    end

    it 'filters by date' do
      results = described_class.where('DATE(time) = ?', Time.zone.today)
      expect(results.count).to eq(4)
    end

    it 'can check for existing registrations by discord_id, server, date, and territory' do
      exists = described_class.where(server_id: '123456', discord_id: 'testuser')
                              .where('DATE(time) = ?', Time.zone.today)
                              .where(territory: 'Everfall')
                              .exists?

      expect(exists).to be true
    end

    it 'returns false for non-existing registrations' do
      exists = described_class.where(server_id: '123456', discord_id: 'unknownuser')
                              .where('DATE(time) = ?', Time.zone.today)
                              .where(territory: 'Everfall')
                              .exists?

      expect(exists).to be false
    end
  end

  describe 'attendance stats' do
    it 'counts distinct push events per server' do
      described_class.create!(valid_attributes)
      described_class.create!(valid_attributes.merge(discord_id: 'user2'))
      described_class.create!(valid_attributes.merge(territory: 'Windsward'))

      races = described_class.select(:time, :territory, :server_id)
                             .where(server_id: '123456')
                             .distinct
                             .count

      expect(races).to eq(2)
    end
  end
end
