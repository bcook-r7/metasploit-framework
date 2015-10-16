# -*- coding:binary -*-
require 'spec_helper'

require 'msf/core'
require 'msf/core/exploit'
require 'rex/proto/http/response'
require 'msf/http/wordpress'

RSpec.describe Msf::HTTP::Wordpress::Base do
  subject do
    mod = ::Msf::Exploit.new
    mod.extend ::Msf::HTTP::Wordpress
    mod.send(:initialize)
    mod
  end

  describe '#wordpress_and_online?' do
    before :each do
      allow(subject).to receive(:send_request_cgi) do
        res = Rex::Proto::Http::Response.new
        res.code = wp_code
        res.body = wp_body
        res
      end
    end

    let(:wp_code) { 200 }

    context 'when wp-content in body' do
      let(:wp_body) { '<a href="http://domain.com/wp-content/themes/a/style.css">' }
      it { expect(subject.wordpress_and_online?).to be_kind_of Rex::Proto::Http::Response }
    end

    context 'when wlwmanifest in body' do
      let(:wp_body) { '<link rel="wlwmanifest" type="application/wlwmanifest+xml" href="https://domain.com/wp-includes/wlwmanifest.xml" />' }
      it { expect(subject.wordpress_and_online?).to be_kind_of Rex::Proto::Http::Response }
    end

    context 'when pingback in body' do
      let(:wp_body) { '<link rel="pingback" href="https://domain.com/xmlrpc.php" />' }
      it { expect(subject.wordpress_and_online?).to be_kind_of Rex::Proto::Http::Response }
    end

    context 'when status code != 200' do
      let(:wp_body) { nil }
      let(:wp_code) { 404 }
      it { expect(subject.wordpress_and_online?).to be_nil }
    end

    context 'when no match in body' do
      let(:wp_body) { 'Invalid body' }
      it { expect(subject.wordpress_and_online?).to be_nil }
    end

  end

end
