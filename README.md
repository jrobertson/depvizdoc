# Introducing the depvizdoc gem


## Usage

    require 'depvizdoc'


    s = "
    ra0
      sshfs
      apache

    rse
      spspublog
      reg
      apache
      sps

    elis
      ra0

    reg
      sshfs
    "

    dvd = DepVizDoc.new(s, path: '/tmp/depgraph')
    dvd.save
    `firefox /tmp/depgraph/index.svg`

The DepVizDoc gem is designed to output an SVG document illustrating the links between dependencies as well as the relative dependencies for each item by clicking on the relevant hyperlink.

## Resources

* depvizdoc https://rubygems.org/gems/depvizdoc

depvizdoc graphviz dependencies depviz gem
