require_relative 'presentation_theme/theme_color'
module OoxmlParser
  class PresentationTheme < OOXMLDocumentObject
    attr_accessor :name, :color_scheme

    def initialize(name = '', color_scheme = {})
      @name = name
      @color_scheme = color_scheme
    end

    def self.parse(file)
      OOXMLDocumentObject.theme = PresentationTheme.new
      OOXMLDocumentObject.add_to_xmls_stack(file)
      unless File.exist?(OOXMLDocumentObject.current_xml)
        OOXMLDocumentObject.xmls_stack.pop
        return
      end
      doc = Nokogiri::XML(File.open(OOXMLDocumentObject.current_xml))
      doc.xpath('a:theme').each do |theme_node|
        OOXMLDocumentObject.theme.name = theme_node.attribute('name').value if theme_node.attribute('name')
        theme_node.xpath('a:themeElements/*').each do |theme_element_node|
          case theme_element_node.name
          when 'clrScheme'
            theme_element_node.xpath('*').each do |color_scheme_element|
              OOXMLDocumentObject.theme.color_scheme[color_scheme_element.name.to_sym] = ThemeColor.new.parse(color_scheme_element)
            end
            OOXMLDocumentObject.theme.color_scheme[:background1] = OOXMLDocumentObject.theme.color_scheme[:lt1]
            OOXMLDocumentObject.theme.color_scheme[:background2] = OOXMLDocumentObject.theme.color_scheme[:lt2]
            OOXMLDocumentObject.theme.color_scheme[:bg1] = OOXMLDocumentObject.theme.color_scheme[:lt1]
            OOXMLDocumentObject.theme.color_scheme[:bg2] = OOXMLDocumentObject.theme.color_scheme[:lt2]
            OOXMLDocumentObject.theme.color_scheme[:text1] = OOXMLDocumentObject.theme.color_scheme[:dk1]
            OOXMLDocumentObject.theme.color_scheme[:text2] = OOXMLDocumentObject.theme.color_scheme[:dk2]
            OOXMLDocumentObject.theme.color_scheme[:tx1] = OOXMLDocumentObject.theme.color_scheme[:dk1]
            OOXMLDocumentObject.theme.color_scheme[:tx2] = OOXMLDocumentObject.theme.color_scheme[:dk2]
          end
        end
      end
      OOXMLDocumentObject.xmls_stack.pop
      ThemeColors.list = {}
      OOXMLDocumentObject.theme.color_scheme.each { |key, value| ThemeColors.list[key] = value.color }
      OOXMLDocumentObject.theme
    end
  end
end
