require 'docopt'
require 'rest-client'

doc = <<DOCOPT
PuppetDB CLI.

Usage:
  #{__FILE__} (import|export) <archive> [--url=<server_url>]
  #{__FILE__} -h | --help
  #{__FILE__} --version

Options:
  -h --help           Show this screen.
  --version           Show version.
  --url=<server_url>  URL for contacting PuppetDB [default: http://127.0.0.1:8080].

DOCOPT

begin
  opts = Docopt::docopt(doc, {:version => "0.1.0"})
  url = opts["--url"]
  archive = File.expand_path(opts["<archive>"])
  case
  when opts["export"]
    response = RestClient::Request.execute(:method => :get,
                                           :url => "#{url}/pdb/admin/v1/archive",
                                           :raw_response => true){|response, request, result| IO.copy_stream(response.file, archive)}
  when opts["import"]
    RestClient.post "#{url}/pdb/admin/v1/archive", :myfile => File.new(archive, 'rb')
  end
rescue Docopt::Exit => e
  puts e.message
end
