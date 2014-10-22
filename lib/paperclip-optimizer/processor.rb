require "paperclip"
require "image_optim"

module Paperclip
  class PaperclipOptimizer < Processor
    def make
      settings = (@options[:paperclip_optimizer] || Rails.application.config.assets.image_optim).reverse_merge(::PaperclipOptimizer::DEFAULT_SETTINGS)

      src_path = File.expand_path(@file.path)

      if settings[:verbose]
        Paperclip.logger.info "optimizing #{src_path} with settings: #{settings.inspect}"

        old_stderr  = $stderr
        $stderr     = ::PaperclipOptimizer::StdErrCapture.new(Paperclip.logger)
      end

      begin
        image_optim           = ImageOptim.new(settings)
        compressed_file_path  = image_optim.optimize_image(src_path)
      ensure
        $stderr = old_stderr if settings[:verbose]
      end

      if compressed_file_path && File.exists?(compressed_file_path)
        return File.open(compressed_file_path)
      else
        return @file
      end
    end
  end
end
