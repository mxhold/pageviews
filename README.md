# pageviews

This is a very small webapp to dynamically generate a visitor counter like this:

![simple counter with green numbers 0000123](./example.png)

## Getting started

Requires [Ruby](https://www.ruby-lang.org/).

Install the dependencies (SQLite3, ChunkyPNG, and Sinatra) with:

    bundle install

Then start the server with:

    rackup

Now you can see it in action at <http://localhost:9292/something.png>.

Change the name of the file to get a new counter.
