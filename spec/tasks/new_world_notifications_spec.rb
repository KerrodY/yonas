require 'rails_helper'

RSpec.describe NewWorldNotifications do
  let(:notifier) { described_class.new }

  describe '#check_server_status' do
    before do
      allow(notifier).to receive(:notify_server_status)
      allow(notifier).to receive(:sleep).and_return(nil)
    end

    context 'when server is online' do
      it 'does not send any notification' do
        allow(notifier).to receive(:fetch_server_status).and_return('Online')

        notifier.send(:check_server_status)

        expect(notifier).not_to have_received(:notify_server_status)
      end
    end

    context 'when server goes offline' do
      it 'notifies with offline status on first detection' do
        allow(notifier).to receive(:fetch_server_status).and_return('Offline')

        notifier.send(:check_server_status)

        expect(notifier).to have_received(:notify_server_status).with(false).once
      end

      it 'does not notify again on subsequent checks while still offline' do
        allow(notifier).to receive(:fetch_server_status).and_return('Offline')

        notifier.send(:check_server_status)
        notifier.send(:check_server_status)

        expect(notifier).to have_received(:notify_server_status).with(false).once
      end
    end

    context 'when server comes back online after being offline' do
      before do
        # Server goes offline first
        allow(notifier).to receive(:fetch_server_status).and_return('Offline')
        notifier.send(:check_server_status)

        # Server comes back online — check_server_status calls fetch_server_status
        # once in the offline check (Block 1), then 3 times in the retry loop (Block 2)
        allow(notifier).to receive(:fetch_server_status).and_return('Online')
      end

      it 'notifies with online status' do
        notifier.send(:check_server_status)

        expect(notifier).to have_received(:notify_server_status).with(true).once
      end

      it 'sleeps between each retry check to confirm stability' do
        notifier.send(:check_server_status)

        expect(notifier).to have_received(:sleep).with(60).exactly(3).times
      end

      it 'resets state so future online checks do not re-notify' do
        notifier.send(:check_server_status)
        notifier.send(:check_server_status)

        expect(notifier).to have_received(:notify_server_status).with(true).once
      end
    end

    context 'when server flickers back to offline during the retry window' do
      it 'does not notify online and remains in offline state' do
        # Server goes offline
        allow(notifier).to receive(:fetch_server_status).and_return('Offline')
        notifier.send(:check_server_status)

        # Block 1 sees 'Online', retry loop sees 'Online' once then 'Offline' — returns early
        allow(notifier).to receive(:fetch_server_status).and_return('Online', 'Online', 'Offline')
        notifier.send(:check_server_status)

        expect(notifier).not_to have_received(:notify_server_status).with(true)
      end
    end
  end
end
