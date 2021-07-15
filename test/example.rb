#!/usr/bin/env ruby
# curl examples of service usage

require 'base64'
require 'json'

root = 'http://localhost:4567'
# root = "https://ceml-transform-service.logicahealth.org"

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


# Supported compliation formats
puts "\n==== Retrieving list of supported compilation formats..."
cmd = "curl -s -X GET #{root}/transforms/formats"
data = JSON.parse `#{cmd}`
puts "Supported transform format targets are: #{data}"

# Compilation in different formats
formats = data # ['jsoncf', 'fsh', 'xcemcf']

models = ['FoozleA.cem', 'FoozleB.cem']
formats.each do |format|
    puts "\n==== Requesting #{format} compilation of #{models.join(', ')}..."
    json = []
    models.each do |m|
        path = File.join('test', m)
        file = File.open(path, 'r')
        content = file.read
        file.close
        tmp = Base64.encode64(content)
        json << {name: m, content: tmp}
    end
    puts 'Service responded as follows...'
    cmd = "curl -s -X POST -d '#{json.to_json}' #{root}/transforms/#{format}"
    data = JSON.parse `#{cmd}`
    pp data

    # Print corresponding curl commands
    puts 'Your next `curl` command options are:'
    data['gets'].each do |g|
        puts "\tGET:\tcurl -X GET '#{g}'"
    end
    url = data['delete']
    cmd = "curl -s -X DELETE '#{url}'"
    puts "\tDELETE (this job only):\t#{cmd}"
end

puts "\nTo reset the service:\n\tPOST (factory reset): curl -s -X POST '#{root}/reset'"
