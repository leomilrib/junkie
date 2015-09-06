workers Integer(ENV['WEB_CONCURRENCY'] || 5)
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

Rack::Timeout.timeout = 45

preload_app!

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
