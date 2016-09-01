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
      if RUBY_PLATFORM == 'java'
        expect(MojoLogger.logger.class).to eq(Java::OrgApacheLog4j::Logger)
      else
        expect(MojoLogger.logger.class).to eq(Logger)
      end
    end

    it 'caches the logger object' do
      first = MojoLogger.logger
      expect(first.object_id).to eq(MojoLogger.logger.object_id)
    end

  end

  context '.debug, .info, .warn, .error, .fatal' do

    it 'delegates to #logger' do
      [:debug, :info, :warn, :error, :fatal].each do |lvl|
        expect(MojoLogger.logger).to receive(lvl)
        MojoLogger.send(lvl, *@mojo_params)
      end
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

    context 'default logger' do
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

      it 'accepts a string for options' do
        expect(JSON.parse(MojoLogger.mojo_msg(
          @api_request,
          "category",
          "this is a message",
          "This is an options...???"
        ))["options"]).to eq("This is an options...???")
      end

      it 'does not merge options when no options are passed.' do
        expect(JSON.parse(MojoLogger.mojo_msg(
          @api_request,
          "category",
          "this is a message"
        ))["options"]).to eq(nil)
      end

      it 'prints the application name' do
        config = MojoLogger.config { |c| c.application_name = "RspecApp" }
        expect(JSON.parse(MojoLogger.mojo_msg(
          @api_request,
          "category",
          "this is a message"
        ))["app"]).to eq("RspecApp")
      end

      it 'prints the env' do
        config = MojoLogger.config { |c| c.application_name = "RspecApp" }
        expect(JSON.parse(MojoLogger.mojo_msg(
          @api_request,
          "category",
          "this is a message"
        ))["env"]).to eq("test")
      end

      it 'prints the time' do
        config = MojoLogger.config { |c| c.application_name = "RspecApp" }
        expect(JSON.parse(MojoLogger.mojo_msg(
          @api_request,
          "category",
          "this is a message"
        ))["time"]).to_not eq(nil)
      end

    end

    context 'other adapters' do
      class CustomAdapter
        def format(msg, msg2)
          { msg: msg, msg2: msg2 }
        end
      end

      before do
        config = MojoLogger.config { |c| c.adapter = CustomAdapter.new }
      end

      it 'prints the default keys' do
        res = JSON.parse(MojoLogger.mojo_msg('first!', 'second!'))
        expect(res["time"]).to_not eq(nil)
        expect(res["app"]).to_not eq(nil)
        expect(res["env"]).to_not eq(nil)
      end

      it 'prints the custom keys' do
        res = JSON.parse(MojoLogger.mojo_msg('first!', 'second!'))
        expect(res["msg"]).to eq('first!')
        expect(res["msg2"]).to eq('second!')
      end

    end

    context '.level' do
      before do
        MojoLogger.config { |c| c.default_log_level = :warn }
      end

      after do
        MojoLogger.config { |c| c.default_log_level = :debug }
      end

      it 'returns the current log level' do
        expect(MojoLogger.level).to eq(:warn)
        MojoLogger.level = :warn
        expect(MojoLogger.level).to eq(:warn)
      end

    end

    context '.level=' do
      before do
        MojoLogger.config { |c| c.default_log_level = :debug }
        expect(MojoLogger.level).to eq(:debug)
      end

      after do
        MojoLogger.config { |c| c.default_log_level = :debug }
      end

      it 'sets the log level' do
        MojoLogger.level = :warn
        expect(MojoLogger.level).to eq(:warn)

        expect(MojoLogger.logger).to receive(:debug).exactly(0).times
        expect(MojoLogger.logger).to receive(:warn).exactly(1).times

        MojoLogger.mojo_debug({},'cat','Message')
        MojoLogger.mojo_warn({},'cat','Message')
      end
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

    it 'allows pattern configuration' do
      config = MojoLogger.config { |c| c.pattern = "%n%n %m %n%n" }
      expect(config.pattern).to eq("%n%n %m %n%n")
    end

    it 'allows max_file_size configuration' do
      config = MojoLogger.config { |c| c.max_file_size = "1MB" }
      expect(config.max_file_size).to eq("1MB")
    end

    it 'allows max_backup_index configuration' do
      config = MojoLogger.config { |c| c.max_backup_index = "5" }
      expect(config.max_backup_index).to eq("5")
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
        if RUBY_PLATFORM == 'java'
          expect(@obj.logger.class).to eq(Java::OrgApacheLog4j::Logger)
        else
          expect(@obj.logger.class).to eq(Logger)
        end
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
