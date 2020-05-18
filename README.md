# Inkblot

Inkblot is a gem for interacting with Waveshare's line of E-paper displays on the Raspberry Pi using ruby. It includes components for outputting images, text, and menus to the EPD as well as reading input from HAT buttons on the side.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'inkblot', github: 'jtp184/inkblot'
```

You can also download and install it globally with

```bash
git clone https://github.com/jtp184/inkblot.git
cd inkblot
rake install
```

## Usage

### Getting Started

### Display

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

One of the easiest ways to start using Inkblot is to add a `#to_display` method on your object which returns a component.

```ruby
class SomethingToShow
  def initialize(smth)
    @something = smth.to_s
  end

  def to_display
    Inkblot::Components::SimpleText.new(text: @something)
  end
end

Inkblot::Display.show(SomethingToShow.new("Cinnamon Buns"))
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

### Converters

The `Converter` class and its subclasses are used to transform input data into other forms, with the end goal of being able to display it on the EPD. Converters are used internally by Components to render their HTML, and are first-class displayables in and of themselves.

#### Converter

Abstract parent class for common functionality. It defines the overridable `#convert` method which is used by the `#convert!` method to produce the output.

#### ImageConverter

The `ImageConverter` class can take images on disk, and through ImageMagick resize and convert them into 1-deep `.bmp` files suitable for display on the EPD.

```ruby
# Paths
i = ImageConverter.new(input: "/home/pi/img.png")
# File and Tempfile objects
j = ImageConverter.new(input: File.new("/home/pi/img.png"))
# Binary image data
k = ImageConverter.new(input: File.read("/home/pi/img.png"))

i.convert! && i.output # => Tempfile
```

#### HtmlConverter

The `HtmlConverter` takes in an HTML doc as input, and transforms it into an image using [wkhtmltopdf](https://wkhtmltopdf.org/). This image is then piped through an `ImageConverter` so that it can be rendered on the EPD

```ruby
html_doc = <<DOC
<html>
  <head></head>
  <body>
    <p>Happy Meal with Extra Happy</p>
  </body>
</html>
DOC

h = HtmlConverter.new(input: html_doc)

h.image_contents # => \"BM\\xFE\\u0018\\u0000\\u0000\\u0000..."
```

### Components

Components are composable views. They're written as ultra-basic ERB/HTML templates, with scaling applied to look good at the resolution of the EPD. These are then passed into the `HtmlConverter`. No writing or comprehension of HTML is necessary though, as you merely pass in options to the constructor.

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
    <div style="...">
      <h1 style="font-family: monospace; ">Several</h1>
    </div>

    <div style="...">
      <h1 style="font-family: monospace; ">Different</h1>
    </div>

    <div style="...">
      <h1 style="font-family: monospace; ">Components</h1>
    </div>
  </body>
</html>
```

### Built-in Components

#### Base Component

The `Component` class is the superclass of all other components, as well as a component itself. Components have a `#options` method, a hash containing their customization options. The base component has only one relevant option, its body.

```ruby

Inkblot::Components::Component.new(body: %q(<h1>A Simple Component</h1>))

# You can also set width and height on any component like so
Inkblot::Components::Component.new do |c|
  c.body = %q(<p>small text</p>)

  c.div_height = 100 # height: 100%
  c.div_width = '500px' # width: 500px
  c.div_height = :full # height = Display.size[:height] 
  c.fullscreen = true # Same as c.div_height = c.div_width = :full
end
```

Other components subclass from this, and have their own customization options. Composed components from `Component.create` are instances of the base component class.

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

#### BarCode

The `BarCode` class can generate and render EAN-13 style barcodes.

```ruby
Inkblot::Components::BarCode.new(code: "123123123123")
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

Components are subclasses of `Inkblot::Components::Component`, which gives them all common behavior around generating their HTML representations. You can create subclasses of Component if you want to create customized views and behaviors, or if you want to go outside of the HTML template model but still use the Display / Buttons functions.

Components optionally override the `#computed` method. This method allows options to be calculated at render time by returning a hash of program-defined options merged into the user defined ones.

```ruby
def computed
  {
    element_name: lookup_name(options[:element]),
    element_weight: lookup_weight(options[:element])
  }
end
```

#### Templates

A Template is an ERB file, like a rails view partial. The built-in components store their templates in a common directory within the gem's vendor directory, and name them after the class. You can load custom templates a couple of different ways.

```ruby
# Pass it as a class option to a generic component
class MyUniqueComponent < Inkblot::Components::Component
  # ...
end

user_info = { first_name: "Erek", last_name: "King"}

muc = MyUniqueComponent.new(user_info, { template_base_path: "/path/to/my/templates" }) do |mc|
  mc.full_name = [mc.first_name, mc.last_name].join(' ')
end

muc.send(:template_path) # => "/path/to/my/templates/MyUniqueComponent.html.erb"
```

```ruby
# Create a new root object for Components to be based off of 
class ParentComponent < Inkblot::Components::Component
  
  private

  def template_base_path
    @template_base_path ||= "/path/to/my/templates"
  end
end

class MyFirstComponent < ParentComponent
  # ...
end

class MySecondComponent < ParentComponent
  # ...
end

MyFirstComponent.new.send(:template_path) # => "/path/to/my/templates/MyFirstComponent.html.erb"
MySecondComponent.new.send(:template_path) # => "/path/to/my/templates/MySecondComponent.html.erb"

```

```ruby
# Overriding the template_path method entirely
class MyNewComponent < Inkblot::Components::Component
  def template_path
    "/path/to/my/templates/NewComponentTemplate.html.erb"
  end
end

mnc_tmp = MyNewComponent.new.template
fil = File.read("/path/to/my/templates/NewComponentTemplate.html.erb")

mnc_tmp == fil # => true
```

Components expect that they come with an HTML Template and should produce a bmp version of it for the display. If your components don't intend to use HTML templates, you can still output them to the screen by overriding the `#convert` function

```ruby
class PhotoFrame < Inkblot::Components::Component
  # ...
  def convert
    # Return any converter, or elsewise displayable object here
    ImageConverter.new(input: binary_img_data)
  end
end
```

#### Helpers

Helper classes share common behavior across components. They're nothing more than modules, with extendable and inheritable methods for Components.

##### Paginated

The `Paginated` helper deals with content that has multiple subsequent views. You must define a method which sets up this pagination, and returns an integer page count

```ruby
require 'inkblot/components/helpers/paginated'

class SlideShow < Inkblot::Components::Component
  include Inkblot::Components::Helpers::Paginated

  # Must return the page count
  paginate_with :pagify
  # Defaults to zero, but can be overridden
  start_page 0

  # More work could be done here to set up the pages themselves
  def pagify
    options[:slides].count
  end

  # Override to display different content depending on the page
  def to_display
    options[:slides][current_page]
  end
end

s = SlideShow.new do |sh|
  sh.fullscreen = true
  sh.slides = Array.new(10) do |x|
    Inkblot::Components::SimpleText.new(text: "Slide #{x}", border_size: 10, div_height: 95, div_width: 95)
  end
end

s.page_count # => 10
s.current_page # => 0

# Page navigation
s.next_page && s.current_page # => 1
s.prev_page && s.current_page # => 0

s.prev_page && s.current_page # => 0, won't go negative

s.current_page = s.page_count - 1 # Can directly set as well
s.next_page && s.current_page # => 9, won't go out of bounds
```

##### MultiState

The `MultiState` helper assists with defining and transitioning between enumerated states for content. States are defined via a class method, and the current state can be read/written. A different collection is maintained for each state.

```ruby
require 'inkblot/components/helpers/multi_state'

class TrafficLight < Inkblot::Components::Component
  def_states :green, :yellow, :red
  default_state :red

  def initialize
    super
    # "Setter" mode, set the content to the block's return value
    content_for_state(:green) { "#00FF00" }
    content_for_state(:yellow) { "#FFFF00" }
    content_for_state(:red) { "#FF0000" }
  end

  def transition_state
    case state
    when :green
      state = :yellow
    when :yellow
      state = :red
    when :red
      state = :green
    end

    self
  end

  private

  def computed
    # "Getter" mode, implicitly uses the state method if no state is given
    { hex_color: content_for_state }
  end
end

t = TrafficLight.new

t.content_for_state(:green) # => "#00FF00"
t.content_for_state(:yellow) # => "#FFFF00"
t.content_for_state(:red) # => "#FF0000"

t.state # => :red
t.transition_state.state # => :green
t.transition_state.state # => :yellow
t.transition_state.state # => :red
```

##### DataUrl

The `DataUrl` helper helps turn binary image data into a data url suitable for the src attribute of an img tag.

```ruby
require 'inkblot/components/helpers/data_url'

class Lithograph < Inkblot::Components::Component
  include Inkblot::Components::Helpers::DataUrl

  private

  def computed
    {
      data_url: data_url_from_binary(File.read(options[:image_path]))
    }
  end
end

```

## Contributing

Bug reports, feature ideas, and pull requests are welcome on GitHub at https://github.com/jtp184/inkblot

