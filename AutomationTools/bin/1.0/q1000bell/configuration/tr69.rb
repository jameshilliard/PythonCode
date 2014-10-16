# Module for TR-69 ACS settings

module TR69
    def acs_url
        return unless self.menu(:tr69)
        @ff.text_field(:name, "ACSURL").set(@user_choices[:acs_url])
        apply_settings("ACS URL")
        @log.info "ACS URL set to #{@ff.text_field(:name, "ACSURL").value}"
    end
end