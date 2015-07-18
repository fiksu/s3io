module S3io

  def self.writer(s3object, options = {}, &block)
    open(s3object, 'w', options, &block)
  end

  class WriteWrapper < Wrapper

    # Default maximum file size
    MAX_FILE_SIZE = 1 * 1024 * 1024 * 1024 * 1024 # TiB

    # S3 only supports up to 10K multipart chunks
    MAX_NUM_CHUNKS = 10000

    # Minimum chunk size in S3 is 5MiB
    MIN_CHUNK_SIZE = 5 * 1024 * 1024 # MiB

    # Number of bytes written to S3
    attr_reader :pos

    def initialize(s3object, options = {})
      super(s3object)

      @options = {
        :max_file_size => (options[:max_file_size] || MAX_FILE_SIZE),
        :multipart_upload_options => (options[:multipart_upload_options] || {})
      }

      @min_chunk_size = [(@options[:max_file_size].to_f / MAX_NUM_CHUNKS).ceil, MIN_CHUNK_SIZE].max
      @multipart_upload = @s3object.multipart_upload(@options[:multipart_upload_options])
      @write_buffer = ''
    end

    def write(data)
      fail "S3 Object is already closed" unless @s3object

      data_str = data.to_s
      data_size = data_str.size

      @write_buffer << data_str
      @pos += data_size
      self.flush if @write_buffer.size >= @min_chunk_size

      return data_size
    end

    alias_method :<<, :write

    def flush
      return if @write_buffer.empty?

      @multipart_upload.add_part(@write_buffer)
      @write_buffer.replace '' # String#clear isn't available on 1.8.x

      return nil
    end

    def close
      self.flush
      @multipart_upload.close
      @multipart_upload = nil

      super
    end
  end
end
