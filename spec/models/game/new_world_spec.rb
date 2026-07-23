# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game::NewWorld do
  it_behaves_like 'a game profile'

  subject(:profile) { described_class.new }

  it 'is named New World' do
    expect(profile.display_name).to eq('New World')
  end

  it 'names the company hierarchy after New World ranks' do
    expect(profile.hierarchy_roles.pluck(:name))
      .to eq(%w[Governor Consul Officer Member Guest])
  end

  it 'treats both Governor and Consul as admins' do
    expect(profile.role_names_for(:admin)).to contain_exactly('Governor', 'Consul')
  end

  it 'admits Governor, Consul and Officer for a staff check' do
    expect(profile.role_names_for(:staff)).to contain_exactly('Governor', 'Consul', 'Officer')
  end

  it 'restricts an exact guest check to Guest only' do
    expect(profile.role_names_for(:guest, exact: true)).to contain_exactly('Guest')
  end

  it 'registers the server status and build cleanup notifiers' do
    expect(profile.notifiers).to contain_exactly(NewWorldNotifications, PlayerBuildsTask)
  end

  it 'exposes the status page url' do
    expect(profile.status_page_url).to match(%r{\Ahttps://})
  end
end
