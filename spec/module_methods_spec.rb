RSpec.describe 'Module Methods' do
  it 'Returns the vendor path' do
    expect(Inkblot.vendor_path).to match(/vendor/)
    expect(Dir.exist?(Inkblot.vendor_path)).to be(true)
  end

  it 'Returns a joined vendor path when given args' do
    pth = Inkblot.vendor_path('with', 'subfolders')

    expect(pth).to match(%r{with/subfolders})
    expect(pth).to match(/vendor/)
  end

  it 'Has a screen size set' do
    expect(Inkblot.screen_size).not_to be(nil)
    expect(Inkblot.screen_size).to be_a(Hash)
  end

  it 'Can set a new screen size' do
    old_siz = Inkblot.screen_size
    new_siz = { width: 1900, height: 1080 }.freeze

    Inkblot.screen_size = new_siz
    same_siz = Inkblot.screen_size == new_siz
    Inkblot.screen_size = old_siz

    expect(same_siz).to eq(true)
  end

  it 'Has a button pinout' do
    expect(Inkblot.button_pinout).not_to be(nil)
    expect(Inkblot.button_pinout).to be_a(Array)
  end

  it 'Can set a new button pinout' do
    old_pin = Inkblot.button_pinout
    new_pin = [6, 7, 8, 9].freeze

    Inkblot.button_pinout = new_pin
    same_pin = Inkblot.button_pinout == new_pin
    Inkblot.button_pinout = old_pin

    expect(same_pin).to eq(true)
  end
end
