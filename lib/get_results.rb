require 'rmagick'
require 'ruby-fann'
require 'json'
include Magick
require 'base64'

BASE_DIR        = "/home/Projects/neural_network_project"
DIGITS_DIR      = "#{BASE_DIR}/Digits"
LIB_DIR         = "#{BASE_DIR}/lib"
JPGS_DIR        = "#{DIGITS_DIR}/jpgs"
CONVERTED_DIR   = "#{DIGITS_DIR}/converted"
TRAINNING_DIR   = "#{BASE_DIR}/tmp/trainning"

FOR_TESTING_DIR           = "#{JPGS_DIR}/notLearned"
FOR_TESTING_CONVERTED_DIR = "#{CONVERTED_DIR}/notLearned"

def convert_images_for_trainning
  (0..9).each do |digit|
    cont = 0
    jpg_images = Dir["#{JPGS_DIR}/#{digit}/*.jpg"]

    jpg_images.each do |filepath|
      new_filepath = "#{CONVERTED_DIR}/#{digit}/#{cont}.png"
      rmagick_image = ImageList.new("#{filepath}")
      rmagick_image[0].fuzz=10 
      rmagick_image[0].trim.resize(30, 50).write(new_filepath)
      @all_images << new_filepath
      cont += 1
    end
  end
end

def convert_images_for_testing
  cont = 0
  images = Dir["#{FOR_TESTING_DIR}/*.jpg"]

  images.each do |filepath|
    filename = filepath.match(/\/(..)\.jpg/) { $1 }
    puts filename
    new_filepath = "#{FOR_TESTING_CONVERTED_DIR}/#{filename}.png"
    rmagick_image = ImageList.new("#{filepath}")
    rmagick_image[0].fuzz=50 
    rmagick_image.trim.resize(30, 50).write(new_filepath)
    @all_images_for_testing << new_filepath
    cont += 1
  end
end

def create_array_of_arrays_trainning
  @all_images.each_with_index do |image, idx|
    puts ("#{idx}#{image}")
    
    rmagick_image = ImageList.new(image)
    image_pixels = []

    rmagick_image.each_pixel do |px, x, y|
      if px.red == 0 # && px.green == 0 && px.blue == 0
        image_pixels << 1
      else
        image_pixels << 0
      end
    end
    @input_arrays << image_pixels
  end
end

def create_array_of_arrays_testing
  @all_images_for_testing.each_with_index do |image, idx|
    puts ("#{idx}#{image}")
    
    rmagick_image = ImageList.new(image)
    image_pixels = []

    rmagick_image.each_pixel do |px, x, y|
      if px.red == 0 # && px.green == 0 && px.blue == 0
        image_pixels << 1
      else
        image_pixels << 0
      end
    end
    @testing_input_arrays << image_pixels
  end
end


@all_images = []
# Convert images
convert_images_for_trainning
puts 'Status: images converted'

# Prepare inputs for Neural Network
@input_arrays = []
create_array_of_arrays_trainning

#
@all_images_for_testing = []
convert_images_for_testing

#
@testing_input_arrays = []
create_array_of_arrays_testing

amount_of_each_digit = Dir["#{JPGS_DIR}/0/*.jpg"].size
puts amount_of_each_digit
@desired_outputs = []

# amount of times each desired output
# Digit 0
amount_of_each_digit.times do
   @desired_outputs << [1,0,0,0,0,0,0,0,0,0]
end
# Digit 1
amount_of_each_digit.times do
   @desired_outputs << [0,1,0,0,0,0,0,0,0,0]
end
# Digit 2
amount_of_each_digit.times do
   @desired_outputs << [0,0,1,0,0,0,0,0,0,0]
end
# Digit 3
amount_of_each_digit.times do
   @desired_outputs << [0,0,0,1,0,0,0,0,0,0]
end
# Digit 4
amount_of_each_digit.times do
   @desired_outputs << [0,0,0,0,1,0,0,0,0,0]
end
# Digit 5
amount_of_each_digit.times do
   @desired_outputs << [0,0,0,0,0,1,0,0,0,0]
end
# Digit 6
amount_of_each_digit.times do
   @desired_outputs << [0,0,0,0,0,0,1,0,0,0]
end
# Digit 7
amount_of_each_digit.times do
   @desired_outputs << [0,0,0,0,0,0,0,1,0,0]
end
# Digit 8
amount_of_each_digit.times do
   @desired_outputs << [0,0,0,0,0,0,0,0,1,0]
end
# Digit 9
amount_of_each_digit.times do
   @desired_outputs << [0,0,0,0,0,0,0,0,0,1]
end

@train = RubyFann::TrainData.new(
  inputs: @input_arrays,
  desired_outputs: @desired_outputs
)

def execute_trainning_and_comparison(hid_neuron_value)
  @fann = RubyFann::Standard.new(:filename => "#{TRAINNING_DIR}/training_file#{hid_neuron_value}.train")
  results = []

  @testing_input_arrays.each_with_index do |arr, idx|
    outputs              = @fann.run(arr)

    results << outputs
  end
  File.open("#{TRAINNING_DIR}/#{hid_neuron_value} neurons.txt", "w") { |file| file.write(JSON.pretty_generate(results)) }  
end

puts "sizes of everything \n"
puts "all_images: #{@all_images.size}"
puts "all_images_for_testing: #{@all_images_for_testing.size}"
puts "input_arrays: #{@input_arrays.size}"
puts "size of input array[1]: #{@input_arrays[1].size}"
puts "testing_input_arrays: #{@testing_input_arrays.size}"

neurons = 0
(1..25).each do |num|
  puts "Execution number: #{num}"
  execute_trainning_and_comparison(neurons + (num * 50))
end