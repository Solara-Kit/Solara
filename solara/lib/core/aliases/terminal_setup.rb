#!/usr/bin/env ruby

Dir.glob("../scripts/*.rb").each { |file| require file }

require 'fileutils'
require 'rbconfig'

class TerminalSetup
  def initialize
    @setup_dir = File.join(ENV['HOME'], '.solara')
  end

  def run
    create_setup_directory

    case RbConfig::CONFIG['host_os']
    when /mswin|mingw|cygwin/
      WindowsTerminalSetup.new(@setup_dir).run
    when /darwin|mac os|linux/
      UnixTerminalSetup.new(@setup_dir).run
    else
      Solara.logger.fatal("Unsupported operating system. Please set up the terminal manually.")
    end
  end

  private

  def create_setup_directory
    FileUtils.mkdir_p(@setup_dir)
  end
end

class UnixTerminalSetup
  def initialize(setup_dir)
    @aliases_file_unix = FilePath.solara_generated_aliases_unix
    @unix_setup_file = File.join(setup_dir, 'setup.sh')
  end

  def run
    create_unix_setup_script
    setup_unix
  end

  private

  def create_unix_setup_script
    File.open(@unix_setup_file, 'w') do |file|
      file.puts <<~SCRIPT
        #!/bin/bash
        source "#{@aliases_file_unix}"
      SCRIPT
    end
    FileUtils.chmod(0755, @unix_setup_file)
  end

  def setup_unix
    shell_config_file = determine_shell_config_file
    setup_line = "source #{@unix_setup_file}"

    if File.exist?(shell_config_file)
      content = File.read(shell_config_file)
      unless content.include?(setup_line)
        File.open(shell_config_file, 'a') do |file|
          file.puts "\n# Solara Setup"
          file.puts setup_line
        end
        Solara.logger.debug("Configuration added to #{shell_config_file}")
        Solara.logger.success("Please restart your terminal or run 'source #{shell_config_file}' to apply changes.")
      else
        Solara.logger.debug("Configuration already exists in #{shell_config_file}")
      end
    else
      Solara.logger.failure("Shell configuration file not found. Please add the following line manually to your shell configuration:")
      Solara.logger.failure(setup_line)
    end
  end

  def determine_shell_config_file
    if ENV['SHELL'] =~ /zsh/
      File.expand_path('~/.zshrc')
    elsif ENV['SHELL'] =~ /bash/
      File.expand_path('~/.bashrc')
    else
      File.expand_path('~/.profile')
    end
  end
end

class WindowsTerminalSetup
  def initialize(setup_dir)
  end

  def run
    setup_command_prompt
    setup_powershell
  end

  private

  def setup_command_prompt
    require 'win32/registry'
    setup_file = FilePath.solara_generated_aliases_windows_command_prompt

    begin
      Win32::Registry::HKEY_CURRENT_USER.create('Software\Microsoft\Command Processor') do |reg|
        reg['AutoRun', Win32::Registry::REG_EXPAND_SZ] = setup_file
      end
      Solara.logger.debug("Windows AutoRun registry key set up successfully.")
      Solara.logger.debug("Please restart your Command Prompt to apply changes.")
    rescue Win32::Registry::Error => e
      Solara.logger.failure("Failed to set up Windows registry: #{e.class} - #{e.message}")
      Solara.logger.failure("Please add the following file path to your AutoRun registry key manually:")
      Solara.logger.failure(setup_file)
    end
  end

  def setup_powershell_
    require 'win32/registry'
    setup_file = FilePath.solara_generated_aliases_powershell

    begin
      # This path targets all versions of PowerShell
      Win32::Registry::HKEY_CURRENT_USER.create('Software\Microsoft\PowerShell\PowerShellEngine') do |reg|
        reg['AutoRun', Win32::Registry::REG_EXPAND_SZ] = setup_file
      end
      Solara.logger.debug("PowerShell AutoRun registry key set up successfully.")
      Solara.logger.debug("Please restart your PowerShell to apply changes.")
    rescue Win32::Registry::Error => e
      Solara.logger.failure("Failed to set up PowerShell registry: #{e.class} - #{e.message}")
      Solara.logger.failure("Please add the following file path to your PowerShell AutoRun registry key manually:")
      Solara.logger.failure(setup_file)
    end
  end

 def setup_powershell
   # Not supported at the moment
 end
end