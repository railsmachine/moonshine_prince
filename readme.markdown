# Moonshine::Prince

## Introduction

Welcome to Moonshine::Prince, a [Moonshine](http://github.com/railsmachine/moonshine) plugin for installing and managing [Prince XML](http://www.princexml.com/).

Here's some quick links:

 * [Homepage](http://github.com/railsmachine/moonshine_prince)
 * [Issues](http://github.com/railsmachine/moonshine_prince/issues) 
 * [Wiki](http://github.com/railsmachine/moonshine_prince/wiki) 
 * Resources for using Prince:
   * [Prince Homepage](https://github.com/railsmachine/moonshine_prince)

## Quick Start

Moonshine::Prince is installed as a Rails plugin:

    # Rails 2.x.x
    script/plugin install git://github.com/railsmachine/moonshine_prince.git
    # Rails 3.x.x
    script/rails plugin install git://github.com/railsmachine/moonshine_prince.git

Once it's installed, you can include it in your manifest:

    # app/manifests/application_manifest.rb
    class ApplicationManifest < Moonshine::Manifest:Rails

       # other recipes and configuration omitted

       # tell ApplicationManifest to use the prince recipe
       recipe :prince
    end

## Configuration Options

Configure the version in your moonshine.yml:

    :prince:
      :version: 7.1

or in your manifest;

    configure(:prince => {:version => '6.0'})

## Dependencies

* [moonshine_msttcorefonts](https://github.com/railsmachine/moonshine_msttcorefonts)