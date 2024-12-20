require "pty"

class Ueberzugpp < Formula
  desc "Drop in replacement for ueberzug written in C++"
  homepage "https://github.com/jstkdng/ueberzugpp"
  url "https://github.com/jstkdng/ueberzugpp/archive/refs/tags/v2.9.6.tar.gz"
  sha256 "29cca04404c5883510aebf02846f608cfbf5892176bf4a48099e5167d5ef9d95"
  head "https://github.com/jstkdng/ueberzugpp.git"
  license "GPL-3.0-or-later"

  depends_on "cli11" => :build
  depends_on "cmake" => :build
  depends_on "nlohmann-json" => :build
  depends_on "pkg-config" => :build
  depends_on "range-v3" => :build
  depends_on "chafa"
  depends_on "fmt"
  depends_on "libsixel"
  depends_on "openssl@3"
  depends_on "spdlog"
  depends_on "tbb"
  depends_on "vips"

  on_linux do
    depends_on "extra-cmake-modules" => :build
    depends_on "wayland-protocols" => :build
    depends_on "libxcb"
    depends_on "wayland"
    depends_on "xcb-util-image"
  end

  def install
    system "cmake", "-S", ".", "-B", "build",
                    "-DENABLE_X11=#{OS.linux?}",
                    "-DENABLE_WAYLAND=#{OS.linux?}",
                    "-DENABLE_OPENCV=OFF",
                    *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    ENV["TMPDIR"] = testpath
    __, secondary = PTY.open
    read, __ = IO.pipe
    pid = spawn("#{bin}/ueberzugpp layer -o iterm2", in: read, out: secondary)
    sleep(0.1)
    Process.kill("TERM", pid)
    read.close
    secondary.close
    sleep(1)

    assert_predicate testpath/"ueberzugpp-#{ENV["USER"]}.log", :exist?
  end
end
