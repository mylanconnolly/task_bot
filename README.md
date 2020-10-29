# TaskBot

This gem is designed to allow Google Cloud Task to be used as a backend for
ActiveJob. This could make life a bit easier if you're utilizing something like
Google Cloud Run to serve your Rails app and are looking for a solution for
a background worker.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'task_bot'
```

And then execute:

    $ bundle install

## Usage

First, you'll need to create the Cloud Task queues you wish to interact with.
For more details on that, you can
[check out the documentation](https://cloud.google.com/tasks/docs).

Configure Rails to use this as your ActiveJob backend:

```ruby
Rails.application.config.active_job.queue_adapter = ActiveJob::TaskBot::Adapter.new(
  project: 'GOOGLE_CLOUD_PROJECT_ID',
  location: 'GOOGLE_CLOUD_LOCATION_ID',
  prefix: 'optional-app-prefix',
  worker_url: 'https://example-worker-host.com' # DO NOT INCLUDE PATH HERE
)
```

> **NOTE:** If you specify a prefix, your queue name will have that prefix
> added to it. Using the example above, if a job has the queue `default`, it
> will send the job to the queue `optional-app-prefix-default`. If the prefix
> is left nil (the default behavior), then it will look for a queue named
> `default`.

Mount the Rack app in your routes (this is where incoming tasks will be POSTed
to be run):

```ruby
mount TaskBot::Rack, at: '/perform'
```

Enqueue jobs as normal.

## Production Details

Perhaps the most sensible way to run this is to have two Cloud Run services:

1. Web servers (perhaps called `example-web`)
2. Workers (perhaps called `example-worker`)

Both of these will start up Rails, but in this setup you won't have to worry
about scaling behaving properly and your worker requests holding up web
requests, etc. You also have the option of only mounting the `TaskBot::Rack`
app when run as a worker, by mounting it as follows:

```ruby
mount TaskBot::Rack, at: '/perform' if ENV['RAILS_WORKER'].present?
```

TODO: I still have to work out an authorization mechanism to only allow Google
Cloud Tasks at the `/perform` endpoint.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then,
run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/mylanconnolly/task_bot. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to adhere
to the [code of conduct](https://github.com/mylanconnolly/task_bot/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the TaskBot project's codebases, issue trackers, chat
rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/[USERNAME]/task_bot/blob/master/CODE_OF_CONDUCT.md).
