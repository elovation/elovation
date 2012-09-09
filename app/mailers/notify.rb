class Notify < ActionMailer::Base
  default :from => Settings.email.from_address

  def challenge_email(base_url, challenge)
    ActionMailer::Base.asset_host = base_url # can this be added before all emails?
    @base_url = base_url
    @challenge = challenge
    mail(
      :to => @challenge.challengee.email,
      :subject => "You have been challenged in #{@challenge.game.name}"
    )
  end
end
