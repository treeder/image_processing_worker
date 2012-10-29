Image Processing Worker for IronWorker
================================

A worker for IronWorker to process images.

## Quick Start

First off, you need an [Iron.io](http://www.iron.io) account, if you don't have one go sign up for a free account.

Second, you need to have your [iron.json file setup](http://dev.iron.io/worker/reference/configuration/).

Now you can get cracking!

### 1. Add this worker to your account

First install the iron_worker_ng gem:

```
$ gem install iron_worker_ng
```

From the command line:

```
$ iron_worker upload https://github.com/treeder/image_processing_worker/blob/master/image_processor.worker
```

### 2. Start using it!

You can queue up tasks for it in any language. Check out our [Client Libraries](http://dev.iron.io/worker/)
in the language of your choice to make it easy, but here's an example using ruby:

Now go look at [HUD](http://hud.iron.io) to see the task and the log.

And here's the same thing using Ruby:

```ruby
require 'iron_worker_ng'

# Create the worker payload which has all our image manipulation functions we want to perform.
# See enqueue.rb for more operations.
payload = {
    aws: {
        access_key: "MY ACCESS KEY",
        secret_key: "MY SECRET KEY",
        s3_bucket_name: "MY BUCKET NAME"
    },
    image_url: "http://dev.iron.io/images/iron_pony.png",
    operations: [
        {
            op: 'sketch',
            format: 'jpg',
            destination: "sketch.jpg"
        }
    ]
}

client = IronWorkerNG::Client.new()
client.tasks.create(
    'image_processor', payload
)
```

Now go look at [HUD](http://hud.iron.io) to see the task and the log.

## Want to modify the worker to suit your needs?

1. Clone this repo (or fork it and clone your own - feel free to make a pull request when you're done).
1. Install required gems: `iron_worker install image_processor`
1. Make your changes
1. Upload your changes to your Iron account: `iron_worker upload image_processor`
1. Share your new worker!

