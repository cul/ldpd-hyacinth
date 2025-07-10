module Hyacinth
  module FormObjects
    class FormObject
      include ActiveModel::Model

      UTF8_BOM = [239, 187, 191].pack('C*')

      def strip_utf8_bom(data)
        if data.present? && data.byteslice(0...UTF8_BOM.length).b == UTF8_BOM
          data = data.byteslice(UTF8_BOM.length..-1).force_encoding('UTF-8')
        end
        data
      end
    end
  end
end
