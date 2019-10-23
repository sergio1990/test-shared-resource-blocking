# Test Shared Resource Blocking

The repository contains two Sinatra applications:

- `deadlocked_app`
- `pooled_app`

The routes of both of them are identical from the functional perspective, but
the first application uses the shared Redis connection between Puma threads. On
the other hand, the second application leverages the `connection_pool` library
to avoid deadlock.

## How to make a test?

The desired application could be run using the following command:

```
$ APP=<app_name> bundle exec puma -C puma.rb
```

For instance:

```
$ APP=deadlocked_app bundle exec puma -C puma.rb
```

After that just use the browser to make the requests to the running web
application. Use the root path to check that the application is running.

### Running `deadlocked_app`

1. Query the `/create-deadlock` endpoint
2. Using other tab query the `/check-deadlock` endpoint. You should get the following console output
```
2019-10-22 22:36:27 - Timeout::Error - execution expired:
        /Users/sergio/.asdf/installs/ruby/2.4.4/lib/ruby/2.4.0/monitor.rb:187:in `lock'
        /Users/sergio/.asdf/installs/ruby/2.4.4/lib/ruby/2.4.0/monitor.rb:187:in `mon_enter'
        /Users/sergio/.asdf/installs/ruby/2.4.4/lib/ruby/2.4.0/monitor.rb:212:in `mon_synchronize'
        /Users/sergio/.asdf/installs/ruby/2.4.4/lib/ruby/gems/2.4.0/gems/redis-4.1.3/lib/redis.rb:52:in `synchronize'
        /Users/sergio/.asdf/installs/ruby/2.4.4/lib/ruby/gems/2.4.0/gems/redis-4.1.3/lib/redis.rb:152:in `ping'
```

### Running `pooled_app`

1. Query the `/create-deadlock` endpoint
2. Using other tab query the `/check-deadlock` endpoint. In this case, you don't get the timeout error and the status of the response is `200 OK`.
```
$ APP=pooled_app bundle exec puma -C puma.rb                                                                                                                                                                                 ~/Work/N-iX/Locomote/misc/test-deadlock
[87954] Puma starting in cluster mode...
[87954] * Version 4.2.1 (ruby 2.4.4-p296), codename: Distant Airhorns
[87954] * Min threads: 5, max threads: 5
[87954] * Environment: development
[87954] * Process workers: 1
[87954] * Phased restart available
[87954] * Listening on tcp://0.0.0.0:3000
[87954] Use Ctrl-C to stop
[87954] - Worker 0 (pid: 88021) booted, phase: 0
127.0.0.1 - - [22/Oct/2019:22:43:09 +0300] "GET / HTTP/1.1" 200 28 0.0039
127.0.0.1 - - [22/Oct/2019:22:43:11 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.0013
127.0.0.1 - - [22/Oct/2019:22:43:17 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.4116
127.0.0.1 - - [22/Oct/2019:22:43:18 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.4108
127.0.0.1 - - [22/Oct/2019:22:43:26 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.3063
127.0.0.1 - - [22/Oct/2019:22:43:29 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.1015
127.0.0.1 - - [22/Oct/2019:22:43:40 +0300] "GET /create-deadlock HTTP/1.1" 200 36 24.9987
127.0.0.1 - - [22/Oct/2019:23:25:57 +0300] "GET / HTTP/1.1" 200 28 0.0004
127.0.0.1 - - [22/Oct/2019:23:26:02 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.0013
127.0.0.1 - - [22/Oct/2019:23:26:07 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.4055
127.0.0.1 - - [22/Oct/2019:23:26:07 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.1052
127.0.0.1 - - [22/Oct/2019:23:26:07 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.4850
127.0.0.1 - - [22/Oct/2019:23:26:07 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.3069
127.0.0.1 - - [22/Oct/2019:23:26:07 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.3084
127.0.0.1 - - [22/Oct/2019:23:26:10 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.2021
127.0.0.1 - - [22/Oct/2019:23:26:11 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.1019
127.0.0.1 - - [22/Oct/2019:23:26:11 +0300] "GET /check-deadlock HTTP/1.1" 200 35 0.2269
```

_INFO:_ yes, the call `ConnectionPool.wrap` isn't very performant due to it
uses the dynamic dispatch technic (`method_missing`), but it was a demonstration
that changing only one of the code helps to make the code more thread-safe
without the need to change the rest of the functionality.
