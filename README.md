# Alyzer

> Web interface for stats and graphs computed from a CouchDB database.

Alyzer allows you to generate graphs from CouchDB data, and display them in
a web interface.


## Screenshots

![Histogram example](http://f.cl.ly/items/1W2u470I29441O3X2w2r/Screen%20Shot%202012-09-05%20at%208.47.34%20PM.png)

![Configuration example](http://f.cl.ly/items/143z421d2e0l173Y0G07/Screen%20Shot%202012-09-05%20at%208.47.53%20PM.png)


## Installation

### Prerequisites

1. Set up a CouchDB server.
2. Make sure you have a working Ruby environment.

### Install

1. Clone the GitHub repository:

    git clone https://github.com/pelletier/alyzer.git

2. Install the required gems using bundle (install it if needed):

    bundle install

3. Make sure your CouchDB server is installed, and run the installation script:

    ruby install.rb

4. Start the application:

    foreman start -f Procfile.dev

You're ready to go. Just visit `http://localhost:8080/`.


## License

MIT (see LICENSE).
