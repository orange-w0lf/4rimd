#!/usr/bin/env ruby

# 4rimd v0.2
# by Allan Clark - <napta2k@gmail.com>, Forked by Bluebird - <gr33nmous3@gmail.com>
# This script will download all images in a given 4chan category, now with arguments.
# URL: http://github.com/orange-w0lf/4rimd
# Proper usage ./4rimd.rb board res/thread id

require 'rubygems'
require 'mechanize'

#argv
board = ARGV[0]
id = ARGV[1]

# 4chan category
url = "http://boards.4chan.org"+board

# Visit imageboard
agent = Mechanize.new
agent.user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:2.0b6) Gecko/20100101 Firefox/4.0b6'
page = agent.get_file(url)

#create directories
pwd = Dir::pwd;
bdir = pwd+board;
rdir = bdir+"res";
idir = bdir+id;
if !FileTest::directory?(bdir)
	Dir::mkdir(bdir)
end

if !FileTest::directory?(rdir)
	Dir::mkdir(rdir)
end

if !FileTest::directory?(idir)
	Dir::mkdir(idir)
end
puts "START,#{board},#{id},";
# Find out how many pages the imageboard has ; visit each one
replies = agent.page.links_with(:text => %r{^\d}, :href => %r{^\d+$}).each do |reply|
  link = "#{url}#{reply.href}"
  begin
    page = agent.get(link)
  rescue Mechanize::ResponseCodeError
  end
  puts "#PAGE#{reply.href},"
  # Find image posts 
  replies = agent.page.links_with(:text => "Reply")

  # For each image post, click Reply and harvest image URLs
  replies.each do |reply|
    begin
      reply.click
    rescue Mechanize::ResponseCodeError
    end
    puts "#POST#{reply.href},"
    if reply.href == id then
      # Download all images on the page, try to ignore duplicates
      replies = agent.page.links_with(:text => %r{\d*.jpg$}, :href => %r{\/src\/\d*.jpg$})
      replies.each do |reply|
        link = "#{reply.href}"
        filename = File.basename(reply.href)

        # Skip the file if it exists
        if FileTest.exist?("#{pwd}#{board}#{id}/#{filename}")
          puts "#{board}#{id}/#{filename},"
          next
        end
        puts "#{board}#{id}/#{filename},"
        begin
        
        # Hash out the line below for a dry-run
        agent.get(link).save_as(pwd+board+id+"/"+filename)
        rescue Mechanize::ResponseCodeError
        end
      end
    abort("END");
    end
  end
end
agent.history.clear