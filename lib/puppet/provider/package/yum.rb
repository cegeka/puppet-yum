require 'puppet/util/package'
require 'fileutils'
require 'tempfile'

Puppet::Type.type(:package).provide :yum, :parent => :rpm, :source => :rpm do
  desc "Support via `yum`.

  Using this provider's `uninstallable` feature will not remove dependent packages. To
  remove dependent packages with this provider use the `purgeable` feature, but note this
  feature is destructive and should be used with the utmost care."

  has_feature :versionable

  commands :yum => "yum", :rpm => "rpm", :python => "python"

  YUMHELPER = File::join(File::dirname(__FILE__), "yumhelper.py")

  attr_accessor :latest_info

  if command('rpm')
    confine :true => begin
      rpm('--version')
      rescue Puppet::ExecutionFailure
        false
      else
        true
      end
  end

  defaultfor :operatingsystem => [:fedora, :centos, :redhat]

  def self.prefetch(packages)
    raise Puppet::Error, "The yum provider can only be used as root" if Process.euid != 0
    super
    return unless packages.detect { |name, package| package.should(:ensure) == :latest }

    # collect our 'latest' info
    updates = {}
    python(YUMHELPER).each_line do |l|
      l.chomp!
      next if l.empty?
      if l[0,4] == "_pkg"
        hash = nevra_to_hash(l[5..-1])
        [hash[:name], "#{hash[:name]}.#{hash[:arch]}"].each  do |n|
          updates[n] ||= []
          updates[n] << hash
        end
      end
    end

    # Add our 'latest' info to the providers.
    packages.each do |name, package|
      if info = updates[package[:name]]
        package.provider.latest_info = info[0]
      end
    end
  end

  def install
    should = @resource.should(:ensure)
    self.debug "Ensuring => #{should}"
    wanted = @resource[:name]
    operation = :install

    case should
    when true, false, Symbol
      # pass
      should = nil
      specificversion = false
    else
      # Add the package version
      wanted += "-#{should}"
      specificversion = true
      is = self.query
      if is && Puppet::Util::Package.versioncmp(should, is[:ensure]) < 0
        self.debug "Downgrading package #{@resource[:name]} from version #{is[:ensure]} to #{should}"
        operation = :downgrade
      end
    end
      if (File.exist?('/etc/yum/pluginconf.d/versionlock.list') == true && specificversion == true)
        self.checknames
      end
    output = yum "-d", "0", "-e", "0", "-y", operation, wanted
      if (File.exist?('/etc/yum/pluginconf.d/versionlock.list') == true && specificversion == true)
        addtolist(wanted)
      end

    is = self.query
    raise Puppet::Error, "Could not find package #{self.name}" unless is

    # FIXME: Should we raise an exception even if should == :latest
    # and yum updated us to a version other than @param_hash[:ensure] ?
    raise Puppet::Error, "Failed to update to version #{should}, got version #{is[:ensure]} instead" if should && should != is[:ensure]
  end

  # What's the latest package version available?
  def latest
    if (File.exist?('/etc/yum/pluginconf.d/versionlock.list') == true)
      self.checknames
    end
    upd = latest_info
    puts latest_info
    unless upd.nil?
      # FIXME: there could be more than one update for a package
      # because of multiarch
      return "#{upd[:epoch]}:#{upd[:version]}-#{upd[:release]}"
    else
      # Yum didn't find updates, pretend the current
      # version is the latest
      raise Puppet::DevError, "Tried to get latest on a missing package" if properties[:ensure] == :absent
      return properties[:ensure]
    end
  end

  def update
    # Install in yum can be used for update, too
    self.install
  end

  def purge
    if (File.exist?('/etc/yum/pluginconf.d/versionlock.list') == true)
      deletefromlist()
    end
    yum "-y", :erase, @resource[:name]
  end

  def deletefromlist
    release = Facter.value("operatingsystemrelease")
    case release
    when /^[5]\..$/
      full = buildstring()
      present = checklist5(full)
      if (present == true)
        #TODO delete file
        tmp = Tempfile.new("extract")
        open('/etc/yum/pluginconf.d/versionlock.list', 'r').each { |l| tmp << l unless l.chomp == full.chomp + '.*' }
        tmp.close
        FileUtils.mv(tmp.path, '/etc/yum/pluginconf.d/versionlock.list')
      end
    when /^[6]\..$/
      full = `rpm -q #{@resource[:name]} --queryformat='%{NAME}-%{VERSION}-%{RELEASE}\n'`
      fulls = buildstring().chomp + '.*'
      present = checkifisinlist6(full)
      if (present == true)
        `/usr/bin/yum versionlock delete #{fulls}`
      end
    end
  end
  def addtolist(wanted)
    release = Facter.value("operatingsystemrelease")
    case release
    when /^[5]\..$/
      present = checkifisinlist5(wanted)
      if (present == false)
        full = buildstring()
        File.open("/etc/yum/pluginconf.d/versionlock.list", 'a+') {|f| f.write(full.chomp + ".*\n") }
      end
    when /^[6]\..$/
        present = checkifisinlist6(wanted)
        if (present == false)
          output = yum  "versionlock", wanted
        end
    end
  end
  def checkifisinlist6(package)
      lineexists = false
      `/usr/bin/yum versionlock list`.each_line do |fd|

        if (fd.chomp =~ /^[0-9]+:#{package.chomp}\.\*$/)
          lineexists = true

          break
        end
      end
    return lineexists
  end
  def checklist5(package)
      present = false
        File.open("/etc/yum/pluginconf.d/versionlock.list").each_line do |line|
          if (line.chomp =~ /^#{package.chomp}\.\*$/)
            present = true
          end
        end
      return present
  end
  def checkifisinlist5(package)
      present = false
        File.open("/etc/yum/pluginconf.d/versionlock.list").each_line do |line|
          if (line.chomp =~ /^[0-9]+:#{package.chomp}\.\*$/)
            present = true
          end
        end
      return present
  end
  def buildstring
    if (`rpm -q #{@resource[:name]} --queryformat='%{EPOCH}\n'`.chomp == "(none)")
      full = `rpm -q #{@resource[:name]} --queryformat='0:%{NAME}-%{VERSION}-%{RELEASE}\n'`
    else
      full = `rpm -q #{@resource[:name]} --queryformat='%{EPOCH}:%{NAME}-%{VERSION}-%{RELEASE}\n'`
    end
    return full
  end
  def checknames
    checkpackage = system 'rpm', '-q', @resource[:name]
    if ( checkpackage == true)
      puts @resource[:name]
      self.deletefromlist
    end

  end
end
