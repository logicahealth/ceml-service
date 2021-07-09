#!/usr/bin/env ruby

require 'base64'
require 'json'

root = 'http://localhost:4567/' 

# CEM GET
puts "\n==== Retrieving list of CEM files..."
cmd = "curl -s -X GET #{root}/cem"
data = JSON.parse `#{cmd}`
puts "Found #{data.length} CEM files."

name = data[0]
puts "\n==== Retrieving #{name}..."
cmd = "curl -s -X GET #{root}/cem/#{name}"
data = JSON.parse `#{cmd}`
puts "Got #{data['name']} as follows"
puts Base64.decode64 data['content']

# DEF GET
puts "\n==== Retrieving list of DEF files..."
cmd = "curl -s -X GET #{root}/def"
data = JSON.parse `#{cmd}`
puts "Found #{data.length} def files."

name = data[0]
puts "\n==== Retrieving #{name}..."
cmd = "curl -s -X GET #{root}/def/#{name}"
data = JSON.parse `#{cmd}`
puts "Got #{data['name']} as follows"
puts Base64.decode64 data['content']

# FHIR map GET
puts "\n==== Retrieving list of FHIR maps..."
cmd = "curl -s -X GET #{root}/fhir"
data = JSON.parse `#{cmd}`
puts "Found #{data.length} map files."

name = data[0]
puts "\n==== Retrieving #{name}..."
cmd = "curl -s -X GET #{root}/fhir/#{name}"
data = JSON.parse `#{cmd}`
puts "Got #{data['name']} as follows"
puts Base64.decode64 data['content']


# Compilation

models = ['FoozleA.cem', 'FoozleB.cem']
json = []
puts "\n==== Requesting compilation of #{models.join(', ')}..."
models.each do |m|
    path = File.join('test', m)
    file = File.open(path, 'r')
    content = file.read
    file.close
    tmp = Base64.encode64(content)
    json << {name: m, content: tmp}
end
puts 'Service responded as follows...'
cmd = "curl -s -X POST -d '#{json.to_json}' #{root}"
data = JSON.parse `#{cmd}`
pp data

# Print corresponding curl commands
puts 'Your `curl` commands are:'
data['gets'].each do |g|
    puts "\tGET:\tcurl -X GET '#{g}'"
end
url = data['delete']
cmd = "curl -s -X DELETE '#{url}'"
puts "\tDELETE:\t#{cmd}"
