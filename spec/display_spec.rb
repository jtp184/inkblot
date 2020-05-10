RSpec.describe 'Display' do
	it 'Speaks parseltongue' do
		script_name = Array.new(2) { |n| "example#{n}" }
		script_args = Array.new(3) { |n| "arg#{n}"}

		ex1 = Inkblot::Display.send(:pyscript, script_name[0])
		ex2 = Inkblot::Display.send(:pyscript, script_name[1], *script_args)

		checkit = [ex1, ex2].all? do |ex|
			ex =~ /^python / &&
			ex =~ /example\d\.py/ &&
			ex =~ %r(#{Regexp.escape(Inkblot.vendor_path)})
		end

		expect(checkit).to be(true)
		expect(ex2).to match(/#{script_args.join(' ')}/)
	end
end