require_relative 'bundle/bundler/setup'
require 'rest'
require 'iron_worker'

MAX_IMAGES = 1000

rest = Rest::Client.new
images = JSON.parse(rest.get("https://unsplash.it/list").body)
p images.size
client = IronWorker::Client.new()
images.each_with_index do |im,i|
  puts "Queuing task for image #{i}"
  # p im
  payload = IronWorker.payload
  payload = payload.merge({
      image_url: "https://unsplash.it/200/300?image=#{im['id']}",
      operations: [
          {
              op: 'sketch',
              format: 'jpg',
              destination: "image_#{im['id']}"
          }
      ]
  })
  task = client.tasks.create('treeder/image_processor', payload)
  # puts task.id
  break if i > MAX_IMAGES
end
