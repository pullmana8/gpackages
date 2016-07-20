require 'nokogiri'
require 'net/http'
require 'time'

module Portage
  module Util
    class Projects
      PROJECTS_XML = URI('https://api.gentoo.org/metastructure/projects.xml')

      CACHE_DURATION = 3600
      @instance_ts = Time.at(0)
      @instance = nil

      def self.cached_instance
        if (Time.now - @instance_ts) > CACHE_DURATION
          @instance = new
          @instance_ts = Time.now
        end

        @instance
      end

      def initialize
        @xml = Nokogiri::XML(Net::HTTP.get(PROJECTS_XML))
      end

      def projects
        @xml.xpath('/projects/project/email/text()').map(&:to_s)
      end

      def project(project)
        project_tag = @xml.xpath('/projects/project/email[text()="%s"]/..' % project).first
        return nil if project_tag.nil?

        project_hash = {
          email: single_xpath(project_tag, './email/text()'),
          name: single_xpath(project_tag, './name/text()'),
          url: single_xpath(project_tag, './url/text()'),
          description: single_xpath(project_tag, './description/text()'),
          members: [],
          subprojects: []
        }

        project_tag.xpath('./member').each do |member_tag|
          project_hash[:members] << {
            email: single_xpath(member_tag, './email/text()'),
            name: single_xpath(member_tag, './name/text()'),
            role: single_xpath(member_tag, './role/text()'),
            is_lead: member_tag['is-lead'] == '1'
          }
        end

        project_tag.xpath('./subproject').each do |subproject_tag|
          project_hash[:subprojects] << {
            ref: subproject_tag[:ref],
            inherit_members: subproject_tag['inherit-members'] == '1'
          }
        end

        project_hash
      end

      # This inherits one level down only
      def inherited_members(project)
        p = project(project)
        return [] if p.nil?

        members = {}
        p[:members].each { |m| members[m[:email]] = m[:name] }

        p[:subprojects].each do |subp|
          next unless subp[:inherit_members]

          project(subp[:ref])[:members].each { |m| members[m[:email]] = m[:name] }
        end

        result = []
        members.each_pair { |k, v| result << { email: k, name: v } }
        result
      end

      private

      def single_xpath(xml, path)
        if (res = xml.xpath(path)).empty?
          nil
        else
          res.to_s
        end
      end
    end
  end
end
