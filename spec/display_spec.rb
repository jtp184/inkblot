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

  describe 'Display tests' do
    before :each do
      allow(Inkblot::Display).to receive(:pyscript) { 'echo' }
    end

    xit 'Can display objects with a to_display method' do
    end

    xit 'Can display Components' do
    end

    xit 'Can display Converters' do
    end

    xit 'Can display Files and TempFiles' do
    end

    xit 'Can display files by path' do
    end

    xit 'Can display plain strings as text' do
    end

    xit 'Raises an error if the object cannot be displayed' do
    end
  end
end
