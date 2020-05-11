# Inkblot

Inkblot is a gem for interacting with Waveshare's line of E-paper displays on the Raspberry Pi using ruby. It includes components for outputting images, text, and menus to the EPD as well as reading input from HAT buttons on the side.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'inkblot', github: 'jtp184/inkblot'
```

## Usage

### Getting Started

### The Display class

The `Display` class handles outputting to the screen. It accepts an argument to its `.show` method to output to the screen, which can be any number of displayable objects.

```ruby
items = []

# Primarily used to display Components and Converters
items << Inkblot::Components::SimpleText.new(text: 'Hello')
items << Inkblot::ImageConverter.new(path: '/home/pi/img.png')
# Can also display (already correct bmp) files directly or by path
items << File.new('/home/pi/bump.bmp') # Or a TempFile
items << '/home/pi/bump.bmp'

# call, show, and [] all work
Inkblot::Display.call(items[0])
Inkblot::Display.show(items[1])
Inkblot::Display[items[2]]
Inkblot::Display.(items[3])

# Plaintext also works
Inkblot::Display.("Show Me")
```
### Buttons

The `Buttons` class deals with input from the HAT buttons. The buttons communicate over the Pi's GPIO pins, and can be used for a broad variety of inputs.

```ruby
# Setting up the buttons for use. This only needs to be run once at the start
Inkblot::Buttons.init
# You can check whether the buttons have been initialized with
Inkblot::Buttons.ready? # => true

# Basic input from buttons. With no argument, blocks until you press a button then returns an index
Inkblot::Buttons.get_input # => 0

# With an argument, it will timeout if no button is pressed.
Inkblot::Buttons.get_input(10) # => nil if no button is pressed for 10 seconds

# It's also possible to get chords instead of single presses.
# Specify the chord length and wait for simultaneous presses.

Inkblot::Buttons.get_multi_input(2) # => [1, 2]
Inkblot::Buttons.get_multi_input(3, 10) # => nil || [0, 1, 3]

# You can also record all button activity within a timeframe

Inkblot::Buttons.get_raw_input(3) # => [[], [0], [0, 1]...]
```

Usually, you'll use the buttons with a display component. Components may have their own defined button actions, and the Buttons class can access them.

```ruby
c = Components::ScrollMenu.new do |sc|
  sc.div_height = sc.div_width = :full
  sc.items = (1..10).to_a.map { |x| "Option #{x}" }
end

Inkblot::Display.show(c)

# Calling .get_press gets the input, then calls the associated proc on the
# currently displayed object, defined under .button_actions
Buttons.get_press

Inkblot::Display.again
```

### Components

### Built-in Components

### Creating new Components

## Contributing

Bug reports, feature ideas, and pull requests are welcome on GitHub at https://github.com/jtp184/inkblot

