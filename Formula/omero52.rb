require 'formula'

class Omero52 < Formula
  homepage 'http://www.openmicroscopy.org/site/products/omero'

  url 'http://downloads.openmicroscopy.org/omero/5.2.0-rc1/artifacts/openmicroscopy-5.2.0-rc1.zip'
  sha256 'afc11cdc38798f8754a08cd7c5f5f922daf1ffeeefe682cc2e89812f57348c54'

  option 'with-cpp', 'Build OmeroCpp libraries.'

  depends_on :python
  depends_on :fortran
  depends_on 'ccache' => :recommended
  depends_on 'pkg-config' => :build
  depends_on 'hdf5'
  depends_on 'jpeg'
  depends_on 'zeroc-ice35' => 'with-python'
  depends_on 'mplayer' => :recommended
  depends_on 'nginx' => :optional
  depends_on 'cmake' if build.with? 'cpp'

  def install
    # Create config file to specify dist.dir (see #9203)
    (Pathname.pwd/"etc/local.properties").write config_file

    ENV['SLICEPATH'] = "#{HOMEBREW_PREFIX}/share/Ice-3.5/slice"
    args = ["./build.py", "-Dice.home=#{ice_prefix}"]
    if build.with? 'cpp'
      args << 'build-all'
    else
      args << 'build-default'
    end
    system *args

    # Remove Windows files from bin directory
    rm Dir[prefix/"bin/*.bat"]

    # Rename and copy the python dependencies installation script
    mv "docs/install/python_deps.sh", "docs/install/omero_python_deps"
    bin.install "docs/install/omero_python_deps"
  end

  def config_file
    <<-EOF.undent
      dist.dir=#{prefix}
    EOF
  end

  def ice_prefix
    Formula['zeroc-ice35'].opt_prefix
  end

  def caveats;
    s = <<-EOS.undent

    For non-homebrew Python, you need to set your PYTHONPATH:
    export PYTHONPATH=#{lib}/python:$PYTHONPATH

    EOS

    python_caveats = <<-EOS.undent
    To finish the installation, execute omero_python_deps in your
    shell:
      .#{bin}/omero_python_deps

    EOS
    s += python_caveats
    return s
  end

  test do
    system "omero", "version"
  end
end
