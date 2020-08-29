RSpec.describe Procmux do
  it "has a version number" do
    expect(Procmux::VERSION).not_to be nil
  end

  it "does something useful" do
    pm = Procmux::Prox.new procfile: 'spec/fixtures/Procfile'

    expect(pm.parsed).to eq([
                              Procmux::ProcEntry.new('foo', 'foobar'),
                              Procmux::ProcEntry.new('nya', 'meow'),
                              Procmux::ProcEntry.new('test', 'command -- : * ; \'\'"".'),
                            ])
  
  end
end
