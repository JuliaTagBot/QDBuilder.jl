# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "qd"
version = v"2.3.22"

# Collection of sources required to build qd
sources = [
    "http://crd.lbl.gov/~dhbailey/mpdist/qd-2.3.22.tar.gz" =>
    "268e89ac68d21bebfba279fec2b82b18686509b020cd9a1868dcaac5e46fef72",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/qd-*
./configure --prefix=$prefix --host=$target --enable-shared --disable-static
make -j${nproc}
make -j${nproc} install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms_linux = [
    Linux(:aarch64, libc=:glibc),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf),
    Linux(:i686, libc=:glibc),
    Linux(:x86_64, libc=:glibc),
    Windows(:i686),
    Windows(:x86_64),
]
platforms_osx = [
    MacOS(:x86_64),
]

os = get(ENV, "TRAVIS_OS_NAME", nothing)
if os == "linux"
    platforms = platforms_linux
elseif os == "osx"
    platforms = platforms_osx
else
    platforms = [platforms_linux; platforms_osx]
end

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libqd", :libqd)
]

# Dependencies that must be installed before this package can be built
dependencies = [
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
