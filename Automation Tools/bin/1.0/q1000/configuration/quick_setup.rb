# Quick Setup module

module QuickSetup
    def quick_setup
        return unless self.menu(:quick_setup)
        ppp_domain = "Other ISP"
        ppp_user = @user_choices[:ppp_username]
        if @user_choices[:ppp_username].include?("@")
            ppp_domain = "@qwest.net" if @user_choices[:ppp_username].split("@")[1].match(/qwest/i)
            ppp_domain = "@msndsl.net" if @user_choices[:ppp_username].split("@")[1].match(/msndsl/i)
            ppp_user = @user_choices[:ppp_username].split("@")[0] unless ppp_domain == "Other ISP"
        end
        @ff.text_field(:id, "ppp_username").set(ppp_user) if ppp_user
        @log.info("Quick Setup::Using PPP Username #{@ff.text_field(:id, "ppp_username").value}")
        @ff.text_field(:id, "ppp_password").set(@user_choices[:ppp_password]) if @user_choices[:ppp_password]
        @log.info("Quick Setup::PPP password set to #{@user_choices[:ppp_password]}") if @user_choices[:ppp_password]
        return unless list_select("ppp_domain", ppp_domain) if ppp_user
        @log.info("Quick Setup::Domain is #{@ff.select_list(:id, "ppp_domain").value}")
        # Domain select
        self.apply_settings("Quick Setup")
        # Apply/success
    end
end