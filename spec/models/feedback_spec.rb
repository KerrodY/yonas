require 'rails_helper'

RSpec.describe Feedback, type: :model do
  let(:valid_attributes) do
    {
      message: 'Great bot!',
      display_name: 'TestUser',
      discord_id: 'testuser#1234',
      server_id: '123456',
      channel_id: '789012'
    }
  end

  describe 'validations' do
    it 'is valid with all required attributes' do
      feedback = described_class.new(valid_attributes)
      expect(feedback).to be_valid
    end

    it 'is invalid without message' do
      feedback = described_class.new(valid_attributes.except(:message))
      expect(feedback).not_to be_valid
      expect(feedback.errors[:message]).to include("can't be blank")
    end

    it 'is invalid without discord_id' do
      feedback = described_class.new(valid_attributes.except(:discord_id))
      expect(feedback).not_to be_valid
      expect(feedback.errors[:discord_id]).to include("can't be blank")
    end

    it 'is invalid without server_id' do
      feedback = described_class.new(valid_attributes.except(:server_id))
      expect(feedback).not_to be_valid
      expect(feedback.errors[:server_id]).to include("can't be blank")
    end
  end

  describe 'optional fields' do
    it 'is valid without display_name' do
      feedback = described_class.new(valid_attributes.except(:display_name))
      expect(feedback).to be_valid
    end

    it 'is valid without channel_id' do
      feedback = described_class.new(valid_attributes.except(:channel_id))
      expect(feedback).to be_valid
    end
  end

  describe 'persistence' do
    it 'saves and retrieves all fields' do
      feedback = described_class.create!(valid_attributes)
      reloaded = described_class.find(feedback.id)

      expect(reloaded.message).to eq('Great bot!')
      expect(reloaded.display_name).to eq('TestUser')
      expect(reloaded.discord_id).to eq('testuser#1234')
      expect(reloaded.server_id).to eq('123456')
      expect(reloaded.channel_id).to eq('789012')
    end
  end
end

