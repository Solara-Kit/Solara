class ValidationStrategy
  class ValidationError < StandardError; end

  def validate(project_path)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end