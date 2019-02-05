require "json"
require 'open3'

require "./14-open-your-ears-and-you-will-hear-it"

Server.mount_proc '/slides.json' do |req, res|
  res.status = 200
  res['Content-Type'] = 'application/json'
  html = Dir["*.html"].map { |x| { type: "html", name: File.basename(x, ".html") } }
  ruby = Dir["*.rb"].map { |x| { type: "ruby", name: File.basename(x, ".rb") } }
  default = ARGV[0] || __FILE__

  res.body = {
    default: File.basename(default, File.extname(default)),
    slides: (html + ruby).sort_by { |x| x[:name] }
  }.to_json
end

Server.mount_proc '/execute/' do |req, res|
  cmd = File.basename(req.path)

  res.status = 200
  res['Content-Type'] = 'text/plain; charset=utf-8'

  if cmd == "13-when-im-going-im-going-for-mine.rb"
    system("ruby", cmd)
    res.body = "ruby #{cmd} (see terminal)"
  else
    stdin, stdout, _ = Open3.popen2e("ruby", cmd)
    res.body = (["ruby #{cmd}\n"] + stdout.read.lines.map { |x| "(out)#{x}" }).join("").chomp
  end
end


# Server.mount_proc '/execute/' do |req, res|
#   cmd = File.basename(req.path)
#   stdout, status = Open3.capture2e("ruby", cmd)
#   res.status = 200
#   res['Content-Type'] = 'text/plain; charset=utf-8'
#   res.body = (["ruby #{cmd} (#{status.exitstatus})\n"] + stdout.lines.map { |x| "(out)#{x}" }).join("").chomp
# end

if __FILE__ == $0
  Thread.new { Server.start }

  sleep 0.1

  config = WKWebViewConfiguration.alloc.init
  config.setUserContentController(WKUserContentController.alloc.init)

  view = WKWebView.alloc.initWithFrame(RECT, configuration: config)
  view.loadRequest(NSURLRequest.alloc.initWithURL(NSURL.alloc.initWithString(NSString.alloc.initWithUTF8String("http://localhost:#{Port}/index.html"))))
  Window.contentView.addSubview(view)
  Window.setTitle(NSString.alloc.initWithUTF8String("I tell you this 'cause there's no limit!"))
  Window.setCollectionBehavior(1 << 7)

  NSApplication.sharedApplication.tap { |app| app.setActivationPolicy(0); app.activateIgnoringOtherApps(1) }.run
end
