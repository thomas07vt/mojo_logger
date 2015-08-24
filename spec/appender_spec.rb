require_relative  'spec_helper'

describe MojoLogger::Appender do

  context '.initialize' do
    it 'requires a name' do
      a = MojoLogger::Appender.new("console")
      expect(a.name).to eq("console")
    end
  end

  context '#level=' do
    before do
      @apndr = MojoLogger::Appender.new("Rspec")
    end

    it 'sets @level when a symbol is given' do
      @apndr.level = :debug
      expect(@apndr.level).to eq("DEBUG")
    end

    it 'sets @level when a string is given' do
      @apndr.level = "warn"
      expect(@apndr.level).to eq("WARN")
    end

    it 'raises when an invalid level is given' do
      expect { @apndr.level = 'not_valid' }.to \
        raise_error
    end

  end

  context '#file' do
    before do
      @apndr = MojoLogger::Appender.new("Rspec")
    end

    it 'accepts a path the a log4j.properties file' do
      @apndr.file = 'conf/log4j.properties'
      expect(@apndr.file).to \
        eq(File.expand_path('conf/log4j.properties'))
    end
  end

  context '#generate_properties_string' do
    it 'generates a console string correctly.'
    it 'generates file properties when a file is given'
  end

end

