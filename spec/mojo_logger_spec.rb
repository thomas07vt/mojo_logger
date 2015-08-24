require 'spec_helper'

describe MojoLogger do
  it 'has a version number' do
    expect(MojoLogger::VERSION).not_to be nil
  end

  before do
    @api_request = {
      session_id: "1234-0000",
      reference_id: "rspec",
      api: "rspec"
    }
    @mojo_params = [
      @api_request,
      "Category",
      "Message",
      { "rspec" => "test" }
    ]
  end

  context '.logger' do

    it 'retuns a generic log4j logger object' do
      expect(MojoLogger.logger.class).to eq(Java::OrgApacheLog4j::Logger)
    end

    it 'caches the logger object' do
      first = MojoLogger.logger
      expect(first.object_id).to eq(MojoLogger.logger.object_id)
    end

  end

  context '.mojo_debug' do
    it 'calls debug on the logger object' do
      expect(MojoLogger.logger).to receive(:debug)
      MojoLogger.mojo_debug(*@mojo_params)
    end
  end

  context '.mojo_info' do
    it 'calls info on the logger object' do
      expect(MojoLogger.logger).to receive(:info)
      MojoLogger.mojo_info(*@mojo_params)
    end
  end

  context '.mojo_warn' do
    it 'calls warn on the logger object' do
      expect(MojoLogger.logger).to receive(:warn)
      MojoLogger.mojo_warn(*@mojo_params)
    end
  end

  context '.mojo_error' do
    it 'calls warn on the logger object' do
      expect(MojoLogger.logger).to receive(:error)
      MojoLogger.mojo_error(*@mojo_params)
    end
  end

  context '.mojo_msg' do

    it 'returns a json message' do
      expect { JSON.parse(MojoLogger.mojo_msg(
        @api_request,
        "category",
        "this is a message"
      )) }.to_not raise_error
    end

    it 'accepts and options hash and merges it onto json' do
      expect(JSON.parse(MojoLogger.mojo_msg(
        @api_request,
        "category",
        "this is a message",
        { mykey: :value }
      ))["mykey"]).to eq("value")
    end

  end

  context '.config' do

    before do
      MojoLogger.class_variable_set(:@@config, nil)
      expect(MojoLogger.class_variable_get(:@@config)).to eq(nil)
    end

    it 'creates a Configurator object' do
      MojoLogger.config
      expect(MojoLogger.class_variable_get(:@@config)).to_not eq(nil)
    end

    it 'returns a Configurator object' do
      expect(MojoLogger.config.class).to eq(MojoLogger::Configurator)
    end

  end



####################
# Module section
####################

  describe 'Module methods' do
    before do
      @obj = OpenStruct.new()
      @obj.extend(MojoLogger)
    end

    context '#logger' do

      it 'retuns a generic log4j logger object' do
        expect(@obj.logger.class).to eq(Java::OrgApacheLog4j::Logger)
      end

      it 'caches the logger object' do
        first = @obj.logger
        expect(first.object_id).to eq(@obj.logger.object_id)
      end

    end

    context '#mojo_debug' do
      it 'calls debug on the logger object' do
        expect(MojoLogger.logger).to receive(:debug)
        @obj.mojo_debug(*@mojo_params)
      end
    end

    context '#mojo_info' do
      it 'calls info on the logger object' do
        expect(MojoLogger.logger).to receive(:info)
        @obj.mojo_info(*@mojo_params)
      end
    end

    context '#mojo_warn' do
      it 'calls warn on the logger object' do
        expect(MojoLogger.logger).to receive(:warn)
        @obj.mojo_warn(*@mojo_params)
      end
    end

    context '#mojo_error' do
      it 'calls warn on the logger object' do
        expect(MojoLogger.logger).to receive(:error)
        @obj.mojo_error(*@mojo_params)
      end
    end

  end

end