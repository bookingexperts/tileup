module TileUp
  module ImageProcessors
    class Vips < TileUp::ImageProcessor

      def initialize(logger)
        require 'vips'
        super(logger)
      end

      def width(image)
        vips_image(image).width
      end

      def height(image)
        vips_image(image).height
      end

      private

      def open_image(image_filename)
        { file_name: image_filename }
      end

      def scale_image(image, scale)
        image = image.dup
        image[:scale] = scale
        image
      end

      def vips_image(image)
        cropped_image = ::Vips::Image.new_from_file(image[:file_name], access: :sequential).bandjoin(255)
        cropped_image = cropped_image.resize(image[:scale]) if image[:scale]
        cropped_image
      end

      def crop_and_save_image(image, crop, filename:, extend_crop: false, extend_color: 'none')
        cropped_image = vips_image(image)

        if extend_crop
          raise "Extend color not supported with vips" unless extend_color == 'none'
          cropped_image = cropped_image.embed(0, 0, width(image) + crop[:width], height(image) + crop[:height], extend: :background,  background: [0, 0, 0, 0])
        end

        cropped_image = cropped_image.crop(crop[:x], crop[:y], crop[:width], crop[:height])
        
        cropped_image.write_to_file(filename)

        true
      rescue StandardError => e
        logger.error "Failed to crop image: #{e.message}"

        false
      end
    end
  end
end