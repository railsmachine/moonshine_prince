module Moonshine
  module Prince

    # Define options for this plugin via the <tt>configure</tt> method
    # in your application manifest:
    #
    #    configure(:prince => {:foo => true})
    #
    # Moonshine will autoload plugins, just call the recipe(s) you need in your
    # manifests:
    #
    #    recipe :prince
    def prince(options = {})
      # define the recipe
      # options specified with the configure method will be 
      # automatically available here in the options hash.
      #    options[:foo]   # => true
      version = options[:version] || 7.1
      package "wget",
        :ensure => :installed

      if version == 7.2
        package_name = 'prince_7.2-4ubuntu10.04_amd64.deb'
        # Install pre-release package for Lucid compatibility
        # http://princecss.com/bb/viewtopic.php?f=2&t=1266&start=30
        %w(libgif4).each do |p|
          package p,
            :ensure => :installed
        end
        exec "download prince",
          :creates => "/usr/local/src/#{package_name}",
          :command => "wget http://www.princexml.com/download/#{package_name}",
          :cwd => "/usr/local/src",
          :require => package("wget")

        package "prince",
          :ensure => :installed,
          :provider => :dpkg,
          :source => "/usr/local/src/#{package_name}",
          :require => [
            exec("download prince"),
            package("libgif4")
          ]

        # remove prince binary if previously installed from source
        file "/usr/local/bin/prince",
          :ensure => :absent
        
        if options[:license_file_path]
          file "/usr/lib/prince/license/license.dat",
            :ensure => :present,
            :source => options[:license_file_path],
            :require => package("prince")
        end

      else
        # install prince from source
        %w(fontconfig fontconfig-config).each do |p|
          package p,
            :ensure => :installed
        end

        exec "install prince",
          :command => [
            "wget http://www.princexml.com/download/prince-#{version}-linux.tar.gz --output-document prince-#{version}-linux.tar.gz",
            "tar -xzf prince-#{version}-linux.tar.gz",
            "cd prince-#{version}-linux",
            "sed '/^read input/ c\# read input' -i install.sh", # remove user input and accept default install path
            "/bin/bash install.sh"
          ].join(' ; '),
          :require => package("wget"),
          :cwd => "/tmp",
          :unless => "test -f /usr/local/bin/prince && /usr/local/bin/prince --version | grep #{version}"
        
        
        if options[:license_file_path]
          file "/usr/local/lib/prince/license/license.dat",
            :ensure => :present,
            :source => options[:license_file_path],
            :require => exec("install prince")
        end
      end
    end
  end
end
