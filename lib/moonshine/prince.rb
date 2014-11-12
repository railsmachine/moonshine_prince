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
      version = options[:version].to_s || '9.0' 
      if ubuntu_lucid?
        os_version='10.04'
      elsif ubuntu_precise?
        os_version='12.04'
      elsif ubuntu_trusty?
        os_version='14.04'
      end

      package "wget",
        :ensure => :installed

      package_name = "prince_#{version}-5_ubuntu#{os_version}_amd64.deb"

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

      else # install prince from source
        if version.match(/8.1/)
          version = '8.1'
          revision = '5'
          full_version = "#{version}r#{revision}"
        elsif version.match(/9.0/)
          # download url format: http://www.princexml.com/download/prince-6.0r8-linux.tar.gz
          version = '9.0'
          revision = '5'
          full_version = "#{version}r#{revision}"
        end

        %w(fontconfig fontconfig-config).each do |p|
          package p,
            :ensure => :installed
        end

        exec "install prince",
          :command => [
            "wget http://www.princexml.com/download/prince-#{full_version}-linux.tar.gz --output-document prince-#{full_version}-linux.tar.gz",
            "tar -xzf prince-#{full_version}-linux.tar.gz",
            "cd prince-#{full_version}-linux",
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
