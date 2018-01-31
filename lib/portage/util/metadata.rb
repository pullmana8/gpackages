require 'digest'
class Portage::Util::Metadata
  def initialize(file)
    @metadata = {}
    @file = file

    f = File.open(file)
    parse! Nokogiri::XML(f)
    f.close
  end

  def [](key)
    @metadata[key]
  end

  def hash
    Digest::MD5.file(@file).hexdigest
  end

  private

  def parse!(xml)
    # <herd>
    @metadata[:herds] = xml.xpath('/pkgmetadata/herd').map(&:text)

    # <maintainer>
    @metadata[:maintainer] = []
    xml.xpath('/pkgmetadata/maintainer').each do |maintainer_tag|
      @metadata[:maintainer] << {
        email:       single_xpath(maintainer_tag, './email/text()'),
        name:        single_xpath(maintainer_tag, './name/text()'),
        type:        maintainer_tag['type'],
        description: single_xpath(maintainer_tag, './description/text()'),
        restrict:    maintainer_tag['restrict']
      }
    end

    # <use>/<flag>
    @metadata[:use] = {}
    xml.xpath('/pkgmetadata/use/flag').each do |flag_tag|
      # inner_html as there are <pkg> and <cat> links
      @metadata[:use][flag_tag['name']] = clean_xml_str(flag_tag.inner_html)
    end

    # <natural-name>
    @metadata[:natural_name] = single_xpath(xml, '/pkgmetadata/natural-name/text()')

    # <longdescription>
    @metadata[:longdescription] = { en: nil }
    xml.xpath('/pkgmetadata/longdescription').each do |desc_tag|
      if desc_tag.has_attribute? 'lang'
        @metadata[:longdescription][desc_tag['lang'].downcase.to_sym] = clean_xml_str(desc_tag.text)
      else
        @metadata[:longdescription][:en] = clean_xml_str(desc_tag.text)
      end
    end
  end

  def single_xpath(xml, path)
    if (res = xml.xpath(path)).empty?
      nil
    else
      res.to_s
    end
  end

  def clean_xml_str(input)
    input.strip.gsub(/\s+/, ' ')
  end
end
