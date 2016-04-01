require 'spec_helper'

describe MojoLogger::DefaultAdapter do

  before do
    @da = MojoLogger::DefaultAdapter.new
  end

  context '#format()' do

    it 'accepts 4 arguments' do
      expect { @da.format({}, "CAT", "MESSAGE", {}) }.to_not raise_error
    end

    it 'returns a hash' do
      out = @da.format({}, "CAT", "MESSAGE", {})
      expect(out.class).to eq(Hash)
    end

  end

end

