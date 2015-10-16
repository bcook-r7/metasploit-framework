# -*- coding:binary -*-
require 'spec_helper'

require 'rex/powershell'

RSpec.describe Rex::Powershell::PshMethods do

  describe "::download" do
    it 'should return some powershell' do
      script = Rex::Powershell::PshMethods.download('a','b')
      script.should be
      script.include?('WebClient').should be_truthy
    end
  end
  describe "::uninstall" do
    it 'should return some powershell' do
      script = Rex::Powershell::PshMethods.uninstall('a')
      script.should be
      script.include?('Win32_Product').should be_truthy
    end
  end
  describe "::secure_string" do
    it 'should return some powershell' do
      script = Rex::Powershell::PshMethods.secure_string('a')
      script.should be
      script.include?('AsPlainText').should be_truthy
    end
  end
  describe "::who_locked_file" do
    it 'should return some powershell' do
      script = Rex::Powershell::PshMethods.who_locked_file('a')
      script.should be
      script.include?('Get-Process').should be_truthy
    end
  end
  describe "::get_last_login" do
    it 'should return some powershell' do
      script = Rex::Powershell::PshMethods.get_last_login('a')
      script.should be
      script.include?('Get-QADComputer').should be_truthy
    end
  end
  describe "::proxy_aware_download_and_exec_string" do
    it 'should return some powershell' do
      url = 'http://blah'
      script = Rex::Powershell::PshMethods.proxy_aware_download_and_exec_string(url)
      script.should be
      script.include?(url).should be_truthy
      script.downcase.include?('downloadstring').should be_truthy
    end
  end
end

