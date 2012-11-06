# Stackato Worker

## Update 2012-11-05

This has been tested on **Stackato Micro Cloud v2.4.3** and the **Stackato Client v1.5**.

- **Issue 1 (resolved)**: Standalone process launches, but Stackato says the app "failed to start"
- **Issue 2 (resolved)**: Standalone framework does not work for Ruby 1.9
- **Issue 3**: Using a Heroku buildpack does not allow for `worker` process in `Procfile`

Thanks a lot to the Stackato team for working to enable the `standalone` framework.

To this day, only **Issue 3** remains unresolved (see the bottom of this document for details), which means this example app can't be used with JRuby for instance. Hopefully one day this will be fixed?
    
    Staging Application [stackato-worker]: Failed to stage application:
     staging plugin exited with non-zero exit code.

    $ stackato logs
    2012-11-05T13:25:32-0500 staging
    2012-11-05T13:25:32-0500 staging -----> Stackato receiving staging request
    2012-11-05T13:25:33-0500 staging -----> JRuby app detected
    2012-11-05T13:25:33-0500 staging -----> Downloading and unpacking JRuby
    2012-11-05T13:25:38-0500 staging -----> Installing JRuby-OpenSSL, Bundler and Rake
    2012-11-05T13:26:05-0500 staging        Successfully installed bouncy-castle-java-1.5.0146.1
    2012-11-05T13:26:05-0500 staging        Successfully installed jruby-openssl-0.7.7
    2012-11-05T13:26:08-0500 staging        Successfully installed bundler-1.2.1
    2012-11-05T13:26:09-0500 staging        Successfully installed rake-0.9.2.2
    2012-11-05T13:26:09-0500 staging        4 gems installed
    2012-11-05T13:26:09-0500 staging -----> Vendoring JRuby into slug
    2012-11-05T13:26:10-0500 staging -----> Installing dependencies with Bundler
    2012-11-05T13:26:29-0500 staging        The Gemfile specifies no dependencies
    2012-11-05T13:26:29-0500 staging        Your bundle is complete! It was installed into ./vendor/bundle
    2012-11-05T13:26:29-0500 staging        Dependencies installed
    2012-11-05T13:26:29-0500 staging -----> Writing config/database.yml to read from DATABASE_URL
    2012-11-05T13:26:34-0500 staging jruby: No such file or directory -- bin (LoadError)
    2012-11-05T13:26:35-0500 staging  !      Procfile must contain a 'web' entry

In the meantime, I've found a workaround described by this example app:

[https://github.com/nicolahery/warbly](https://github.com/nicolahery/warbly)

## Description of original problem

This is a dummy worker process I'm trying to get working on [Stackato](http://www.activestate.com/stackato).

Worker processes on  [Heroku](http://www.heroku.com/) are easy, just add a `Procfile` containing:

	worker: ruby worker.rb

I wish they worked fine on Stackato. I like Stackato's approach of targeting enterprise private PaaS, and I believe many businesses have apps that are not web apps, just long-running processes.

Everything here was tested with a local **Stackato Micro Cloud v2.2.1** and the **Stackato Client v1.4.4**.

I will also add that standalone apps (what Heroku calls "worker") are supported in Cloud Foundry since June 2012, see this blog post: [http://blog.cloudfoundry.com/2012/05/01/cloud-foundry-improves-support-for-background-processing/](http://blog.cloudfoundry.com/2012/05/01/cloud-foundry-improves-support-for-background-processing/)

In Stackato 2.2.1, they are still not fully supported, although the `standalone` framework exists. I will detail below the issues I found:

- **Issue 1**: Standalone process launches, but Stackato says the app "failed to start"
- **Issue 2**: Standalone framework does not work for Ruby 1.9
- **Issue 3**: Using a Heroku buildpack does not allow for `worker` process in `Procfile`

The forum post I opened on the Stackato Community website for this is: [http://support.activestate.com/node/8843](http://support.activestate.com/node/8843).

You can check that the worker works (no pun intended) fine locally:

	$ ruby worker.rb
	Working.. 1
	Working.. 2
	Working.. 3

`Ctrl+C` to exit process.

## Issue 1: Standalone process launches, but Stackato says the app "failed to start"

When I deploy the worker as a `standalone` app I get:

    $ stackato push stackato-worker
    Would you like to deploy from the current directory ?  [Yn]:
    Detected a Standalone application, is this correct ?  [Yn]:
    Framework:       standalone
    Select Runtime:  (erlangR14B02, java, node, perl514, php, python27, python32, ruby18, or ruby19): ruby18
    Runtime:         Ruby 1.8.7
    Start command: ruby worker.rb
    Command:         ruby worker.rb
    Enter Memory Reservation [128M]:
    Creating Application [stackato-worker]: OK
    Create services to bind to 'stackato-worker' ?  [yN]:
    Would you like to save this configuration? [yN]: y
    Uploading Application [stackato-worker]:
      Checking for bad links:  OK
      Copying to temp space:  OK
      Checking for available resources:  OK
      Packing application: OK
      Uploading (2K):  OK
    Push Status: OK
    Staging Application [stackato-worker]: OK
    Starting Application [stackato-worker]: ..........................
    Error: Application [stackato-worker] failed to start, logs information below.
    
    ====> /logs/stdout.log <====
    No Redis service bound to app.  Skipping auto-reconfiguration.
    No Mongo service bound to app.  Skipping auto-reconfiguration.
    No MySQL service bound to app.  Skipping auto-reconfiguration.
    No PostgreSQL service bound to app.  Skipping auto-reconfiguration.
    No RabbitMQ service bound to app.  Skipping auto-reconfiguration.
    Working.. 1
    Working.. 2
    Working.. 3
    Working.. 4
    Working.. 5
    Working.. 6
    Working.. 7
    Working.. 8
    
    
    Should I delete the application ?  [Yn]: n

I can check that the process is still running with `stackato logs`, but Stackato thinks the app is dead. This is fairly inconvenient, because Stackato has a nice app monitoring dashboard, and it will always show this app as dead. When it *does* actually crash, we wouldn't be able to tell the difference.

    $ stackato logs stackato-worker
    ====> /logs/staging.log <====
    
    Need to fetch bundler-1.0.10.gem from RubyGems
    Fetching missing gems from RubyGems
    Adding bundler-1.0.10.gem to app...
    Adding cf-autoconfig-0.0.3.gem to app...
    Need to fetch cf-runtime-0.0.1.gem from RubyGems
    Need to fetch crack-0.3.1.gem from RubyGems
    Fetching missing gems from RubyGems
    Adding cf-runtime-0.0.1.gem to app...
    Adding crack-0.3.1.gem to app...
    @2012-09-13 12:57:14 -- end of staging
    
    ====> /logs/stdout.log <====
    No Redis service bound to app.  Skipping auto-reconfiguration.
    No Mongo service bound to app.  Skipping auto-reconfiguration.
    No MySQL service bound to app.  Skipping auto-reconfiguration.
    No PostgreSQL service bound to app.  Skipping auto-reconfiguration.
    No RabbitMQ service bound to app.  Skipping auto-reconfiguration.
    Working.. 1
    Working.. 2
    Working.. 3
    Working.. 4
    Working.. 5
    Working.. 6
    Working.. 7
    Working.. 8
    Working.. 9
    Working.. 10
    Working.. 11
    Working.. 12
    Working.. 13
    Working.. 14
    Working.. 15
    Working.. 16
    Working.. 17
    Working.. 18

## Issue 2: Standalone framework does not work for Ruby 1.9

This is more of a bug. The example above is using Ruby 1.8, because when I tried Ruby 1.9 I got:

    $ stackato push stackato-worker
    Would you like to deploy from the current directory ?  [Yn]:
    Detected a Standalone application, is this correct ?  [Yn]:
    Framework:       standalone
    Select Runtime:  (erlangR14B02, java, node, perl514, php, python27, python32, ruby18, or ruby19): ruby19
    Runtime:         Ruby 1.9.3
    Start command: ruby worker.rb
    Command:         ruby worker.rb
    Enter Memory Reservation [128M]:
    Creating Application [stackato-worker]: OK
    Create services to bind to 'stackato-worker' ?  [yN]:
    Would you like to save this configuration? [yN]: y
    Uploading Application [stackato-worker]:
      Checking for bad links:  OK
      Copying to temp space:  OK
      Checking for available resources:  OK
      Packing application: OK
      Uploading (2K):  OK
    Push Status: OK
    Staging Application [stackato-worker]: Failed to stage application:
     /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/common.rb:751:in `current_ruby': uninitialized constant
    StagingPlugin::Config::CONFIG (NameError)
    
            from /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/common.rb:789:in `ruby'
    
            from /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/gemfile_support.rb:24:in `compile_gems'
    
            from /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/standalone/plugin.rb:24:in `runtime_specific_staging'
    
            from /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/standalone/plugin.rb:15:in `block in stage_application'
    
            from /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/standalone/plugin.rb:10:in `chdir'
    
            from /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/standalone/plugin.rb:10:in `stage_application'
    
            from /home/stackato/stackato/vcap/stager/bin/run_plugin:19:in `<main>'

I don't know about Stackato's internals to say why is this happening when it works fine for Ruby 1.8, but the error above should help.

## Issue 3: Using a Heroku buildpack does not allow for worker process in Procfile

Ultimately, the worker I want to deploy is actually in **JRuby**. However, it seems that the buildpack framework does not allow `worker` processes to be defined in the `Procfile`.

I use the following `stackato.yml` config file:

```yaml
name: stackato-worker
instances: 1
framework:
    type: buildpack
env:
    BUILDPACK_URL: git://github.com/jruby/heroku-buildpack-jruby
mem: 128
```

I deploy the app, and it fails with not errors printed:

    $ stackato push -n
    Pushing application 'stackato-worker'...
    Framework:       buildpack
    Runtime:         <framework-specific default>
    Application Url: stackato-worker.stackato.local
    Creating Application [stackato-worker]: OK
      Adding Environment Variable [BUILDPACK_URL=git://github.com/jruby/heroku-buildpack-jruby]
    Updating environment: OK
    Uploading Application [stackato-worker]:
      Checking for bad links:  OK
      Copying to temp space:  OK
      Checking for available resources:  OK
      Packing application: OK
      Uploading (2K):  OK
    Push Status: OK
    Staging Application [stackato-worker]: Failed to stage application:

I went on the Stackato server to dig in the logs and found:

    $ tail /home/stackato/stackato/logs/stager.log
    [2012-09-13 13:20:15] vcap.stager.task - 2253 7c4d 913a   INFO -- Staging application
    [2012-09-13 13:20:15] vcap.stager.task - 2253 7c4d 913a  DEBUG -- Running staging command: 'env APP_NAME=stackato-worker /opt/rubies/current/bin/ruby /home/stackato/stackato/vcap/stager/bin/run_plugin buildpack /staging/plugin_config.yaml'
    [2012-09-13 13:20:58] vcap.stager.task - 2253 7c4d 913a  DEBUG -- Command 'env APP_NAME=stackato-worker /opt/rubies/current/bin/ruby /home/stackato/stackato/vcap/stager/bin/run_plugin buildpack /staging/plugin_config.yaml' exited with status='pid 7690 exit 1', timed_out=false
    [2012-09-13 13:20:58] vcap.stager.task - 2253 7c4d 913a   INFO -- Staging output:\n\n-----> Stackato receiving staging request\n@2012-09-13 13:20:18\n-----> JRuby app detected\n@2012-09-13 13:20:18\n-----> Downloading and unpacking JRuby\n-----> Installing JRuby-OpenSSL, Bundler and Rake\n       Successfully installed bouncy-castle-java-1.5.0146.1\n       Successfully installed jruby-openssl-0.7.7\n       Successfully installed bundler-1.2.0\n       Successfully installed rake-0.9.2.2\n       4 gems installed\n-----> Vendoring JRuby into slug\n-----> Installing dependencies with Bundler\n       The Gemfile specifies no dependencies\n       Your bundle is complete! It was installed into ./vendor/bundle\n       Dependencies installed\n-----> Writing config/database.yml to read from DATABASE_URL\n-----> Precompiling assets\n       jruby: No such file or directory -- bin (LoadError)\n !      Procfile must contain a 'web' entry\n
    [2012-09-13 13:20:58] vcap.stager.task - 2253 7c4d 913a   INFO -- Staging plugin exited with status 'pid 7690 exit 1'
    [2012-09-13 13:20:58] vcap.stager.task - 2253 7c4d 913a  DEBUG -- Failed to stage application:\n \n
    [2012-09-13 13:20:58] vcap.stager.task_manager - 2253 7c4d 913a   INFO -- Task, id=0778142b75e9f1d6237617151edba00e completed, result='#<VCAP::Stager::TaskResult:0x00000003203f70>'
    [2012-09-13 13:20:58] vcap.stager.task - 2253 7c4d 913a   INFO -- Cleaning up container for 01541d922abd031f28b953f1f3ec3459

Which led me to this: `$ vim /home/stackato/stackato/vcap/staging/lib/vcap/staging/plugin/buildpack/plugin.rb` (line 146)

```ruby
# until we have a "foreman export cf" plugin, this should be
# sufficient. only 'web' from Procfile is used. background workers
# in Procfile is meaningless for stackato as they will scale along
# with the web processes.
def extract_procfile_web
  procfile = File.join(@app_dir, 'Procfile')
  IO.readlines(procfile).each do |line|
    if line =~ /\s*web\s*\:\s*(.+)\s*/
      return $1
    end
  end
  log_to_staging(" !      Procfile must contain a 'web' entry")
abort
end
```

I don't really understand the comment there, and why background workers are "meaningless" in Procfile, and how you would define them otherwise.
