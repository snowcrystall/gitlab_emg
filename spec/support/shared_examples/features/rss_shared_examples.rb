# frozen_string_literal: true

RSpec.shared_examples "an autodiscoverable RSS feed with current_user's feed token" do
  it "has an RSS autodiscovery link tag with current_user's feed token" do
    expect(page).to have_css("link[type*='atom+xml'][href*='feed_token=#{user.feed_token}']", visible: false)
  end
end

RSpec.shared_examples "it has an RSS button with current_user's feed token" do
  it "shows the RSS button with current_user's feed token" do
    expect(page)
      .to have_css("a:has(.qa-rss-icon)[href*='feed_token=#{user.feed_token}']") # rubocop:disable QA/SelectorUsage
  end
end

RSpec.shared_examples "an autodiscoverable RSS feed without a feed token" do
  it "has an RSS autodiscovery link tag without a feed token" do
    expect(page).to have_css("link[type*='atom+xml']:not([href*='feed_token'])", visible: false)
  end
end

RSpec.shared_examples "it has an RSS button without a feed token" do
  it "shows the RSS button without a feed token" do
    expect(page)
      .to have_css("a:has(.qa-rss-icon):not([href*='feed_token'])") # rubocop:disable QA/SelectorUsage
  end
end
