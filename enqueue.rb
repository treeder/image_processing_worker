require 'uber_config'
require 'iron_worker_ng'

@config = UberConfig.load

# Create the worker payload which has all our image manipulation functions
payload = {
    image_url: "http://dev.iron.io/images/iron_pony.png",
    operations: [
        {
            op: 'resize',
            width : 100,
            height : 100,
            format : 'jpg',
            destination : "resized.jpg"
        },
        {
            op: 'thumbnail',
            width : 50,
            height : 50,
            format : 'jpg',
            destination : "thumb.jpg"
        },
        {
            op: 'sketch',
            format: 'jpg',
            destination : "sketch.jpg"
        },
        {
            op: 'normalize',
            format: 'jpg',
            destination : "normalize.jpg",
        },
        {
            op: 'charcoal',
            format: 'jpg',
            destination : "charcoal.jpg",
        },
        {
            op: 'level',
            format: 'jpg',
            destination : "levelled.jpg",
            black_point : 10,
            white_point : 250,
            gamma : 1.0,
        }
    ]
}


client = IronWorkerNG::Client.new(@config)
client.tasks.create(
    'image_processor', config_data
)
