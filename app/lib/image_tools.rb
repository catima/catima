

module ImageTools
  include MiniMagick

  module_function
  def thumbnail(src, dest, size, mode=:fill, center=nil)
    return nil unless File.file?(src)
    i = Image.open src
    sz = size.map { |s| s.to_s }.join('x')
    center = [i.width / 2, i.height / 2] if center.nil?
    if mode == :fill
      len = [i.width, i.height].min
      x_offset = center[0] - (len / 2)
      y_offset = center[1] - (len / 2)
      i.crop "#{len}x#{len}+#{x_offset}+#{y_offset}"
    end
    i.resize sz
    i.quality 75
    i.write dest
  end
end