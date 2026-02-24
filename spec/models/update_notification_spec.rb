require 'rails_helper'

RSpec.describe UpdateNotification, type: :model do
  describe 'persistence' do
    it 'saves with a channel_id' do
      notification = described_class.create!(channel_id: '123456789')
      expect(notification).to be_persisted
      expect(notification.channel_id).to eq('123456789')
    end
  end

  describe 'unique channel_id constraint' do
    it 'enforces uniqueness on channel_id' do
      described_class.create!(channel_id: '123456789')

      expect { described_class.create!(channel_id: '123456789') }
        .to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'allows different channel_ids' do
      described_class.create!(channel_id: '123456789')

      expect { described_class.create!(channel_id: '987654321') }
        .not_to raise_error
    end
  end

  describe 'subscription management' do
    it 'can subscribe a channel' do
      described_class.create!(channel_id: '111')
      described_class.create!(channel_id: '222')

      expect(described_class.count).to eq(2)
    end

    it 'can unsubscribe a channel by channel_id' do
      described_class.create!(channel_id: '111')
      described_class.create!(channel_id: '222')

      described_class.where(channel_id: '111').delete_all

      expect(described_class.count).to eq(1)
      expect(described_class.first.channel_id).to eq('222')
    end

    it 'iterates over all subscribed channels' do
      described_class.create!(channel_id: '111')
      described_class.create!(channel_id: '222')
      described_class.create!(channel_id: '333')

      channel_ids = []
      described_class.all.find_each { |n| channel_ids << n.channel_id }

      expect(channel_ids).to contain_exactly('111', '222', '333')
    end
  end
end

