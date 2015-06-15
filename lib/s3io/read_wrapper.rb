module S3io

  def self.reader(s3object, options = {}, &block)
    open(s3object, 'r', options, &block)
  end

  # This error indicates that the object was modified between being opened
  # and being read.
  class ReadModifiedError < IOError; end

  class ReadWrapper < Wrapper

    # Default buffer size for line parser in bytes
    LINE_BUFFER_SIZE = 5 * 1024 * 1024 # MiB

    include Enumerable

    # Current byte position in S3 object
    attr_accessor :pos

    def initialize(s3object, options = {})
      super(s3object)

      @options = {
        :line_buffer_size => (options[:line_buffer_size] || LINE_BUFFER_SIZE)
      }
      @last_modified = @s3object.last_modified
    end

    # Reads data from S3 object.
    #
    # @param [Integer] bytes number of bytes to read
    def read(bytes = nil, outbuf = nil)
      @content_length ||= @s3object.content_length

      return '' if (@pos >= @content_length) || (bytes == 0)

      bytes ||= @content_length

      upper_bound = @pos + bytes - 1
      upper_bound = (@content_length - 1) if upper_bound >= @content_length

      data = @s3object.read :range => @pos..upper_bound, :if_unmodified_since => @last_modified

      @pos = upper_bound + 1

      outbuf.replace data if outbuf 

      return data

    rescue AWS::S3::Errors::PreconditionFailed
      fail ReadModifiedError, "S3 object #{@s3object.key} was updated during read (modified since #{@last_modified.to_s})"
    end

    def eof?
      (@content_length = @s3object.content_length) && (@pos >= @content_length)
    end

    # Rewinds position to the very beginning of S3 object.
    def rewind
      @pos = 0
    end

    # Iterates over S3 object lines.
    #
    # @param [String] separator line separator string
    def each(separator = $/)
      return enum_for(:each, separator) unless block_given?

      line = ''
      newline_pos = nil

      # Either trying to parse the remainder or reading some more data
      while newline_pos || !(buffer = read(@options[:line_buffer_size])).empty?
        prev_newline_pos = newline_pos || 0
        newline_pos = buffer.index(separator, prev_newline_pos)

        if newline_pos
          line << buffer[prev_newline_pos..newline_pos]
          newline_pos += 1
          yield line
          line = ''
        else
          line << buffer[prev_newline_pos..-1]
        end
      end

      # Flush the remainder if body doesn't end with separator
      yield line unless line.empty?

      return self
    end
    alias lines each
    alias each_line each

    # Returns one string at a time.
    #
    # @param [String] separator line separator string
    def gets(separator = $/)
      @_gets ||= enum_for(:each, separator)
      @_gets.next
    rescue StopIteration
      nil
    end
  end
end
