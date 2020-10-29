# frozen_string_literal: true

require 'rack/test'

class JobStub
  def self.perform_now(data); end
end

class BadJobStub
  def self.perform_now(_data)
    raise StandardError, 'woops!'
  end
end

RSpec.describe TaskBot::Rack do
  include Rack::Test::Methods

  let(:app) { described_class }
  let(:path) { '/perform' }
  let(:attrs) { 'foo=bar&bar=baz' }

  describe 'GET /perform' do
    before { get "#{path}?#{params}" }

    context 'when no job is supplied' do
      let(:params) { attrs }

      it 'should return 422' do
        expect(last_response.status).to eq(422)
      end

      it 'should have an error explanation' do
        expect(last_response.body).to eq('Missing job type')
      end
    end

    context 'when unknown job is supplied' do
      let(:params) { "job=FakeJobStub&#{attrs}" }

      it 'should return 422' do
        expect(last_response.status).to eq(422)
      end

      it 'should have an error explanation' do
        expect(last_response.body).to eq('Unknown job type')
      end
    end

    context 'when valid job is supplied' do
      let(:params) { "job=JobStub&#{attrs}" }

      it 'should return 200' do
        expect(last_response.status).to eq(200)
      end

      it 'should have a status explanation' do
        expect(last_response.body).to eq('ok')
      end
    end

    context 'when job fails' do
      let(:params) { "job=BadJobStub&#{attrs}" }

      it 'should return 500' do
        expect(last_response.status).to eq(500)
      end

      it 'should have an error explanation' do
        expect(last_response.body).to eq('Failure processing job')
      end
    end
  end

  describe 'POST /perform' do
    before { post '/perform', body }

    context 'when no job is supplied' do
      let(:body) { attrs }

      it 'should return 422' do
        expect(last_response.status).to eq(422)
      end

      it 'should have an error explanation' do
        expect(last_response.body).to eq('Missing job type')
      end
    end

    context 'when unknown job is supplied' do
      let(:body) { "job=FakeJobStub&#{attrs}" }

      it 'should return 422' do
        expect(last_response.status).to eq(422)
      end

      it 'should have an error explanation' do
        expect(last_response.body).to eq('Unknown job type')
      end
    end

    context 'when valid job is supplied' do
      let(:body) { "job=JobStub&#{attrs}" }

      it 'should return 200' do
        expect(last_response.status).to eq(200)
      end

      it 'should have a status explanation' do
        expect(last_response.body).to eq('ok')
      end
    end

    context 'when job fails' do
      let(:body) { "job=BadJobStub&#{attrs}" }

      it 'should return 500' do
        expect(last_response.status).to eq(500)
      end

      it 'should have an error explanation' do
        expect(last_response.body).to eq('Failure processing job')
      end
    end
  end
end
