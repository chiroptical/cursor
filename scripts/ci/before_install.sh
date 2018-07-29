set -ex

case $BUILD_KIND in
  stack)
    mkdir -p ~/.local/bin
    export PATH=$HOME/.local/bin:$PATH
    travis_retry curl -L https://www.stackage.org/stack/linux-x86_64 | tar xz --wildcards --strip-components=1 -C ~/.local/bin '*/stack'
    chmod a+x ~/.local/bin/stack
  nix)
    echo "Nothing to do before install"
  *)
    echo "Unknown build kind"
esac