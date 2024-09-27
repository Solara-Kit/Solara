$LOAD_PATH.unshift(File.expand_path(__dir__))

require 'singleton'

require 'logger'
require 'colorize'

class SolaraLogger
    LEVELS = %i[debug info warn error fatal]
    EMOJIS = {
        debug: "",
        info: "",
        warn: "⚠️",
        error: "❌ ",
        fatal: "💀"
    }

    def initialize
        @logger = Logger.new(STDOUT)
        # Set the default to INFO until we override it later.
        @logger.level = Logger::INFO
        @verbose = false
        @step_count = 0
        set_default_format
    end

    def reset_steps
        @step_count = 0
    end

    def verbose=(value)
        @verbose = value
        @logger.level = @verbose ? Logger::DEBUG : Logger::INFO
    end

    LEVELS.each do |level|
        define_method(level) do |message|
            emoji = EMOJIS[level]
            @logger.send(level, colorize("#{emoji.empty? ? '' : emoji + "\s"}#{message}", level))
        end
    end

    def start_step(message)
        return unless @verbose
        @step_count += 1
        @logger.debug("Step #{@step_count}: #{message}".green)
        line
    end

    def log_step(step_name)
        start_step(step_name)
        yield
        end_step(step_name)
      end

    def title(message)
        @logger.info(message.green)
        line
    end

    def end_step(message = "Step completed")
        return unless @verbose
        @logger.debug("FINISHED Step #{@step_count}: #{message}".green)
        line
        info("") # Empty line for better readability
    end

    def line(char: '-', length: 50)
        message = char * length
        @logger.info(message.green)
    end

    def header(message)
        return unless @verbose

        line(char: '=')
        @logger.info(message.upcase.green)
        line(char: '=')
        info("") # Empty line for better readability
    end

    def success(message)
        @logger.info("🎉 #{message.green}")
    end

    def failure(message)
        error(message)
    end

    def passed(message)
        @logger.debug("✅  #{message.green}")
    end


    private

    def set_default_format
        @logger.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end
    end

    def colorize(message, level)
        case level
        when :debug then message
        when :info then message
        when :warn then message.yellow
        when :error then message.red
        when :fatal then message.red.bold
        else message
        end
    end
end