# Stackato Worker

This is a dummy worker process I'm trying to get working on [Stackato](http://www.activestate.com/stackato).

On [Heroku](http://www.heroku.com/) I would just add a `Procfile` containing:

	worker: ruby worker.rb

Working with a local **Stackato Micro Cloud v2.05** and the **Stackato Client v1.4**, below is what I got so far.

Connect to local Stackato instance:

	$ stackato target api.stackato.local
	Successfully targeted to [https://api.stackato.local]
		
	$ stackato login me@example.com --passwd mypass
	Attempting login to [https://api.stackato.local]
	Successfully logged into [https://api.stackato.local]
	Reset current group: OK
	
Test that the worker works (no pun intended) locally:

	$ ruby worker.rb
	Working.. 1
	Working.. 2
	Working.. 3

`Ctrl+C` to exit process.

Try pushing to Stackato:

	$ stackato push -n
	Pushing application 'stackato-worker'...
	Application Url: stackato-worker.stackato.local
	Framework:       standalone
	Runtime:         <framework-specific default>
	Creating Application [stackato-worker]: OK
	Uploading Application [stackato-worker]:
	  Checking for bad links:  OK
	  Copying to temp space:  OK
	  Checking for available resources:  OK
	  Packing application: OK
	  Uploading (1K):  OK
	Push Status: OK
	Staging Application [stackato-worker]: OK
	Starting Application [stackato-worker]: ..........................
	Error: Application [stackato-worker] failed to start, logs information below.

(There is no log information.)

The contents of my `stackato.yml` file:

	name: stackato-worker

	framework:
	  type: standalone
	
	processes:
	  web: ruby worker.rb
	
	ignores: [".git"]

I couldn't find any walkthrough in the [Stackato Documentation](http://docs.stackato.com) to help me out.

The forum post I opened on the Stackato Community website is: [http://support.activestate.com/node/8843](http://support.activestate.com/node/8843).

Any help is appreaciated! :)

\- Nicolas