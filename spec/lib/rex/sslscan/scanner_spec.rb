# -*- coding:binary -*-
require 'rex/sslscan/scanner'
require 'rex/thread_factory'
require 'rex/text'
require 'rex/compat'

RSpec.describe Rex::SSLScan::Scanner do

  subject{Rex::SSLScan::Scanner.new("google.com", 443)}

  it { should respond_to :host }
  it { should respond_to :port }
  it { should respond_to :timeout }
  it { should respond_to :valid? }

  context "when validating the scanner config" do
    it "should return true when given a valid config" do
      expect(subject.valid?).to eq true
    end

    it "should return false if given an invalid host" do
      subject.host = nil
      expect(subject.valid?).to eq false
    end

    it "should return false if given an invalid port" do
      subject.port = nil
      expect(subject.valid?).to eq false
    end

    it "should return false if given an invalid timeout" do
      subject.timeout = nil
      expect(subject.valid?).to eq false
    end
  end

  context "when testing a single cipher" do
    context "an exception should be raised if" do
      it "has an invalid scanner configuration" do
        subject.host =nil
        expect{ subject.test_cipher(:SSLv2, "AES128-SHA")}.to raise_error
      end

      it "is given an invalid SSL version" do
        expect{ subject.test_cipher(:SSLv5, "AES128-SHA")}.to raise_error
      end

      it "is given an invalid cipher" do
        expect{ subject.test_cipher(:SSLv2, "FOO128-SHA")}.to raise_error
      end

      it "is given an invalid cipher for the SSL Version" do
        expect{ subject.test_cipher(:SSLv3, 'DES-CBC3-MD5')}.to raise_error
      end
    end

    context ":rejected should be returned if" do
      it "scans a server that doesn't support the supplied SSL version" do
        expect(subject.test_cipher(:SSLv3, "DES-CBC-SHA")).to eq :rejected
      end

      it "scans a server that doesn't support the cipher" do
        expect(subject.test_cipher(:SSLv3, "DHE-DSS-AES256-SHA")).to eq :rejected
      end
    end

    context ":accepted should be returned if" do
      it "scans a server that accepts the given cipher" do
        expect(subject.test_cipher(:SSLv3, "AES256-SHA")).to eq :accepted
      end
    end
  end

  context "when retrieving the cert" do
    it "should return nil if it can't connect" do
      expect(subject.get_cert(:SSLv3, "DES-CBC-SHA")).to eq nil
    end

    it "should return an X509 cert if it can connect" do
      subject.get_cert(:SSLv3, "AES256-SHA").should be_a OpenSSL::X509::Certificate
    end
  end

  context "when scanning https://google.com" do
    it "should return a Result object" do
      result = subject.scan
      result.should be_a Rex::SSLScan::Result
    end

    context "if SSLv2 is not available locally" do
      before(:each) do
        subject.stub(:check_opensslv2).and_return(false)
        subject.send(:initialize, 'google.com', 443)
      end
      it "should mark SSLv2 as unsupported" do
        subject.supported_versions.should_not include :SSLv2
        expect(subject.sslv2).to eq false
      end

      it "should not test any SSLv2 ciphers" do
        res = subject.scan
        expect(res.sslv2).to eq []
      end
    end
  end

end
