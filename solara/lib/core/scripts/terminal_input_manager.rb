class TerminalInputManager

    def get_validated(message)
        loop do
            print message.green
            user_input = STDIN.gets.chomp

            if yield(user_input)
                return user_input
            end
        end
    end

    def get(message)
        loop do
            print message.green
            user_input = STDIN.gets.chomp
            return user_input unless user_input.nil? || user_input.empty?
        end
    end

end