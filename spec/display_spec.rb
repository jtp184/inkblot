RSpec.describe 'Display' do
  describe 'Exports' do
    it 'Properly creates python commands' do
      script_name = Array.new(2) { |n| "example#{n}" }
      script_args = Array.new(3) { |n| "arg#{n}" }

      ex1 = Inkblot::Display.send(:pyscript, script_name[0])
      ex2 = Inkblot::Display.send(:pyscript, script_name[1], *script_args)

      checkit = [ex1, ex2].all? do |ex|
        ex =~ /^python / &&
          ex =~ /example\d\.py/ &&
          ex =~ /#{Regexp.escape(Inkblot.vendor_path)}/
      end

      expect(checkit).to be(true)
      expect(ex2).to match(/#{script_args.join(' ')}/)
    end

    it 'Translates to css sizing' do
      expect(Inkblot::Display.size_css).to match(/px/)
      expect(Inkblot::Display.size_css).to match(/:/)
      expect(Inkblot::Display.size_css.scan(/\d+/).count).to be(2)
    end
  end

  describe 'Current value tests' do
    before :each do
      allow(Inkblot::Display).to receive(:pyscript) { 'echo' }
    end

    it 'Displaying something sets the stored object' do
      expect(Inkblot::Display.current).to be(nil)

      Inkblot::Display.show(Inkblot.vendor_path('qrtest.bmp'))

      expect(Inkblot::Display.current).not_to be(nil)
      expect(Inkblot::Display.current).to eq(Inkblot.vendor_path('qrtest.bmp'))
    end

    it 'Clearing the display clears the stored object' do
      Inkblot::Display.show(Inkblot.vendor_path('qrtest.bmp'))
      expect(Inkblot::Display.current).not_to be(nil)

      Inkblot::Display.clear
      expect(Inkblot::Display.current).to be(nil)
    end

    it 'Knows whether it is empty or not' do
      Inkblot::Display.show(Inkblot.vendor_path('qrtest.bmp'))
      expect(Inkblot::Display.empty?).to be(false)

      Inkblot::Display.clear
      expect(Inkblot::Display.empty?).to be(true)
    end
  end

  describe 'Show tests' do
    before :each do
      allow(Inkblot::Display).to receive(:pyscript) { 'echo' }
    end

    it 'Can display objects with a to_display method' do
      st = Inkblot::Components::SimpleText.new(text: 'Hello')
      item = double('Displayable', to_display: st)

      Inkblot::Display.show(item)

      expect(Inkblot::Display.current).to be(item)
    end

    it 'Can display Components' do
      item = Inkblot::Components::SimpleText.new(text: 'Hello')
      Inkblot::Display.show(item)

      expect(Inkblot::Display.current).to eq(item)
    end

    it 'Can display Converters' do
      item = Inkblot::Converters::ImageConverter.new(input: Inkblot.vendor_path('qrtest.bmp'))
      Inkblot::Display.show(item)

      expect(Inkblot::Display.current).to be(item)
    end

    it 'Can display Files and TempFiles' do
      item = File.open(Inkblot.vendor_path('qrtest.bmp')).tap(&:close)
      Inkblot::Display.show(item)

      expect(Inkblot::Display.current).to be(item)
    end

    it 'Can display files by path' do
      item = Inkblot.vendor_path('qrtest.bmp')
      Inkblot::Display.show(item)

      expect(Inkblot::Display.current).to eq(item)
    end

    it 'Can display plain strings as text' do
      item = 'Hello'
      Inkblot::Display.show(item)

      expect(Inkblot::Display.current).to eq(item)
    end

    it 'Raises an error if the object cannot be displayed' do
      item = 5

      expect { Inkblot::Display.show(item) }.to raise_error(ArgumentError)
    end
  end
end
