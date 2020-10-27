# frozen_string_literal: true

require 'bundler/setup'
require 'pry'

require_relative '../lib/krouter'
require_relative './actions.rb'

template = Action::Items::Templates.new
create_template = Action::Items::CreateTemplate.new

domain = 'vk'
actions = [template, create_template]

sleep 20

Krouter::Krouter.new(domain: domain, actions: actions).call
