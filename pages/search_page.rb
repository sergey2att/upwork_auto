# frozen_string_literal: true

require_relative 'base_page'

#
# Search freelancers page

class SearchPage < BasePage

  # freelancer filter
  def apply_filter(type, name)
    filter_button.click
    sleep 1
    radio_type = @driver.find_element(tag_name: 'freelancer-facet-search')
                        .find_elements(tag_name: 'facet-input-radio-list')
                        .select { |v| v.attribute('data-label') == type }.first
    radio = radio_type.find_elements(tag_name: 'label')
                      .select { |s| (s.text.sub /\s*\(.+\)$/, '') == name }
                      .first
    scroll_and_click { radio }
    sleep 1
    filter_button.click
    sleep 5 # TODO: should be replaced with smart waiter
  end

  def filter_button
    result = @driver.find_element(css: 'div.filters-button')
    scroll_to_element { result }
    result
  end

  def collect_freelancers
    profiles = {}
    results = @driver.find_element(id: 'oContractorResults')
    results.find_elements(tag_name: 'article').each do |article|
      skills = collect_skills(article)
      specialization_line = element_text_or_empty do
        article.find_element(css: '.ng-isolate-scope div.text-muted.p-sm-top.ng-binding.ng-scope')
      end
      portfolios_count = find_element_or_nil { article.find_element(css: '.m-0-bottom small a') }
      profile_key = article.find_element(css: 'h4 a')
      profile = {
        name: article.find_element(css: 'h4 a').text,
        profile_title: article.find_element(css: 'h4.freelancer-tile-title').text,
        hourly_rate: article.find_element(css: '.pull-left.ng-binding').text,
        total_earned: element_text_or_empty do
          article.find_element(css: '.ng-isolate-scope span.d-lg-inline strong.ng-binding')
        end,
        location: article.find_element(class: 'freelancer-tile-location').text,
        specialization_line: specialization_line,
        description: article.find_element(css: 'p.freelancer-tile-description').text,
        top_rated: !find_element_or_nil { article.find_element(css: 'span.badge-top-rated span.air-icon-top-rated') }.nil?,
        portfolios_count: portfolios_count.nil? ? 0 : portfolios_count.text.to_i,
        job_success: job_success(article),
        skills: skills
      }
      profiles[profile_key] = profile
    end
    profiles
  end

  private

  def collect_skills(profile)
    skills = []
    profile.find_elements(css: '.skills-section').each do |skill_row|
      skills_group = element_text_or_empty { skill_row.find_element(css: 'ul li strong.ng-binding') }
      skill = {
        tags_group_name: skills_group.delete_suffix('-').strip,
        tags: skill_row.find_elements(css: 'ul li .o-tag-skill').map(&:text)
      }
      skills.append(skill)
    end
    skills
  end

  def job_success(root)
    result = find_elements_or_nil { root.find_elements(css: 'span.ng-isolate-scope') }
    if result.nil?
      nil
    else
      first = result.select { |v| v.attribute('data-jss-value') }.first
      first.nil? ? nil : first.attribute('data-jss-value')
    end
  end
end
