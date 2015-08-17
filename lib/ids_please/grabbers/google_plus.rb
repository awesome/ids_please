class IdsPlease
  module Grabbers
    class GooglePlus < IdsPlease::Grabbers::Base

      def grab_link
        @network_id   = find_network_id
        @avatar       = find_avatar
        @display_name = find_display_name
        @username     = find_username

        @counts = {
          followers: find_followers,
          views: find_views,
          reviews: find_reviews
        }.delete_if {|k,v| v.nil? }

        @data = {
          description: find_description
        }

        self
      rescue => e
        record_error __method__, e.message
        return self
      end

      def find_network_id
        page_source.scan(/data-oid="(\d+)"/).flatten.first
      rescue => e
        record_error __method__, e.message
        return nil
      end

      def find_avatar
        'https:' + page_source.scan(/guidedhelpid="profile_photo"><img src="([^"]+)"/).flatten.first
      rescue => e
        record_error __method__, e.message
        return nil
      end

      def find_display_name
        page_source.scan(/og:title" content="([^"]+)"/).flatten.first.gsub(' - Google+','')
      rescue => e
        record_error __method__, e.message
        return nil
      end

      def find_username
        '+' + page_source.scan(/&quot;https:\/\/plus.google.com\/\+(.+?)&quot;/).flatten.first
      rescue => e
        record_error __method__, e.message
        return nil
      end

      def find_description
        page_source.scan(/name="Description" content="([^"]+)">/).flatten.first.encode('utf-8')
      rescue => e
        record_error __method__, e.message
        return nil
      end

      def find_followers
        page_source.scan(/">([^"]+)<\/span> followers</).flatten.first.tr(',','').to_i
      rescue => e
        record_error __method__, e.message
        return nil
      end

      def find_views
        page_source.scan(/">([^"]+)<\/span> views</).flatten.first.tr(',','').to_i
      rescue => e
        record_error __method__, e.message
        return nil
      end

      def find_reviews
        nil
      rescue => e
        record_error __method__, e.message
        return nil
      end
    end
  end
end
