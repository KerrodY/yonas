# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game::NewWorld do
  it_behaves_like 'a game profile'

  subject(:profile) { described_class.new }

  it 'is named New World' do
    expect(profile.display_name).to eq('New World')
  end

  it 'registers the server status and build cleanup notifiers' do
    expect(profile.notifiers).to contain_exactly(NewWorldNotifications, PlayerBuildsTask)
  end

  it 'exposes the status page url' do
    expect(profile.status_page_url).to match(%r{\Ahttps://})
  end

  it 'serves the same data as the DATA constants during the transition' do
    expect(profile.weapons).to eq(DATA::WEAPONS)
    expect(profile.react_role_groups).to eq(DATA::REACT_ROLES)
    expect(profile.weapon_params).to eq(DATA::WEAPONS_PARAMS)
  end
end
