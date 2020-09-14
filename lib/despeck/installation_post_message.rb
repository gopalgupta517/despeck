# frozen_string_literal: true

module Despeck
  module InstallationPostMessage
    module_function

    def pre_install_valid?
      require 'vips'
      return print_error unless vips_check_passed?

      true
    end

    def vips_support_pdf?
      begin
        Vips::Image.pdfload
      rescue Vips::Error => e
        if e.message =~ /class "pdfload" not found/
          error_messages << <<~DOC
          - Libvips installed without PDF support, make sure you
            have PDFium/poppler-glib installed before installing
            despeck. For more detail install instruction go to
            this page https://libvips.github.io/libvips/install.html
          DOC
          return false
        end
      end
      true
    end

    def vips_version_supported?
      version_only = Vips.version_string.match(/(\d+\.\d+\.\d+)/)[0]
      return true if version_only > '8.6.5'

      error_messages << <<~DOC
      - Your libvips version is should be minimal at 8.6.5
        Please rebuild/reinstall your libvips to >= 8.6.5 .
      DOC
      false
    end

    def vips_check_passed?
      passed = true
      passed = false unless vips_version_supported?
      passed = false unless vips_support_pdf?
      passed
    end

    def error_messages
      @error_messages ||= []
    end

    def print_error
      return if error_messages.empty?

      puts <<~ERROR
        #{hr '='}
        Despeck Post Installation Notes :
        #{hr}
        #{error_messages.join("\n")}
        #{hr '='}
      ERROR
      @error_message = []
      false
    end

    def hr(line = '-')
      (line * 50)
    end
  end
end