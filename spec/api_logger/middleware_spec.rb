require 'spec_helper'

RSpec.describe ApiLogger::Middleware do
  let(:app) { double('app', call: [200, {}, ['OK']]) }
  let(:middleware) { described_class.new(app) }
  let(:env) { {} }

  describe '#call' do
    it 'calls the app' do
      expect(app).to receive(:call).with(env)
      middleware.call(env)
    end
  end

  describe 'request logging' do
    let(:uri) { URI('https://services.mfcentral.com/api/v1/users') }
    let(:request) { Net::HTTP::Get.new(uri) }
    let(:response) { Net::HTTP::Response.new('1.1', '200', 'OK') }
    
    before do
      # Allow the actual request to go through
      stub_request(:get, uri.to_s).to_return(status: 200, body: 'OK')

      # Reset Net::HTTP to original state
      if Net::HTTP.method_defined?(:request_without_api_logger)
        Net::HTTP.class_eval do
          alias_method :request, :request_without_api_logger
          remove_method :request_without_api_logger
          remove_method :request_with_api_logger if method_defined?(:request_with_api_logger)
        end
      end

      # Apply our middleware patch
      middleware.call(env)
    end

    context 'when host is in allowed list' do
      before do
        ApiLogger.configure do |config|
          config.allowed_hosts = ['services.mfcentral.com']
        end
      end

      it 'logs the request' do
        expect(ApiLogger).to receive(:log).with(
          hash_including(
            endpoint: '/api/v1/users',
            http_method: 'GET',
            response_status: 200
          )
        )

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.request(request)
      end

      it 'logs errors when they occur' do
        error_uri = URI('https://services.mfcentral.com/api/v1/error')
        stub_request(:get, error_uri.to_s).to_raise(StandardError.new('Test error'))

        expect(ApiLogger).to receive(:log).with(
          hash_including(
            endpoint: '/api/v1/error',
            http_method: 'GET',
            error_message: 'Test error'
          )
        )

        http = Net::HTTP.new(error_uri.host, error_uri.port)
        http.use_ssl = true
        
        expect {
          http.request(Net::HTTP::Get.new(error_uri))
        }.to raise_error(StandardError, 'Test error')
      end
    end

    context 'when host is not in allowed list' do
      before do
        ApiLogger.configure do |config|
          config.allowed_hosts = ['uatservices.mfcentral.com']
        end
      end

      it 'does not log the request' do
        expect(ApiLogger).not_to receive(:log)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.request(request)
      end
    end

    context 'when logging is disabled' do
      before do
        ApiLogger.configure do |config|
          config.enabled = false
          config.allowed_hosts = ['services.mfcentral.com']
        end
      end

      it 'does not log the request' do
        expect(ApiLogger).not_to receive(:log)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.request(request)
      end
    end

    context 'when middleware is disabled' do
      before do
        ApiLogger.configure do |config|
          config.use_middleware = false
          config.allowed_hosts = ['services.mfcentral.com']
        end
      end

      it 'does not log the request' do
        expect(ApiLogger).not_to receive(:log)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.request(request)
      end
    end

    context 'when request is already being processed' do
      before do
        ApiLogger.configure do |config|
          config.allowed_hosts = ['services.mfcentral.com']
        end
      end

      it 'prevents recursive logging' do
        Thread.current[:api_logger_active] = true
        expect(ApiLogger).not_to receive(:log)

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.request(request)
      ensure
        Thread.current[:api_logger_active] = nil
      end
    end
  end
end
