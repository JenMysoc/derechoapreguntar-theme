# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do

  User.class_eval do
    has_one :general_law, :dependent => :destroy,
                          :validate => true,
                          :autosave => true

    accepts_nested_attributes_for :general_law

    validates :terms,
              :acceptance => {
                :message => _('Please accept the Terms and Conditions'),
                :on => :create,
                :allow_nil => false
              }

    validates :identity_card_number,
              :presence => {
                :message => _('Please enter your Identity Card number')
              },
              :format => {
                :with => /\A\d\d\d-\d\d\d\d\d\d-\d\d\d\d[A-Z]\z/,
                :message => _("Please enter your Identity Card number in the correct format"),
                :allow_blank => true
              }

    validates :general_law,
              :presence => {
                :message => _('Please enter your General Law information')
              }

    validates :name,
              :format => {
                :with => /\s/,
                :message => _("Please enter your full name - it is required by law when making a request") }


    after_save :update_censor_rules

    private

    def update_censor_rules
      censor_rules.where(:text => identity_card_number).first_or_create(
        :text => identity_card_number,
        :replacement => _('REDACTED'),
        :last_edit_editor => THEME_NAME,
        :last_edit_comment => _('Updated automatically after_save')
      )
    end

  end

end
