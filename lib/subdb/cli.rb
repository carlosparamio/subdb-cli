require 'subdb/cli/version'
require 'digest'
require 'faraday'

module Subdb
  class Cli

    BASE_URL = 'http://api.thesubdb.com/'
    READSIZE = 64 * 1024

    FileNotFound         = Class.new(StandardError)
    ErrorCalculatingHash = Class.new(StandardError)
    SubtitlesNotFound    = Class.new(StandardError)
    SubtitleUploadError  = Class.new(StandardError)

    def download(video_file_path, language)
      raise FileNotFound unless File.exists?(video_file_path)

      response = client.get('/', {
        action: 'download',
        language: language,
        hash: hash_for(video_file_path)
      })

      raise SubtitleNotFound unless response.status == 200

      File.open(srt_file_for(video_file_path), "w") do |srt_file|
        srt_file.write(response.body)
      end
    end


    def upload(video_file_path, subtitles_file_path)
      raise FileNotFound unless File.exists?(video_file_path)
      raise FileNotFound unless File.exists?(subtitles_file_path)

      response = client.post('/?action=upload', {
        hash: hash_for(video_file_path),
        file: Faraday::UploadIO.new(subtitles_file_path, 'application/octet-stream')
      })

      raise SubtitleUploadError unless response.status == 200
    end

  private

    def srt_file_for(file_path)
      dir = File.dirname(file_path)
      basename = File.basename(file_path, File.extname(file_path))
      File.join(dir, "#{basename}.srt")
    end

    def hash_for(file_path)
      file    = File.open(file_path, "r")
      buffer  = file.read(READSIZE)
      file.seek(-READSIZE, IO::SEEK_END)
      buffer += file.read(READSIZE)
      file.close
      md5_for(buffer)
    rescue
      raise ErrorCalculatingHash
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
      "SubDB/1.0 (subdb-cli/#{VERSION}; https://github.com/carlosparamio/subdb-cli)"
    end

  end
end
