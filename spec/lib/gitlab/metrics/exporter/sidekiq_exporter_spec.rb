# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Metrics::Exporter::SidekiqExporter do
  let(:exporter) { described_class.new }

  after do
    exporter.stop
  end

  context 'with valid config' do
    before do
      stub_config(
        monitoring: {
          sidekiq_exporter: {
            enabled: true,
            log_enabled: false,
            port: 0,
            address: '127.0.0.1'
          }
        }
      )
    end

    it 'does start thread' do
      expect(exporter.start).not_to be_nil
    end

    it 'does not enable logging by default' do
      expect(exporter.log_filename).to eq(File::NULL)
    end
  end

  context 'with logging enabled' do
    before do
      stub_config(
        monitoring: {
          sidekiq_exporter: {
            enabled: true,
            log_enabled: true,
            port: 0,
            address: '127.0.0.1'
          }
        }
      )
    end

    it 'returns a valid log filename' do
      expect(exporter.log_filename).to end_with('sidekiq_exporter.log')
    end
  end

  context 'when port is already taken' do
    let(:first_exporter) { described_class.new }

    before do
      stub_config(
        monitoring: {
          sidekiq_exporter: {
            enabled: true,
            port: 9992,
            address: '127.0.0.1'
          }
        }
      )

      first_exporter.start
    end

    after do
      first_exporter.stop
    end

    it 'does print error message' do
      expect(Sidekiq.logger).to receive(:error)
        .with(
          class: described_class.to_s,
          message: 'Cannot start sidekiq_exporter',
          'exception.message' => anything)

      exporter.start
    end

    it 'does not start thread' do
      expect(exporter.start).to be_nil
    end
  end
end
