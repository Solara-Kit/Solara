require 'rspec'
require 'thor'
require 'fileutils'
require_relative '../solara.rb'

RSpec.describe Solara do

  before do
    allow(FilePath).to receive(:brands).and_return('/path')
    allow(FilePath).to receive(:dot_solara).and_return('.solara')
    allow(Solara::Setup).to receive(:setup).and_return(true)
    allow(Solara::Setup).to receive(:setup).and_return(true)
  end

  describe Solara::Setup do
    let(:setup) { Solara::Setup.new }

    it 'sets up SolaraSettingsManager correctly' do
      expect(SolaraSettingsManager.instance).to receive(:root=).with(Solara::ROOT)
      expect(SolaraSettingsManager.instance).to receive(:project_root=).with(Solara::PROJECT_ROOT)
      expect(Solara.logger).to receive(:debug).with("Solara installation at path: #{Solara::PROJECT_ROOT}")

      setup.setup
    end
  end

  describe Solara::CLI do
    let(:cli) { Solara::CLI.new }

    describe '#init' do
      it 'initializes Solara with valid parameters' do
        allow(cli).to receive(:options).and_return({
          'brand_key' => 'test_key',
          'brand_name' => 'Test Brand',
          'platform' => 'test_platform'
        })

        expect(cli).to receive(:validate_brand_key).with('test_key', ignore_brand_check: true).and_return('test_key')
        expect(cli).to receive(:validate_brand_name).with('Test Brand').and_return('Test Brand')
        expect_any_instance_of(SolaraManager).to receive(:init).with('test_key', 'Test Brand')

        cli.init
      end
    end

    describe '#status' do
      it 'checks project health and calls status on SolaraManager' do
        expect(cli).to receive(:check_project_health)
        expect_any_instance_of(SolaraManager).to receive(:status)

        cli.status
      end
    end

    describe '#import' do
      it 'imports configurations' do
        allow(cli).to receive(:options).and_return({ 'configurations' => ['config1', 'config2'] })
        expect(cli).to receive(:check_project_health)
        expect_any_instance_of(SolaraManager).to receive(:import).with(['config1', 'config2'])

        cli.import
      end
    end

    describe '#export' do
      it 'exports configurations' do
        allow(cli).to receive(:options).and_return({
          'brand_keys' => ['key1', 'key2'],
          'directory' => '/export/dir'
        })
        expect(cli).to receive(:check_project_health)
        expect_any_instance_of(SolaraManager).to receive(:export).with(['key1', 'key2'], '/export/dir')

        cli.export
      end
    end

    describe '#onboard' do
      it 'onboards a new brand' do
        allow(cli).to receive(:options).and_return({
          'brand_key' => 'new_key',
          'brand_name' => 'New Brand',
          'clone' => 'clone_key'
        })

        expect(cli).to receive(:check_project_health)
        expect(cli).to receive(:validate_brand_key).with('new_key', ignore_brand_check: true).and_return('new_key')
        expect(cli).to receive(:validate_brand_name).with('New Brand').and_return('New Brand')
        expect(cli).to receive(:validate_brand_key).with('clone_key', message: "Clone brand key is not existing, please enter correct key: ").and_return('clone_key')
        expect_any_instance_of(SolaraManager).to receive(:onboard).with('new_key', 'New Brand', clone_brand_key: 'clone_key')

        cli.onboard
      end
    end

    describe '#offboard' do
      it 'offboards a brand' do
        allow(cli).to receive(:options).and_return({ 'brand_key' => 'off_key' })
        expect(cli).to receive(:check_project_health)
        expect(cli).to receive(:validate_brand_key).with('off_key').and_return('off_key')
        expect_any_instance_of(SolaraManager).to receive(:offboard).with('off_key')

        cli.offboard
      end
    end

    describe '#switch' do
      it 'switches to a brand successfully' do
        allow(cli).to receive(:options).and_return({ 'brand_key' => 'switch_key' })
        expect(cli).to receive(:check_project_health)
        expect(cli).to receive(:validate_brand_key).with('switch_key').and_return('switch_key')
        expect_any_instance_of(SolaraManager).to receive(:switch).with('switch_key')

        cli.switch
      end

      it 'handles switch failure' do
        allow(cli).to receive(:options).and_return({ 'brand_key' => 'fail_key' })
        expect(cli).to receive(:check_project_health)
        expect(cli).to receive(:validate_brand_key).with('fail_key').and_return('fail_key')
        expect_any_instance_of(SolaraManager).to receive(:switch).and_raise(Issue.error(''))
        expect(Solara.logger).to receive(:fatal).with("Switching to fail_key failed.")
        expect { cli.switch }.to raise_error(SystemExit)
      end
    end

    describe '#dashboard' do
      it 'opens the dashboard for a brand' do
        allow(cli).to receive(:options).and_return({ 'brand_key' => 'dash_key', 'port' => 8080 })
        expect(cli).to receive(:check_project_health)
        expect(cli).to receive(:validate_brand_key).with('dash_key', ignore_if_nil: true).and_return('dash_key')
        expect_any_instance_of(SolaraManager).to receive(:dashboard).with('dash_key', 8080)

        cli.dashboard
      end
    end

    describe '#doctor' do
      it 'visits the doctor for a brand' do
        allow(cli).to receive(:options).and_return({ 'brand_key' => 'doc_key' })
        expect(cli).to receive(:check_project_health)
        expect(cli).to receive(:validate_brand_key).with('doc_key', ignore_if_nil: true).and_return('doc_key')
        expect_any_instance_of(SolaraManager).to receive(:doctor).with('doc_key')

        cli.doctor
      end
    end
  end
end