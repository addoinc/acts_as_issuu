require 'net/http'
require 'digest/md5'

module Issuu
  class Connect

    def initialize(config)
      @config = config  
    end

    def document_upload file_params
      ext = File.extname(file_params[:file_rel_path])

      args = {
        'action' => 'issuu.document.upload', 
        'apiKey' => @config[:apiKey],
        'access' => @config[:access],
        'name' => file_params[:issuu_name],
        'title' => file_params[:issuu_title] 
      }

      params = {
        'action' => "issuu.document.upload",
        'access' => "private",
        'apiKey' => @config[:apiKey],
        'signature' => calculate_signature(args),
        'name' => file_params[:issuu_name],
        'title' => file_params[:issuu_title],
        'file' => File.open(file_params[:file_rel_path], 'r')
      }

      http = Net::HTTP.new('upload.issuu.com',80)
      request = Net::HTTP::Post.new('/1_0')
      
      request.multipart_params(params)
      http.request(request)
    end

    def document_list
      args = { 
        'action' => 'issuu.documents.list',
        'access' => 'public',
        'format' => 'xml',
        'pageSize' => '20',
        'apiKey' => @config[:apiKey],
        'responseParams' => 'name,documentId,title,origin' 
      }
      
      args["signature"] = calculate_signature(args)
      http_get('api.issuu.com','/1_0',args) 
    end
    
    def document_delete doc_name
      args = { 
        'action' => 'issuu.document.delete',
        'apiKey' => @config[:apiKey],
        'names' => doc_name 
      }

      args["signature"] = calculate_signature(args)
      
      http = Net::HTTP.new('api.issuu.com',80)
      request = Net::HTTP::Post.new('/1_0')
      request.body = args.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.reverse.join("&")
      http.request(request)
    end

    private
    
    def calculate_signature(args)
      str = @config[:secret]
      args.keys.sort.each{|key| str << key+args[key]}
      Digest::MD5.hexdigest(str)
    end

    def http_get(domain,path,params)
      param_str = params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.reverse.join("&") unless params.nil?
      if param_str
        Net::HTTP.get(domain, "#{path}?#{param_str}")
      else 
        Net::HTTP.get(domain, path)
      end
    end
  end
end
