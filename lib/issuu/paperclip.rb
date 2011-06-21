module Issuu
  module Paperclip
    module InstanceMethods
      def self.included(base)
        base.extend ClassMethods
      end

      # Returns the full filename for the given attribute. If the file is
      # stored on S3, this is a full S3 URI, while it is a full path to the
      # local file if the file is stored locally.
      def file_path
        attached_file.url =~ Issuu::S3 ? attached_file.url : attached_file.path
      end

      private

      # Figure out what Paperclip is calling the attached file object
      # ie. has_attached_file :attachment => "attachment"
      def prefix
        @prefix ||= self.class.column_names.detect{|c| c.ends_with?("_file_name")}.gsub("_file_name", '')
      end

      # Return the attached file object
      def attached_file
        @file ||= self.send(prefix)
      end
    end    
  end
end
