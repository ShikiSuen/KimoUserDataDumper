class KimoUserDataDumper < Formula
  desc "A tool to dump user data"
  homepage "https://github.com/ShikiSuen/KimoUserDataDumper"
  url "https://github.com/ShikiSuen/KimoUserDataDumper/archive/refs/tags/1.0.0.tar.gz"
  sha256 "567e3e56505c9db3931dd0e034099c1bf59fa827176c4dd48f958d3fbb338669"  # Replace with actual SHA256 of the tar.gz

  depends_on "swift"

  def install
    cd "ForMojaveAndEarlier" do
      system "swift", "build", "-c", "release"
      bin.install "build/release/KimoUserDataDumper"
    end
  end
end
