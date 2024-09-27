require 'rspec'
require_relative '../solara.rb'
Dir.glob("../core/scripts/*.rb").each { |file| require file }

RSpec.describe SolaraManager do
  let(:manager) { SolaraManager.new }
  let(:brand_key) { 'brand1' }
  let(:brand_name) { 'Brand 1' }
  let(:clone_brand_key) { 'brand1' }
  let(:configurations) { { key: 'value' } }
  let(:export_path) { '/path/to/export' }
  let(:test_lab) { FilePath.test_lab }

def setup_solara_configurations
  # Set up Solara configurations
  Solara.logger.reset_steps
  Solara.logger.verbose = true
  SolaraSettingsManager.instance.environment = SolaraEnvironment::Test
  SolaraSettingsManager.instance.root = Pathname.new(File.expand_path('../..', __FILE__))
end

def manage_test_lab_environment(platform)
  test_lab_platform = File.join(test_lab, platform)
  test_lab_cache = FilePath.test_lab_cache
  test_lab_cache_platform = File.join(test_lab_cache, platform)

  # Ensure the target platform directory exists
  FileUtils.mkdir_p(test_lab_platform) unless File.exist?(test_lab_platform)

  # Delete existing test_lab if it exists
  FileManager.delete_if_exists(test_lab_platform)

  # Check if the cache exists
  if Dir.exist?(test_lab_cache)
    Solara.logger.debug("Cache found at #{test_lab_cache_platform}. Copying to #{test_lab_platform}.")
    FileUtils.cp_r("#{test_lab_cache_platform}/.", test_lab_platform)
  else
    # Define the repository URL and clone if cache does not exist
    repo_url = 'https://github.com/Solara-Kit/TestLab.git'
    Solara.logger.debug("No cache found. Cloning from #{repo_url}.")

    FileManager.delete_if_exists(test_lab)
    # Clone the repository
    system("git clone #{repo_url} #{test_lab}")

    # Check if the clone was successful
    if $?.success?
      Solara.logger.debug("Successfully cloned #{repo_url} into #{test_lab}.")

      # Cache the cloned repository
      FileUtils.rm_rf(test_lab_cache) if Dir.exist?(test_lab_cache) # Remove old cache if it exists
      FileUtils.cp_r("#{test_lab}/.", test_lab_cache) # Copy the new clone to cache
      Solara.logger.debug("Cached the cloned repository to #{test_lab_cache}.")
    else
      Solara.logger.debug("Failed to clone the repository.")
      raise "Git clone failed."
    end
  end
end

def init_solara(platform)
  SolaraSettingsManager.instance.project_root = File.join(FilePath.test_lab, platform)
  SolaraSettingsManager.instance.platform = platform

  Solara.logger.debug("platform: #{SolaraSettingsManager.instance.platform}")
  Solara.logger.debug("project_root: #{SolaraSettingsManager.instance.project_root}")

  expect { manager.init(brand_key, brand_name) }.not_to raise_error

  is_current_brand = BrandsManager.instance.is_current_brand(brand_key)
  expect(is_current_brand).to be true
  Solara.logger.debug("Test: Finished initializing #{platform}")
end

describe '#onboard' do
  before do
    setup_solara_configurations
  end

  shared_examples 'onboards and offboards with platform' do |platform|
      it "onboards and offboards #{platform} with the given platform" do
        Solara.logger.header("Test: Onboard with platform: #{platform}")

        manage_test_lab_environment(platform)
        init_solara(platform)

        brand_key = 'brand2'
        manager.onboard(brand_key, 'Brand 2')

        expect(Solara.logger).to receive(:fatal).with("Brand with key (#{brand_key}) already added to brands!")
        manager.onboard(brand_key, 'Brand 2')

        expect { manager.offboard(brand_key, confirm: false) }.not_to raise_error

        expect(BrandsManager.instance.exists(brand_key)).to be false

        expect(Solara.logger).to receive(:fatal).with("Brnad key brand3 doesn't exist!")
        expect { manager.offboard('brand3', confirm: false) }.not_to raise_error
      end
    end

    context 'when platform is Flutter' do
      it_behaves_like 'onboards and offboards with platform', 'flutter'
    end

    context 'when platform is Android' do
      it_behaves_like 'onboards and offboards with platform', 'android'
    end

    context 'when platform is iOS' do
      it_behaves_like 'onboards and offboards with platform', 'ios'
    end
  end

  describe '#export' do
  before do
    setup_solara_configurations
  end

  shared_examples 'exports and imports with platform' do |platform|
      it "exports and imports #{platform} with the given platform" do
        Solara.logger.header("Test: Export and import with platform: #{platform}")

        manage_test_lab_environment(platform)
        init_solara(platform)

        expect { manager.export([brand_key], test_lab) }.not_to raise_error
        path = File.join(test_lab, "#{brand_key}-solara-configurations.json")
        expect { manager.import([path]) }.not_to raise_error
      end
    end

    context 'when platform is Flutter' do
      it_behaves_like 'exports and imports with platform', 'flutter'
    end

    context 'when platform is Android' do
      it_behaves_like 'exports and imports with platform', 'android'
    end

    context 'when platform is iOS' do
      it_behaves_like 'exports and imports with platform', 'ios'
    end

    it 'exports and imports brand keys to the specified path' do
      expect { manager.export([brand_key], test_lab) }.not_to raise_error
    end
  end


  describe '#status' do
    it 'checks the status without errors' do
      expect { manager.status }.not_to raise_error
    end
  end

end