module DOSpacesCustomResource
  module Helpers
    require 'uri'

    def local_path_sanitize(path)
      return '' if path.nil?
      return path if path == ''
      return path if path[-1] == '/'
      path + '/'
    end

    def remote_path_sanitize(path)
      return '' if path.nil?
      return path if path == ''
      path += '/' unless path[-1] == '/'
      path = '/' + path unless path[0] == '/'
      path
    end

    def local_package(url)
      ::File.basename(URI.parse(url).path)
    end
  end
end
