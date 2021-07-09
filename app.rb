require 'sinatra'
require 'sinatra/reloader' if development?

require 'securerandom' # UUIDs
require 'fileutils'
require 'base64'

class CEMLService < Sinatra::Base

    configure do
        enable :threaded
    end

    configure :development do
      register Sinatra::Reloader
      require 'byebug'
    end
  
    TEMPLATE_CEM = File.join('./', 'cem')
    TEMPLATE_DEF = File.join('./', 'def')
    TEMPLATE_FHIR = File.join('./', 'fhir')

    # TODO Allow configuration via environment variable.
    OUTPUT_ROOT =  File.join('/tmp', 'ceml-service')
    
    before do
        content_type :json
    end
    
    def get_listing(path)
        files = Dir.children(path).sort
        puts "Returning #{files.length} names"
        files.to_json
    end
    
    def get_file(path, name)
        resp = {}
        begin
            path  = File.join(path, name)
            file = File.open(path, 'r')
            content = file.read
            resp = {name: name, content: Base64.encode64(content)}
        rescue => exception
            status 404
        end
        resp.to_json
    end
    
    get '/cem' do
        get_listing(TEMPLATE_CEM)
    end
    
    get '/def' do
        get_listing(TEMPLATE_DEF)
    end
    
    get '/fhir' do
        get_listing(TEMPLATE_FHIR)
    end
    
    get '/cem/:name' do |name|
        get_file(TEMPLATE_CEM, name)
    end
    
    get '/def/:name' do |name|
        get_file(TEMPLATE_DEF, name)
    end
    
    get '/fhir/:name' do |name|
        get_file(TEMPLATE_FHIR, name)
    end
    
    get '/' do
        {message: 'Post to the root URL to compile.', uuid: SecureRandom.uuid}.to_json
    end
    
    post '/' do
        json = {}
        begin
            json = JSON.parse request.body.read
        rescue => e
            halt 406, {message: "Body must be valid JSON."}.to_json
        end
        u = SecureRandom.uuid
        puts 'Creating processing space with template content...'
        d_name = File.join(OUTPUT_ROOT, u)
        FileUtils.mkdir_p d_name
        dest_src = File.join(d_name, 'src')
        # dest_cem =    File.join(d_name, 'cem')
        # dest_def = File.join(d_name, 'def')
        # dest_fhir = File.join(d_name, 'fhir')
        dest_out = File.join(d_name, 'out')
        Dir.mkdir dest_src
        Dir.mkdir dest_out
        # FileUtils.copy_entry(TEMPLATE_CEM, dest_cem)
        # FileUtils.copy_entry(TEMPLATE_DEF, dest_def)
        # FileUtils.copy_entry(TEMPLATE_FHIR, dest_fhir)
    
        puts 'Checking for submitted models...'
        
        inputs  = []
        json.each_with_index do |n, i|
            name = n['name']
            content = n['content']
            inputs.push name
            f_dest = File.join(dest_src, name)
            puts "Writing \##{i} content to #{f_dest}"
            File.open(f_dest, 'w') do |f|
                f.puts Base64.decode64(content)
            end
        end
    
        puts 'Running compiler...'
        msg = ''
        p = IO.popen(['java', '-jar', 'ceml-3.0.4-jar-with-dependencies.jar', '-d', TEMPLATE_DEF, '-i', dest_src, '-p', TEMPLATE_CEM, '-f', TEMPLATE_FHIR, '-dest', 'fsh', '-o', dest_out, *inputs, err: [:child, :out]], 'r') do |java_io|
            msg = java_io.read
            msg_name = File.join(d_name, 'message')
            # byebug
            puts msg
            File.open(msg_name, 'w') do |f|
                f.puts(msg)# until java_io.eof?
            end
            puts "Wrote to #{msg_name}"
        end

        gets = inputs.map {|i| "#{request.url}/#{u}/#{i.gsub(/.cem$/, '.fsh')}" }
        {uuid: u, gets: gets, delete: "#{request.url}/#{u}", message: msg}.to_json
    end
    
    get '/:uuid/:file' do |uuid, file|
        puts 'Getting result for #{uuid}'
        content = ''
        res = {uuid: uuid, file: file}
        begin
            path = File.join(OUTPUT_ROOT, uuid, 'out', file)
            f = File.open(path, 'r')
            content = f.read
            f.close
            res['content'] = Base64.encode64(content)
            # attachment
            # content_type :binary
            # msg                
        rescue => exception
            status 404
            puts "File at #{path} not found"
        end
        res.to_json
    end
    
    delete '/:uuid' do |uuid|
        d = File.join(OUTPUT_ROOT, uuid)
        puts "Deleting #{d}"
        FileUtils.remove_dir d, true
        {message: 'deleted'}.to_json
    end

    post '/reset' do
        puts "Delete everything in #{OUTPUT_ROOT}"
        msg = {}
        begin
            FileUtils.remove_dir OUTPUT_ROOT
            msg['message'] = "Service has been fully reset"
        rescue => Errno::ENOENT
            puts "#{OUTPUT_ROOT} does not exist"
            msg['message'] = "Output directory did not exist, so nothing has been done. Service may have already been reset."
        end
        msg.to_json
    end

end
