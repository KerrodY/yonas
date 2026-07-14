require 'rails_helper'

RSpec.describe CompanyApplication, type: :model do
  let(:valid_attributes) do
    {
      server_id: '123456',
      discord_name: 'testuser',
      status: 'pending',
      years_of_experience: '500',
      pvp_player: 'Yes',
      ign: 'TestPlayer',
      role: 'DPS'
    }
  end

  describe 'validations' do
    it 'is valid with all required attributes' do
      application = described_class.new(valid_attributes)
      expect(application).to be_valid
    end

    %i[server_id discord_name status years_of_experience pvp_player ign role].each do |field|
      it "is invalid without #{field}" do
        application = described_class.new(valid_attributes.except(field))
        expect(application).not_to be_valid
        expect(application.errors[field]).to include("can't be blank")
      end
    end
  end

  describe 'optional fields' do
    it 'is valid without extra_info' do
      application = described_class.new(valid_attributes.merge(extra_info: nil))
      expect(application).to be_valid
    end

    it 'is valid without online_at_launch' do
      application = described_class.new(valid_attributes.merge(online_at_launch: nil))
      expect(application).to be_valid
    end

    it 'persists extra_info when provided' do
      application = described_class.create!(valid_attributes.merge(extra_info: 'War leader experience'))
      expect(application.reload.extra_info).to eq('War leader experience')
    end
  end

  describe 'status workflow' do
    let(:application) { described_class.create!(valid_attributes) }

    it 'defaults to pending status' do
      expect(application.status).to eq('pending')
    end

    it 'can be approved' do
      application.update!(status: 'approved')
      expect(application.reload.status).to eq('approved')
    end

    it 'can be rejected' do
      application.update!(status: 'rejected')
      expect(application.reload.status).to eq('rejected')
    end
  end
end
