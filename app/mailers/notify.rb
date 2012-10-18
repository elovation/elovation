class Notify < ActionMailer::Base
  def challenge_email(base_url, challenge)
    ActionMailer::Base.asset_host = base_url
    @base_url = base_url
    @challenge = challenge
    mail(
      :to => @challenge.challengee.email,
      :from => @challenge.challenger.email,
      :subject => "You have been challenged in #{@challenge.game.name}"
    )
  end
end
