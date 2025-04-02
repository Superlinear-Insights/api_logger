require 'spec_helper'

RSpec.describe ApiLogger::Configuration do
  let(:config) { described_class.new }

  describe 'default configuration' do
    it 'has default values' do
      expect(config.table_name).to eq('api_logs')
      expect(config.enabled).to be true
      expect(config.use_middleware).to be true
      expect(config.allowed_hosts).to eq(['services.mfcentral.com', 'uatservices.mfcentral.com'])
      expect(config.exclude_hosts).to be_empty
      expect(config.exclude_routes).to be_empty
    end
  end

  describe '#should_log_route?' do
    context 'when enabled and middleware is used' do
      it 'logs requests to allowed hosts' do
        expect(config.should_log_route?('/api/v1/users', 'services.mfcentral.com')).to be true
        expect(config.should_log_route?('/api/v1/users', 'uatservices.mfcentral.com')).to be true
      end

      it 'does not log requests to non-allowed hosts' do
        expect(config.should_log_route?('/api/v1/users', 'api.example.com')).to be false
      end
    end

    context 'when disabled' do
      before { config.enabled = false }

      it 'does not log any requests' do
        expect(config.should_log_route?('/api/v1/users', 'services.mfcentral.com')).to be false
      end
    end

    context 'when middleware is disabled' do
      before { config.use_middleware = false }

      it 'does not log any requests' do
        expect(config.should_log_route?('/api/v1/users', 'services.mfcentral.com')).to be false
      end
    end

    context 'when host is nil' do
      it 'does not log requests' do
        expect(config.should_log_route?('/api/v1/users', nil)).to be false
      end
    end
  end
end
