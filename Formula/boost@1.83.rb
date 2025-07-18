class BoostAT183 < Formula
  desc "Collection of portable C++ source libraries"
  homepage "https://www.boost.org/"
  url "https://github.com/boostorg/boost/releases/download/boost-1.83.0/boost-1.83.0.tar.xz"
  sha256 "c5a0688e1f0c05f354bbd0b32244d36085d9ffc9f932e8a18983a9908096f614"
  license "BSL-1.0"
  version "1.83.0"
  head "https://github.com/boostorg/boost.git", branch: "master"

  keg_only :versioned_formula

  bottle do
    root_url "https://ghcr.io/v2/awnion/tap"
    sha256 cellar: :any,                 arm64_sequoia:  "e6292405effb56c7e96fec292b5d7975b6189b4ef8e3bcbdd211d2e3c9006ae7"
    sha256 cellar: :any,                 arm64_sonoma:   "e9b3e62d2cb90b174a3489439c1eab0bcfa018cf8db4e141ecaf73dbcfd184c6"
    sha256 cellar: :any,                 arm64_ventura:  "f5d0cc805c2a7d07aa44d17b9827f8ca66a773368b985716df8380b32e851664"
    sha256 cellar: :any,                 arm64_monterey: "c5d17ce1381bf70013d0e9c1fdffab12de1ad81cc32b4dc66745cc0932525368"
    sha256 cellar: :any,                 sonoma:         "fd39be1abc7c473fbb387f8c34eb70202bebe774383f04aca5e720bdf847d622"
    sha256 cellar: :any,                 ventura:        "b1810730f9882bb9446b84c92b966e6e33cdd6d945d4c1ba22356b910cc55a71"
    sha256 cellar: :any,                 monterey:       "a71d415dcc55645048431c71f821bca5cd417e02e8d488c38e6ccb40991aaef5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "589c2a88532aff56e337570b55c2715726a4eda861be06282fcf43712983ab4e"
  end

  depends_on "icu4c"
  depends_on "xz"
  depends_on "zstd"

  uses_from_macos "bzip2"
  uses_from_macos "zlib"

  # fix for https://github.com/boostorg/process/issues/342
  # should eventually be in boost 1.84
  patch :DATA

  def install
    # Force boost to compile with the desired compiler
    open("user-config.jam", "a") do |file|
      if OS.mac?
        file.write "using darwin : : #{ENV.cxx} ;\n"
      else
        file.write "using gcc : : #{ENV.cxx} ;\n"
      end
    end

    # libdir should be set by --prefix but isn't
    icu4c_prefix = Formula["icu4c"].opt_prefix
    bootstrap_args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      --with-icu=#{icu4c_prefix}
    ]

    # Handle libraries that will not be built.
    without_libraries = ["python", "mpi"]

    # Boost.Log cannot be built using Apple GCC at the moment. Disabled
    # on such systems.
    without_libraries << "log" if ENV.compiler == :gcc

    bootstrap_args << "--without-libraries=#{without_libraries.join(",")}"

    # layout should be synchronized with boost-python and boost-mpi
    args = %W[
      --prefix=#{prefix}
      --libdir=#{lib}
      -d2
      -j#{ENV.make_jobs}
      --layout=tagged-1.66
      --user-config=user-config.jam
      install
      threading=multi,single
      link=shared,static
    ]

    # Boost is using "clang++ -x c" to select C compiler which breaks C++14
    # handling using ENV.cxx14. Using "cxxflags" and "linkflags" still works.
    args << "cxxflags=-std=c++14"
    args << "cxxflags=-stdlib=libc++" << "linkflags=-stdlib=libc++" if ENV.compiler == :clang

    system "./bootstrap.sh", *bootstrap_args
    system "./b2", "headers"
    system "./b2", *args
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <boost/algorithm/string.hpp>
      #include <boost/iostreams/device/array.hpp>
      #include <boost/iostreams/device/back_inserter.hpp>
      #include <boost/iostreams/filter/zstd.hpp>
      #include <boost/iostreams/filtering_stream.hpp>
      #include <boost/iostreams/stream.hpp>

      #include <string>
      #include <iostream>
      #include <vector>
      #include <assert.h>

      using namespace boost::algorithm;
      using namespace boost::iostreams;
      using namespace std;

      int main()
      {
        string str("a,b");
        vector<string> strVec;
        split(strVec, str, is_any_of(","));
        assert(strVec.size()==2);
        assert(strVec[0]=="a");
        assert(strVec[1]=="b");

        // Test boost::iostreams::zstd_compressor() linking
        std::vector<char> v;
        back_insert_device<std::vector<char>> snk{v};
        filtering_ostream os;
        os.push(zstd_compressor());
        os.push(snk);
        os << "Boost" << std::flush;
        os.pop();

        array_source src{v.data(), v.size()};
        filtering_istream is;
        is.push(zstd_decompressor());
        is.push(src);
        std::string s;
        is >> s;

        assert(s == "Boost");

        return 0;
      }
    EOS
    system ENV.cxx, "test.cpp", "-std=c++14", "-o", "test", "-L#{lib}", "-lboost_iostreams",
                    "-L#{Formula["zstd"].opt_lib}", "-lzstd"
    system "./test"
  end
end
