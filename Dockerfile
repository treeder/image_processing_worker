FROM treeder/ruby-imagemagick

WORKDIR /worker
ADD . /worker

ENTRYPOINT ["ruby", "image_processor.rb"]
