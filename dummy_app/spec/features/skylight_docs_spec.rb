require 'rails_helper'

describe "visiting support index page" do
  it "displays all of the chapters" do
    visit "/support"
    expect(page).to have_content("Markdown Styleguide")
    expect(page).to have_content("A Aardvark Chapter")
    expect(page).to have_content("Third Chapter")
  end
end

describe "visiting a chapter page" do
  it "displays the correct chapter page" do
    visit "/support"
    click_on "Markdown Styleguide"
    expect(page).to have_content("Content of the markdown styleguide")
    expect(page).to have_current_path('/support/markdown-styleguide')
  end

  it 'parses `link_to` helpers, adding html options for external or anchor links' do
    visit "/support/markdown-styleguide"
    expect(page.html).to include('<a href="./a-aardvark-chapter">internal</a>')
    expect(page.html).to include('<a class="js-scroll-link" href="#header-1">anchor</a>')
  end

  it 'generates HTML for a table of contents' do
    visit "/support/markdown-styleguide"
    expect(page).not_to have_css('.support-menu-chapter-list a[href="#header-1"]')
    expect(page).to have_css('.support-menu-chapter-list a[href="#header-2"]')
    expect(page).to have_css('.support-menu-chapter-list a[href="#header-3"]')
    expect(page).not_to have_css('.support-menu-chapter-list a[href="#header-4"]')
  end

  it 'does not include the frontmatter' do
    # NOTE: This really only tests the dummy app's markdown handler
    # which is currently identical to the one in the client app.
    visit "/support/markdown-styleguide"
    expect(page).not_to have_content('description: This one line description shows up')
  end

  context "when the chapter name is invalid" do
    it "redirects to the support index page" do
      visit "/support/bork"
      expect(page).to have_current_path('/support/bork')
      expect(page).to have_content("\"Bork\" has been moved.")
      expect(page.status_code).to eq(404)
    end
  end
end
