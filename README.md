Image Processing Docker Worker for IronWorker
================================

An image processing Docker image for us on IronWorker to process images.

## Setup your Iron account (if you don't have one yet)

First off, you need an [Iron.io](http://www.iron.io) account, if you don't have one go sign up for a free account.

Second, you need to have your [Iron credentials setup](http://dev.iron.io/worker/reference/configuration/) and the
[iron CLI tool](https://github.com/iron-io/ironcli) installed.

Now you can get cracking!

## Usage

**NOTE**: Replace `treeder` everywhere below with your Docker Hub username.

The payload for this worker defines the image operations you'd like to perform and where
here to store the results. See `payload_example.json` for an example.

## Test / build

### 1. Vendor dependencies

```sh
docker run --rm -v "$PWD":/worker -w /worker iron/ruby:dev bundle install --standalone --clean
```

### 2. Test with a single image

```sh
docker run --rm -it -e "PAYLOAD_FILE=payload.json" -v "$PWD":/worker -w /worker treeder/ruby-imagemagick ruby image_processor.rb
```

### 3. Build Docker image

```sh
docker build -t treeder/image_processor:latest .
```

### 4. Test Docker image with a single image

```sh
docker run --rm -it -e "PAYLOAD_FILE=payload.json" -v "$PWD":/worker -w /worker treeder/image_processor
```

### 5. Push to Docker Hub

```sh
docker push treeder/image_processor
```

## Run a single task on IronWorker

Now that we have our Micro Worker built as an image and it's up on Docker Hub,
we can start using that to process massive amounts of images.  

First, w need to tell IronWorker about the image we just made:

```sh
iron worker upload --name treeder/image_processor treeder/image_processor
# TODO: Change this to register when ready
```

Then we can just start queuing tasks!  The following is just a quick way to test
a single task:

```sh
iron worker queue --payload-file payload.json --wait treeder/image_processor
```

In normal use, you'll be queuing up tasks in your code via the API, for example, here's
the curl command to queue up a task.

```sh
curl -H "Content-Type: application/json" -H "Authorization: OAuth $IRON_TOKEN" \
 -d '{"tasks":[{"code_name":"treeder/image_processor"}]}' \
 "http://worker-aws-us-east-1.iron.io/2/projects/$IRON_PROJECT_ID/tasks"
```

Now go look at [HUD](http://hud.iron.io) to see the task and the log.

## Run a ton of tasks on IronWorker!

Now let's batch up ALL the images.

```sh
docker run --rm -it -e "PAYLOAD_FILE=payload.json" -e IRON_TOKEN -e IRON_PROJECT_ID -v "$PWD":/worker -w /worker iron/ruby ruby batch.rb
```

Boom, that will queue up almost 1000 images and they will all be processed in parallel
and put into your s3 bucket in a **matter of seconds**.
