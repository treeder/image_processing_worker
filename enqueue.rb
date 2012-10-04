require 'yaml'
require 'iron_worker_ng'

# Create an IronWorker client
config_data = YAML.load_file 'config.yml'
client = IronWorkerNG::Client.new()

client.tasks.create(
    'image_processor',config_data
)
