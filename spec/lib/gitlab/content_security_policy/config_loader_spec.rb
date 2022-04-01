# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::ContentSecurityPolicy::ConfigLoader do
  let(:policy) { ActionDispatch::ContentSecurityPolicy.new }
  let(:csp_config) do
    {
      enabled: true,
      report_only: false,
      directives: {
        base_uri: 'http://example.com',
        child_src: "'self' https://child.example.com",
        default_src: "'self' https://other.example.com",
        script_src: "'self'  https://script.exammple.com ",
        worker_src: "data:  https://worker.example.com",
        report_uri: "http://example.com"
      }
    }
  end

  describe '.default_enabled' do
    let(:enabled) { described_class.default_enabled }

    it 'is enabled' do
      expect(enabled).to be_truthy
    end

    context 'when in production' do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      end

      it 'is disabled' do
        expect(enabled).to be_falsey
      end
    end
  end

  describe '.default_directives' do
    let(:directives) { described_class.default_directives }

    it 'returns default directives' do
      directive_names = (described_class::DIRECTIVES - ['report_uri'])
      directive_names.each do |directive|
        expect(directives.has_key?(directive)).to be_truthy
        expect(directives[directive]).to be_truthy
      end

      expect(directives.has_key?('report_uri')).to be_truthy
      expect(directives['report_uri']).to be_nil
      expect(directives['child_src']).to eq(directives['frame_src'])
    end

    context 'when CDN host is defined' do
      before do
        stub_config_setting(cdn_host: 'https://example.com')
      end

      it 'adds CDN host to CSP' do
        expect(directives['script_src']).to eq("'strict-dynamic' 'self' 'unsafe-inline' 'unsafe-eval' https://www.google.com/recaptcha/ https://www.recaptcha.net https://apis.google.com https://example.com")
        expect(directives['style_src']).to eq("'self' 'unsafe-inline' https://example.com")
        expect(directives['font_src']).to eq("'self' https://example.com")
      end
    end

    context 'when sentry is configured' do
      before do
        stub_sentry_settings
      end

      it 'adds sentry path to CSP without user' do
        expect(directives['connect_src']).to eq("'self' dummy://example.com/43")
      end
    end

    context 'when CUSTOMER_PORTAL_URL is set' do
      before do
        stub_env('CUSTOMER_PORTAL_URL', 'https://customers.example.com')
      end

      context 'when in production' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
        end

        it 'does not add CUSTOMER_PORTAL_URL to CSP' do
          expect(directives['frame_src']).to eq("'self' https://www.google.com/recaptcha/ https://www.recaptcha.net/ https://content.googleapis.com https://content-compute.googleapis.com https://content-cloudbilling.googleapis.com https://content-cloudresourcemanager.googleapis.com")
        end
      end

      context 'when in development' do
        before do
          allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('development'))
        end

        it 'adds CUSTOMER_PORTAL_URL to CSP' do
          expect(directives['frame_src']).to eq("'self' https://www.google.com/recaptcha/ https://www.recaptcha.net/ https://content.googleapis.com https://content-compute.googleapis.com https://content-cloudbilling.googleapis.com https://content-cloudresourcemanager.googleapis.com https://customers.example.com")
        end
      end
    end
  end

  describe '#load' do
    subject { described_class.new(csp_config[:directives]) }

    def expected_config(directive)
      csp_config[:directives][directive].split(' ').map(&:strip)
    end

    it 'sets the policy properly' do
      subject.load(policy)

      expect(policy.directives['base-uri']).to eq([csp_config[:directives][:base_uri]])
      expect(policy.directives['default-src']).to eq(expected_config(:default_src))
      expect(policy.directives['child-src']).to eq(expected_config(:child_src))
      expect(policy.directives['worker-src']).to eq(expected_config(:worker_src))
      expect(policy.directives['report-uri']).to eq(expected_config(:report_uri))
    end

    it 'ignores malformed policy statements' do
      csp_config[:directives][:base_uri] = 123

      subject.load(policy)

      expect(policy.directives['base-uri']).to be_nil
    end
  end
end
