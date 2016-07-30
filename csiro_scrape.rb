#!/usr/bin/env ruby

require 'open-uri'
require 'csv'

BASE_URL = 'ftp://ftp.ga.gov.au/outgoing-emergency-imagery/sentinel/'

def getFilePaths
  uri = URI.parse(BASE_URL)
  dirs = ['AVHRR', 'hotspots', 'MODIS', 'VIIRS']
  path_list = []

  dirs.each do |d|
    begin
      Net::FTP.open(uri.host) do |ftp|
        ftp.login
        ftp.chdir(uri.path + d)
        lines = ftp.list('*hotspots.txt')

        lines.each do |l|
          name = l.split(" ").delete_if { |w| !w.include?(".txt")}
          path = BASE_URL + d + '/' + name[0]
          p path
          path_list << path
        end
      end
    rescue Exception => e
      puts "Exception: '#{e}'. FTP Failed."
    end
  end

  path_list
end

def getData(paths)
  CSV::Converters[:blank_to_nil] = lambda do |field|
    field && field.empty? ? nil : field
  end

  paths.each do |path|
    open(path) { |f|
      csv = CSV.new(f, :headers => true, :header_converters => :symbol, :converters => [:all, :blank_to_nil])
      p csv.to_a.map {|row| row.to_hash }
    }
  end

end

paths = getFilePaths
getData(paths)