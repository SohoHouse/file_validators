begin
  require 'cocaine'
rescue LoadError
end

module FileValidators
  module Utils

    class ContentTypeDetector
      EMPTY_CONTENT_TYPE = 'inode/x-empty'
      DEFAULT_CONTENT_TYPE = 'application/octet-stream'

      def initialize(file_path)
        @file_path = file_path
      end

      # content type detection strategy:
      #
      # 1. empty file: returns 'inode/x-empty'
      # 2. nonempty file: if the file is not empty then returns the content type using file command
      # 3. invalid file: file command raises error and returns 'application/octet-stream'

      def detect
        empty_file? ? EMPTY_CONTENT_TYPE : content_type_from_file_command
      end

      private

      def empty_file?
        File.exists?(@file_path) && File.size(@file_path) == 0
      end

      def content_type_from_file_command
        type = begin
          Cocaine::CommandLine.new('file', '-b --mime-type :file').run(file: @file_path)
        rescue NameError => e
          puts "file_validators: Add 'cocaine' gem as you are using file content type validations in strict mode"
        rescue Cocaine::CommandLineError => e
          # TODO: log command failure
          DEFAULT_CONTENT_TYPE
        end.strip

        type.include?('No such file or directory') ? DEFAULT_CONTENT_TYPE : type
      end
    end

  end
end
