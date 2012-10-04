require 'open-uri'
require 'RMagick'

require 'aws'
require 'subexec'
require 'mini_magick'

def resize(image, h)
  original_width, original_height = image[:width], image[:height]
  h['width'] ||= original_width
  h['height'] ||= original_height
  image.resize "#{h['width']}x#{h['height']}"
  image
end

def thumbnail(image, h)
  image.combine_options do |c|
    c.thumbnail "#{h['width']}x#{h['height']}"
    c.background 'white'
    c.extent "#{h['width']}x#{h['height']}"
    c.gravity "center"
  end
  image
end

def sketch(image, h)
  image.combine_options do |c|
    c.edge "1"
    c.negate
    c.normalize
    c.colorspace "Gray"
    c.blur "0x.5"
  end
  image
end

def normalize(image, h)
  image.normalize
  image
end

def charcoal(image, h)
  image.charcoal '1'
  image
end

def level(image, h)
  image.level " #{h['black_point']},#{h['white_point']},#{h['gamma']}"
  image
end

def tile(h)
  file_list=[]
  image = MiniMagick::Image.open(filename)
  original_width, original_height = image[:width], image[:height]
  slice_height = original_height / h['num_tiles_height']
  slice_width = original_width / h['num_tiles_width']
  h['num_tiles_width'].times do |slice_w|
    file_list[slice_w]=[]
    h['num_tiles_height'].times do |slice_h|
      output_filename = "filename_#{slice_h}_#{slice_w}.jpg"
      image = MiniMagick::Image.open(filename)
      image.crop "#{slice_width}x#{slice_height}+#{slice_w*slice_width}+#{slice_h*slice_height}"
      image.write output_filename
      file_list[slice_w][slice_h] = output_filename
    end
  end
  file_list
end

def merge_images(col_num, row_num, file_list)
  output_filename = "merged_file.jpg"
  ilg = Magick::ImageList.new
  col_num.times do |col|
    il = Magick::ImageList.new
    row_num.times do |row|
      il.push(Magick::Image.read(file_list[col][row]).first)
    end
    ilg.push(il.append(true))
    ilg.append(false).write(output_filename)
  end
  output_filename
end

def upload_file(filename)
  unless params['disable_network']
    files = [filename].flatten
    files.each do |filepath|
      puts "Uploading the file to s3..."
      s3 = Aws::S3Interface.new(params['aws']['access_key'], params['aws']['secret_key'])
      s3.create_bucket(params['aws']['s3_bucket_name'])
      response = s3.put(params['aws']['s3_bucket_name'], filepath, File.open(filepath))
      if response == true
        puts "Uploading successful."
        link = s3.get_link(params['aws']['s3_bucket_name'], filepath)
        puts "\nYou can view the file here on s3: ", link
      else
        puts "Error uploading to s3."
      end
      puts "-"*60
    end
  end
end

def filename
  File.basename(params['image_url'])
end

def download_image()
  puts "Downloading file: #{filename}"
  unless params['disable_network']
    File.open(filename, 'wb') do |fout|
      open(params['image_url']) do |fin|
        IO.copy_stream(fin, fout)
      end
    end
  end
  filename
end


puts "Worker started"
puts "Downloading image"
filename = download_image
params['operations'].each do |op|

  puts "\n\nPerforming #{k} with #{v.inspect}"
  output_filename = v['destination']
  image = MiniMagick::Image.open(filename)
  image = self.send(k, image, {}.merge(v))
  image.format v['format'] if v['format']
  image.write output_filename
  upload_file output_filename
end
puts "Worker end"