require 'rmagick'
include Magick

file           = "1.jpg"
converted_file = "2.jpg"

image = ImageList.new(file)
image[0].fuzz=10
image[0].trim.resize(30,50).write(converted_file)

# convert 1.jpg -fuzz 50% -trim +repage 2.jpg

# %x( ./centertrim #{converted_file} #{converted_file} )
# image = ImageList.new(converted_file)
# image = image.rotate(90)
# image.write(converted_file)

# 4.times do 
#   %x( ./centertrim #{converted_file} #{converted_file} )
#   image = ImageList.new(converted_file)
#   image = image.rotate(90)
#   image.write(converted_file)
# end
