require 'spec_helper'

RSpec.describe ApiLogger::Configuration do
  let(:config) { described_class.new }

  describe 'default configuration' do
    it 'has default values' do
      expect(config.table_name).to eq('api_logs')
      expect(config.enabled).to be true
      expect(config.use_middleware).to be true
      expect(config.allowed_hosts).to be_empty
    end
  end

  describe '#should_log_route?' do
    context 'when logging is disabled' do
      before { config.enabled = false }

      it 'returns false regardless of host' do
        expect(config.should_log_route?('/any/path', 'services.mfcentral.com')).to be false
      end
    end

    context 'when middleware is disabled' do
      before { config.use_middleware = false }

      it 'returns false regardless of host' do
        expect(config.should_log_route?('/any/path', 'services.mfcentral.com')).to be false
      end
    end

    context 'when no host is provided' do
      it 'returns false' do
        expect(config.should_log_route?('/any/path')).to be false
      end
    end

    context 'with allowed hosts' do
      before do
        config.allowed_hosts = [
          'services.mfcentral.com',
          'uatservices.mfcentral.com'
        ]
      end

      it 'returns true for allowed hosts' do
        expect(config.should_log_route?('/any/path', 'services.mfcentral.com')).to be true
        expect(config.should_log_route?('/any/path', 'uatservices.mfcentral.com')).to be true
      end

      it 'returns false for non-allowed hosts' do
        expect(config.should_log_route?('/any/path', 'api.example.com')).to be false
        expect(config.should_log_route?('/any/path', 'api.telegram.org')).to be false
        expect(config.should_log_route?('/any/path', 'cognito-idp.amazonaws.com')).to be false
      end
    end

    context 'with empty allowed hosts' do
      before do
        config.allowed_hosts = []
      end

      it 'returns false for any host' do
        expect(config.should_log_route?('/any/path', 'services.mfcentral.com')).to be false
        expect(config.should_log_route?('/any/path', 'api.example.com')).to be false
      end
    end
  end
end
