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

        if options[:license_file_path]
          file "/usr/lib/prince/license/license.dat",
            :ensure => :present,
            :source => options[:license_file_path],
            :require => package("prince")
        end

      if options[:license_file_path]
        file "/usr/local/lib/prince/license/license.dat",
          :ensure => :present,
          :source => options[:license_file_path],
          :require => exec("install prince")
      end
    end
  end
end
