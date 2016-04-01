module MojoLogger
  class DefaultAdapter

    def format(api_request, category, message, options=nil)
      msg = {
        'session_id'   => api_request[:session_id],
        'reference_id' => api_request[:reference_id],
        'api'          => api_request[:api],
        'category'     => category,
        'message'      => message
      }

      msg.merge!(process_options(options)) if options
      msg
    end

    private

    def process_options(options)
      if options.is_a?(Hash)
        options
      else
        { 'options' => options }
      end
    end

  end
end

