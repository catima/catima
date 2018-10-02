module ImageTools
  include MiniMagick

  module_function

  def thumbnail(src, dest, size, mode=:fill, crop=[0, 0, 100, 100])
    return nil unless File.file?(src)

    i = Image.open src
    sz = size.map { |s| s.to_s }.join('x')
    cr = crop.map { |n| n / 100.0 }
    if mode == :fill
      # Convert cropping from image percentages to pixels
      # and make sure it is squared
      width = i.width * cr[2]
      height = i.height * cr[3]
      x_offset = i.width * cr[0]
      x_offset += (width - height) / 2 if width > height
      y_offset = i.height * cr[1]
      y_offset += (height - width) / 2 if height > width
      len = [width, height].min
      i.crop "#{len}x#{len}+#{x_offset}+#{y_offset}"
    end
    i.resize sz
    i.quality 75
    i.write dest
  end
end
