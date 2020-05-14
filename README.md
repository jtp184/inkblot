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
c = Inkblot::Components::ScrollMenu.new do |sc|
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

Components are composable views. They're written as ultra-basic ERB/HTML templates, with scaling applied to look good at the resolution of the EPD. These are then passed into [wkhtmltopdf](https://wkhtmltopdf.org/) and another pass through ImageMagick to convert them into 1-deep `.bmp` files. No writing or comprehension of HTML is necessary though, as you merely pass in options to the constructor.

You can provide options to the constructor with standard or block syntax.

```ruby
Inkblot::Components::SimpleText.new(text: "Works this way")

Inkblot::Components::SimpleText.new do |st|
  st.text = "Or this way"
end
```

Passed in options can be retrieved through the options method, or defined accessors

```ruby
c = Inkblot::Components::SimpleText.new(text: "Text")

c.options[:text] # => "Text"
```

You can also compose components by passing them to `Component.create` method, which will combine the fragments together into a single page, top to bottom.

```ruby
Inkblot::Components::Component.create do |cpt|
  cpt << Inkblot::Components::SimpleText.new(text: "Several")
  cpt << Inkblot::Components::SimpleText.new(text: "Different")
  cpt << Inkblot::Components::SimpleText.new(text: "Components")
end
```

```html
<!DOCTYPE html>
<html>
  <head>

  </head>
  <body style="height: 176px; width: 264px;">
    <div style="border: 0px solid black; box-sizing: border-box; height: 100%; width: 100%; display: flex; flex-flow: column; align-items: center; justify-content: center; text-align: center">
      <h1 style="font-family: monospace; ">Several</h1>
    </div>

    <div style="border: 0px solid black; box-sizing: border-box; height: 100%; width: 100%; display: flex; flex-flow: column; align-items: center; justify-content: center; text-align: center">
      <h1 style="font-family: monospace; ">Different</h1>
    </div>

    <div style="border: 0px solid black; box-sizing: border-box; height: 100%; width: 100%; display: flex; flex-flow: column; align-items: center; justify-content: center; text-align: center">
      <h1 style="font-family: monospace; ">Components</h1>
    </div>
  </body>
</html>
```

### Built-in Components

#### Base Component
#### SimpleText

The `SimpleText` class allows you to do just that, simple text. Sizing can be set explicitly or automatically, as can fonts.

```ruby
Inkblot::Components::SimpleText do |st|
  st.text = "Example Text"
  st.border_size = 10 # Adds an inner border
  st.size = :large # :tiny, :small, :medium, :large or an integer for px
  # Takes in an array of font names and includes them
  st.gfonts = ['Roboto', 'Open Sans', 'Jost', 'Pangolin']
  # Also works with built in fonts like Helvetica
  st.font = "Pangolin"
end
```

#### FullScreenImage

The `FullScreenImage` class displays images. You can pass a variety of image sources in, and it works with other components for nesting and resizing. Images are automatically resized and downsampled.

```ruby
# Sets the img tag src to the url
Inkblot::Components::FullScreenImage.new do |fsi| 
  fsi.url = "https://live.staticflickr.com/2753/4177140189_f5fd431b26_o_d.jpg"
end

# Sets the img tag src to the absolute version of the path
Inkblot::Components::FullScreenImage.new(path: "/home/pi/img.jpg")

# Sets the img tag src as a data url from reading the file
Inkblot::Components::FullScreenImage.new(file: File.new("/home/pi/img.jpg"))

# Sets the img tag src as a data url from the file contents themselves
Inkblot::Components::FullScreenImage.new(binary: File.read("/home/pi/img.jpg"))
```
#### QrCode

The `QrCode` class can generate and render QR Codes to the screen, great for small area and two-channel color.

```ruby
Inkblot::Components::QrCode.new do |qr| 
  qr.message = "http://justinp.io/"
  qr.margin_top = qr.margin_left = -5 # adds a -5% margin
end
```

#### TableList

The `TableList` class displays up to 4 line items in a horizontal table view. If you supply fewer than 4 items, blank entries are produced to keep 4 lines.

```ruby
Inkblot::Components::TableList.new do |tl|
  tl.items = ['Apples', 'Pears', 'Oranges', 'Bananas']
end

```

#### IconPane

An `IconPane` is a two-column layout with icons on the left, and a large rectangular frame on the right. Other components can be placed in the right-hand frame. 

```ruby
Inkblot::Components::IconPane.new do |ic|
  # This symbol is equivalent to %i[nwarr larr swarr swarr]
  # Other icon group presets include :arrows_out, :select, and :agree / :cancel
  # You can also pass strings, or symbols which are considered html symbols
  ic.icons = :arrows_in 

  # A single object or an array works here. Arrays are composed with `Component.create`
  ic.frame_contents = Inkblot::Components::FullScreenImage.new do |fc|
    fc.path = Inkblot.vendor_path('chris_kim.bmp')
  end
end
```

#### ScrollMenu
The `ScrollMenu` can be used for selecting from a list of items, and includes a view and button actions to accomplish this

```ruby
scroll_menu = Inkblot::Components::ScrollMenu.new do |sc|
  sc.items = (1..10).map { |x| "Option #{x}" }
end

# Scroll menu has 4 states: :scroll, :select, :answered, and :canceled
scroll_menu.state # => :scroll

# Scroll menu also has pages of content divided into fours
scroll_menu.current_page # => 0
scroll_menu.page_count # => 3

# Using the menu as User prompting is simple
Inkblot::Display.show(scroll_menu) # Display the component initially

until scroll_menu.concluded? # True when canceled or answered
  # Contains the 4 presented options
  puts "User can see #{scroll_menu.choices.map { |x| %Q("#{x}") }.join(',') }"
  Inkblot::Buttons.get_press # Defers to ScrollMenu's #button_actions method
  Inkblot::Display.again unless scroll_menu.concluded? # Show it again
end

scroll_menu.answer # => One of the options, or nil if canceled
```
### Creating new Components

#### Templates
#### Helpers

## Contributing

Bug reports, feature ideas, and pull requests are welcome on GitHub at https://github.com/jtp184/inkblot

