module Issuu
  module AttachmentFu

    module InstanceMethods

      def self.included(base)
        base.extend ClassMethods
      end

      # Yields the correct path to the file, either the local filename or the S3 URL.
      def file_path
        public_filename =~ Issuu::S3 ? public_filename : "#{RAILS_ROOT}/public#{public_filename}"
      end
    end

  end
end
