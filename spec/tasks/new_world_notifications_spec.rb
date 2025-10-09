describe NewWorldNotifications do
  let(:notifier) { described_class.new }

  describe '#check_server_status' do
    before do
      allow(notifier).to receive(:notify_server_status)
      allow(notifier).to receive(:sleep).and_return(nil)
    end

    context 'when server goes offline' do
      it 'notifies only once when status changes to offline' do
        # First, server is online
        allow(notifier).to receive(:fetch_server_status).and_return('Online')
        notifier.send(:check_server_status)
        expect(notifier).not_to have_received(:notify_server_status)

        # Now, server goes offline
        allow(notifier).to receive(:fetch_server_status).and_return('Offline')
        notifier.send(:check_server_status)
        expect(notifier).to have_received(:notify_server_status).with(false).once

        # Still offline, should not notify again
        notifier.send(:check_server_status)
        expect(notifier).to have_received(:notify_server_status).once
      end
    end

    context 'when server comes back online' do
      it 'notifies when status changes back to online' do
        # Server goes offline first
        allow(notifier).to receive(:fetch_server_status).and_return('Offline')
        notifier.send(:check_server_status)
        expect(notifier).to have_received(:notify_server_status).with(false).once

        # Now, server comes back online
        allow(notifier).to receive(:fetch_server_status).and_return('Online')
        notifier.send(:check_server_status)
        expect(notifier).to have_received(:notify_server_status).with(true).once
      end
    end
  end
end
