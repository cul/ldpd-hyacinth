# frozen_string_literal: true

# TODO: Use secure token gem instead of including this file in Hyacinth code base

require 'digest'
require 'base64'

module Wowza
  # docs TBD
  module SecureToken
    # Wraps a params hash in the sorting and hashing logic necessary
    # to generate a Wowza secure token
    class Params
      # Create the wrapper
      # required symbol keys for:
      # - stream
      # - secret
      # - client_ip
      # - prefix
      # - starttime (Integer)
      # - endtime (Integer)
      # - playstart (Integer)
      # - playduration (Integer)
      # @param opts [Hash] options used to generate a token url
      def initialize(opts)
        @prefix = opts.delete(:prefix)
        @stream = opts.delete(:stream)
        @client_ip = opts.delete(:client_ip)
        @secret = opts.delete(:secret)
        @params = opts
      end

      # @return the sorted token string for the wrapped params
      def to_token
        query_string = params_to_sorted_query_string(prefix_params(@params).merge(@client_ip => nil, @secret => nil))
        "#{@stream}?#{query_string}"
      end

      # @param digest_alg the digest algorithm to be used to hash the params
      # @return a URL-safe B64 encoded hash
      def to_token_hash(digest_alg = Digest::SHA256)
        Base64.urlsafe_encode64(digest_alg.digest(to_token))
      end

      def to_url_with_token_hash(host, port, stream_type)
        query_string = params_to_sorted_query_string(prefix_params(@params))
        case stream_type
        when 'hls', 'hls-ssl'
          (stream_type == 'hls' ? 'http' : 'https') + "://#{host}:#{port}/#{@stream}/playlist.m3u8?#{query_string}&#{@prefix}hash=#{self.to_token_hash}"
        when 'mpeg-dash', 'mpeg-dash-ssl'
          (stream_type == 'mpeg-dash' ? 'http' : 'https') + "://#{host}:#{port}/#{@stream}/manifest.mpd?#{query_string}&#{@prefix}hash=#{self.to_token_hash}"
        when 'rtmp', 'rtmps'
          "#{stream_type}://#{host}:#{port}/#{@stream}?#{query_string}&#{@prefix}hash=#{self.to_token_hash}"
        else
          raise "Unsupported stream_type: #{stream_type}"
        end
      end

      private

        def params_to_sorted_query_string(prms)
          prms.sort.map { |p| p[1].to_s == '' ? p[0] : "#{p[0]}=#{p[1]}" }.join('&')
        end

        def prefix_params(hsh)
          hsh = hsh.clone
          hsh.map { |p| ["#{@prefix}#{p[0]}", p[1]] }.to_h
        end
    end
  end
end
