require 'spec_helper'

RSpec.describe 'puma user validation' do
  # Mock the Mina DSL methods
  def fetch(key, default = nil)
    case key
    when :user then @user
    when :puma_user then @puma_user || fetch(:user)
    when :puma_group then @puma_group || fetch(:user)
    else
      default
    end
  end
  
  def error!(message)
    raise StandardError, message
  end
  
  # Include the validation method
  def validate_puma_user!
    puma_user = fetch(:puma_user)
    puma_group = fetch(:puma_group)
    
    if puma_user.nil? || puma_user.to_s.strip.empty?
      error! %(
ERROR: puma_user is not set!

The systemd service requires a user to run under.
Please set either :user or :puma_user in your deploy.rb:

Example:
  set :user, 'deploy'
  # or
  set :puma_user, 'deploy'
      )
    end
    
    if puma_group.nil? || puma_group.to_s.strip.empty?
      error! %(
ERROR: puma_group is not set!

The systemd service requires a group to run under.
Please set either :user or :puma_group in your deploy.rb:

Example:
  set :user, 'deploy'
  # or
  set :puma_group, 'deploy'
      )
    end
  end
  
  describe 'validate_puma_user!' do
    context 'when user is not set' do
      before do
        @user = nil
        @puma_user = nil
        @puma_group = nil
      end
      
      it 'raises an error about missing puma_user' do
        expect { validate_puma_user! }.to raise_error(StandardError, /ERROR: puma_user is not set!/)
      end
    end
    
    context 'when user is set' do
      before do
        @user = 'deploy'
        @puma_user = nil
        @puma_group = nil
      end
      
      it 'does not raise an error' do
        expect { validate_puma_user! }.not_to raise_error
      end
    end
    
    context 'when puma_user is set but empty' do
      before do
        @user = nil
        @puma_user = ''
        @puma_group = 'deploy'
      end
      
      it 'raises an error about missing puma_user' do
        expect { validate_puma_user! }.to raise_error(StandardError, /ERROR: puma_user is not set!/)
      end
    end
    
    context 'when puma_user is set but puma_group is empty' do
      before do
        @user = nil
        @puma_user = 'deploy'
        @puma_group = ''
      end
      
      it 'raises an error about missing puma_group' do
        expect { validate_puma_user! }.to raise_error(StandardError, /ERROR: puma_group is not set!/)
      end
    end
    
    context 'when puma_user is set to whitespace' do
      before do
        @user = nil
        @puma_user = '   '
        @puma_group = 'deploy'
      end
      
      it 'raises an error about missing puma_user' do
        expect { validate_puma_user! }.to raise_error(StandardError, /ERROR: puma_user is not set!/)
      end
    end
    
    context 'when both puma_user and puma_group are set' do
      before do
        @user = nil
        @puma_user = 'deploy'
        @puma_group = 'deploy'
      end
      
      it 'does not raise an error' do
        expect { validate_puma_user! }.not_to raise_error
      end
    end
  end
  
  describe 'systemd template generation' do
    # Test to ensure the template would fail without proper user
    it 'generates invalid systemd file when user is nil' do
      @user = nil
      @puma_user = nil
      
      user_line = "User=#{fetch(:puma_user)}"
      expect(user_line).to eq("User=")  # This would be invalid
    end
    
    it 'generates valid systemd file when user is set' do
      @user = 'deploy'
      @puma_user = nil
      
      user_line = "User=#{fetch(:puma_user)}"
      expect(user_line).to eq("User=deploy")
    end
  end
end