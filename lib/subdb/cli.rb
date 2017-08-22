require 'subdb/cli/version'
require 'digest'
require 'faraday'

module Subdb
  class Cli

    BASE_URL = 'http://api.thesubdb.com/'
    READSIZE = 64 * 1024

    FileNotFound      = Class.new(StandardError)
    SubtitlesNotFound = Class.new(StandardError)

    def download(file_path, language)
      response = client.get('/', {
        action: 'download',
        language: language,
        hash: hash_for(file_path)
      })

      raise SubtitleNotFound unless response.status == 200

      File.open(srt_file_for(file_path), "w") do |file|
        file.write(response.body)
      end
    end

  private

    def srt_file_for(file_path)
      dir = File.dirname(file_path)
      basename = File.basename(file_path, File.extname(file_path))
      File.join(dir, "#{basename}.srt")
    end

    def hash_for(file_path)
      file    = File.open(file_path)
      buffer  = file.read(READSIZE)
      file.seek(-READSIZE, IO::SEEK_END)
      buffer += file.read(READSIZE)
      file.close
      md5_for(buffer)
    rescue Errno::ENOENT
      raise FileNotFound
    end

    def md5_for(buffer)
      md5 = Digest::MD5.new
      md5.update(buffer)
      md5.hexdigest
    end

    def client
      @_client ||= Faraday.new(url: BASE_URL).tap do |client|
        client.headers[:user_agent] = user_agent
      end
    end

    def user_agent
      "SubDB/1.0 (subdb-cli/0.1; https://github.com/carlosparamio/subdb-cli)"
    end

  end
end
