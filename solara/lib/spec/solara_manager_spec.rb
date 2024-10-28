require 'rspec'
require_relative '../solara.rb'

RSpec.describe SolaraManager do
  let(:manager) { SolaraManager.new }
  let(:brand_key) { 'test_brand' }
  let(:brand_name) { 'Test Brand' }
  let(:platform) { 'ios' }
  let(:configurations) { { some: 'config' } }
  let(:export_path) { '/path/to/export' }

  describe '#init' do
    it 'calls SolaraInitializer with correct parameters' do
      initializer_mock = instance_double(SolaraInitializer)
      expect(SolaraInitializer).to receive(:new).with(brand_key, brand_name).and_return(initializer_mock)
      expect(initializer_mock).to receive(:init)

      manager.init(brand_key, brand_name)
    end
  end

  describe '#import' do
    it 'calls BrandImporter with correct parameters' do
      importer_mock = instance_double(BrandImporter)
      expect(BrandImporter).to receive(:new).and_return(importer_mock)
      expect(importer_mock).to receive(:start).with(configurations)

      manager.import(configurations)
    end
  end

  describe '#export' do
    it 'calls BrandExporter with correct parameters' do
      exporter_mock = instance_double(BrandExporter)
      expect(BrandExporter).to receive(:new).and_return(exporter_mock)
      expect(exporter_mock).to receive(:start).with([brand_key], export_path)

      manager.export([brand_key], export_path)
    end
  end

  describe '#status' do
    it 'calls SolaraStatusManager' do
      status_manager_mock = instance_double(SolaraStatusManager)
      expect(SolaraStatusManager).to receive(:new).and_return(status_manager_mock)
      expect(status_manager_mock).to receive(:start)

      manager.status
    end
  end

  describe '#onboard' do
    let(:brands_manager_mock) { instance_double(BrandsManager) }
    let(:brand_onboarder_mock) { instance_double(BrandOnboarder) }
    let(:logger_mock) { instance_double(SolaraLogger) }

    before do
      allow(BrandsManager).to receive(:instance).and_return(brands_manager_mock)
      allow(BrandOnboarder).to receive(:new).and_return(brand_onboarder_mock)
      allow(Solara).to receive(:logger).and_return(logger_mock)
      allow(logger_mock).to receive(:header)
      allow(logger_mock).to receive(:success)
      allow(manager).to receive(:switch)
      allow(manager).to receive(:dashboard)
    end

    context 'when brand already exists' do
      it 'logs fatal error and returns' do
        allow(brands_manager_mock).to receive(:exists).with(brand_key).and_return(true)
        expect(logger_mock).to receive(:fatal).with("Brand with key (#{brand_key}) already added to brands!")
        expect(brand_onboarder_mock).not_to receive(:onboard)

        manager.onboard(brand_key, brand_name)
      end
    end

    context 'when brand does not exist' do
      before do
        allow(brands_manager_mock).to receive(:exists).with(brand_key).and_return(false)
      end

      it 'calls BrandOnboarder and switches to the new brand' do
        expect(BrandOnboarder).to receive(:new).and_return(brand_onboarder_mock)
        expect(brand_onboarder_mock).to receive(:onboard).with(brand_key, brand_name, clone_brand_key: nil)
        expect(manager).to receive(:switch).with(brand_key, ignore_health_check: true)

        manager.onboard(brand_key, brand_name)
      end

      it 'opens dashboard when open_dashboard is true' do
        expect(BrandOnboarder).to receive(:new).and_return(brand_onboarder_mock)
        expect(brand_onboarder_mock).to receive(:onboard).with(brand_key, brand_name, clone_brand_key: nil)
        expect(manager).to receive(:switch).with(brand_key, ignore_health_check: true)
        expect(manager).to receive(:dashboard).with(brand_key)

        manager.onboard(brand_key, brand_name, open_dashboard: true)
      end

      it 'does not open dashboard when open_dashboard is false' do
        expect(BrandOnboarder).to receive(:new).and_return(brand_onboarder_mock)
        expect(brand_onboarder_mock).to receive(:onboard).with(brand_key, brand_name, clone_brand_key: nil)
        expect(manager).to receive(:switch).with(brand_key, ignore_health_check: true)
        expect(manager).not_to receive(:dashboard)

        manager.onboard(brand_key, brand_name, open_dashboard: false)
      end

      it 'passes clone_brand_key when provided' do
        clone_key = 'source_brand'
        expect(BrandOnboarder).to receive(:new).and_return(brand_onboarder_mock)
        expect(brand_onboarder_mock).to receive(:onboard).with(brand_key, brand_name, clone_brand_key: clone_key)
        expect(manager).to receive(:switch).with(brand_key, ignore_health_check: true)

        manager.onboard(brand_key, brand_name, clone_brand_key: clone_key)
      end
    end
  end

  describe '#offboard' do
    it 'calls BrandOffboarder with correct parameters' do
      offboarder_mock = instance_double(BrandOffboarder)
      expect(BrandOffboarder).to receive(:new).and_return(offboarder_mock)
      expect(offboarder_mock).to receive(:offboard).with(brand_key, confirm: true)

      manager.offboard(brand_key)
    end
  end

  describe '#switch' do
    it 'calls BrandSwitcher with correct parameters' do
      switcher_mock = instance_double(BrandSwitcher)
      expect(BrandSwitcher).to receive(:new).with(brand_key, ignore_health_check: false).and_return(switcher_mock)
      expect(switcher_mock).to receive(:start)

      manager.switch(brand_key)
    end
  end

  describe '#dashboard' do
    it 'calls DashboardManager with correct parameters' do
      dashboard_manager_mock = instance_double(DashboardManager)
      expect(DashboardManager).to receive(:new).and_return(dashboard_manager_mock)
      expect(dashboard_manager_mock).to receive(:start).with(brand_key, 8000)

      manager.dashboard(brand_key)
    end
  end

  describe '#doctor' do
    let(:doctor_manager_mock) { instance_double(DoctorManager) }

    before do
      allow(DoctorManager).to receive(:new).and_return(doctor_manager_mock)
    end

    it 'calls DoctorManager with correct parameters when brand_key is provided' do
      expect(doctor_manager_mock).to receive(:visit_brands).with([brand_key], print_logs: true)

      manager.doctor(brand_key)
    end

    it 'calls DoctorManager with empty array when brand_key is not provided' do
      expect(doctor_manager_mock).to receive(:visit_brands).with([], print_logs: true)

      manager.doctor
    end
  end
end