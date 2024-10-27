class StringCase

    def self.capitalize(string)
        "#{string[0].upcase}#{string[1..-1]}"
    end

    def self.snake_to_capitalized_spaced(snake_case_string, exclude: '', transform: ->(item) { StringCase.capitalize(item) })
        # Split by underscores, then apply the transformation to each part
        parts = snake_case_string.split('_').map do |item|
            # Return the item as-is if it matches the exclude value
            item == exclude ? item : transform.call(item)
        end

        # Join the parts with a space
        parts.join(' ')
     end

end