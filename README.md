![SubZam](https://raw.githubusercontent.com/pgaspar/subzam/master/app/assets/images/subzam.png)
# SubZam
This is the source for the Codebits 2014 [project #517](https://codebits.eu/intra/s/project/517).

The costs of hosting a Solr server (using [websolr](http://websolr.com) for example), the size of the DB (~60Mb) and the lack of time to look for alternatives prevented us from having SubZam up and running on the web. If you can help us out with this, do get in touch!

However, we wanted you to try out SubZam, and that's the purpose of this repo. The instructions below will help you run your own copy.

## Technology

* **Ruby** 2.1
* **Ruby on Rails** 4.1
* **Apache Solr** for Full-Text Search (through [sunspot](https://github.com/sunspot/sunspot))
* **[OpenSubtitles.org](http://opensubtitles.org)** for subtitles
* Google's **Web Speech API**
* Sapo's **Ink**
* Some other gems described in the Gemfile

## Setup

Install Ruby ~> 2.0.0 (if necessary). RVM is optional, but highly recommended.

    $ rvm install ruby-2.1.0

Clone the repo:

    $ git clone https://github.com/pgaspar/subzam.git
    $ cd subzam

Install bundler (if necessary)

    $ gem install bundler

Install the gems:

    $ bundle install

### Database

We've uploaded the same dataset we used on-stage. You can use this DB as your own.

    $ mv db/development.sqlite3.backup db/development.sqlite3

### Full-Text Search engine

Now that we have a decent Database, we need to index it with Solr. Let's start by starting the Solr server:

    $ bundle exec rake sunspot:solr:run

Next, lets ask it to reindex:

    $ bundle exec rake sunspot:solr:reindex

### Running the Server

Once that's done, leave the Solr server running and start the Rails server (finally!):

    $ rails s

Go to [localhost:3000](http://localhost:3000) and start searching :smile:.

## Contributing

1. Fork it ( http://github.com/pgaspar/subzam/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
