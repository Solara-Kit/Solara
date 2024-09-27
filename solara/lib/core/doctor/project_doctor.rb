Dir.glob("#{__dir__}/*.rb").each { |file| require file }

class ProjectDoctor
    def visit
        ProjectFileSystemValidator.new.validate
    end
end