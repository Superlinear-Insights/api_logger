require 'spec_helper'

RSpec.describe ApiLogger::Configuration do
  let(:config) { described_class.new }

  describe 'default configuration' do
    it 'has default values' do
      expect(config.table_name).to eq('api_logs')
      expect(config.enabled).to be true
      expect(config.use_middleware).to be true
      expect(config.exclude_routes).to be_empty
      expect(config.exclude_hosts).to be_empty
    end
  end

  describe '#should_log_route?' do
    context 'when logging is disabled' do
      before { config.enabled = false }

      it 'returns false regardless of route' do
        expect(config.should_log_route?('/any/path')).to be false
      end
    end

    context 'when middleware is disabled' do
      before { config.use_middleware = false }

      it 'returns false regardless of route' do
        expect(config.should_log_route?('/any/path')).to be false
      end
    end

    context 'with excluded routes' do
      before do
        config.exclude_routes = [
          '/signin',
          '/signup',
          %r{^/admin.*}
        ]
      end

      it 'returns false for exact string matches' do
        expect(config.should_log_route?('/signin')).to be false
        expect(config.should_log_route?('/signup')).to be false
      end

      it 'returns false for regex matches' do
        expect(config.should_log_route?('/admin/users')).to be false
        expect(config.should_log_route?('/admin/settings')).to be false
      end

      it 'returns true for non-excluded routes' do
        expect(config.should_log_route?('/users')).to be true
        expect(config.should_log_route?('/api/posts')).to be true
      end
    end

    context 'with excluded hosts' do
      before do
        config.exclude_hosts = [
          'api.example.com',
          /.*\.myapp\.com$/
        ]
      end

      it 'returns false for excluded hosts' do
        expect(config.should_log_route?('/users', 'api.example.com')).to be false
      end

      it 'returns false for regex host matches' do
        expect(config.should_log_route?('/users', 'api.myapp.com')).to be false
        expect(config.should_log_route?('/users', 'admin.myapp.com')).to be false
      end

      it 'returns true for non-excluded hosts' do
        expect(config.should_log_route?('/users', 'other-api.com')).to be true
        expect(config.should_log_route?('/users', 'myapp.org')).to be true
      end

      it 'returns true when no host is provided' do
        expect(config.should_log_route?('/users')).to be true
      end
    end

    context 'with both excluded routes and excluded hosts' do
      before do
        config.exclude_routes = ['/signin', '/signup']
        config.exclude_hosts = ['api.example.com']
      end

      it 'returns false for excluded routes regardless of host' do
        expect(config.should_log_route?('/signin', 'other-api.com')).to be false
        expect(config.should_log_route?('/signup', 'other-api.com')).to be false
      end

      it 'returns false for excluded hosts regardless of route' do
        expect(config.should_log_route?('/users', 'api.example.com')).to be false
      end

      it 'returns true for non-excluded routes with non-excluded hosts' do
        expect(config.should_log_route?('/users', 'other-api.com')).to be true
      end
    end
  end
end
