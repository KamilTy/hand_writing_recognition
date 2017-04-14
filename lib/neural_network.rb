require 'rmagick'
require 'ruby-fann'
require 'base64'
include Magick

BASE_DIR      = Rails.root.to_s
TRAINNING_DIR = "#{BASE_DIR}/tmp/trainning"

SAVED_TRAINNING_FILE = "#{TRAINNING_DIR}/training_file1000.train"

class NeuralNetwork

  def self.recognize(image)
    self.new(image).recognize
  end

  def initialize(image)
    @image = Base64.decode64(image.gsub('data:image/png;base64,', ''))
    @fann = RubyFann::Standard.new(:filename => "#{SAVED_TRAINNING_FILE}")
    puts 'executed initialize'
    #@image = image
    #@image = (image.gsub('data:image/png;base64,', ''))
  end

  def create_array_for_testing(image)
    rmagick_image = image
    image_pixels = []

    white = 0
    black = 0

    rmagick_image.each_pixel do |px, x, y|
      if px.red < 10000 # && px.green == 0 && px.blue == 0
        image_pixels << 1
        black += 1
      else
        image_pixels << 0
        white += 1
      end
    end
    puts "the amount of blacks: #{black}"
    puts "the amount of white: #{white}"
    puts image_pixels.size
    image_pixels
  end

  def get_answer(outputs)
    # highest_value = outputs.each_with_index.max
    puts outputs.max
    highest_value = outputs.index(outputs.max)
    puts highest_value
    if outputs.max > 0.80
      answer = highest_value
    else
      answer = "?"
    end
    answer
  end

  def recognize
    # call NN
    rmagick_image = Magick::ImageList.new.from_blob(@image)
    #rmagick_image = rmagick_image.flatten_images
    #rmagick_image[0].format = "png"
    rmagick_image[0].background_color='White'
    rmagick_image[0].fuzz=10
    rmagick_image[0].trim.resize(30, 50).write("#{TRAINNING_DIR}/00.png")
    img_for_testing = ImageList.new("#{TRAINNING_DIR}/00.png")
    array_of_pixels = create_array_for_testing(img_for_testing)
    outputs = @fann.run(array_of_pixels)
    answer = get_answer(outputs)
    answer.to_s

    # [0, 1, 2, 3, 4, 5, 6, 7, 8, 9].sample
  end

end
    # # rmagick_image[0].format = "png"
