# frozen_string_literal: true

#
# Freelancer page
#
class FreelancerPage < BasePage


  def name
    page.find_element(css: 'h2.m-xs-bottom').text
  end

  def profile_title
    page.find_element(css: 'h3.m-0-top.m-sm-bottom.ng-scope')
  end

  def location
    page.find_element(css: '.fe-map-trigger')
  end

  def description
    page.find_element(tag_name: 'o-profile-overview')
  end

  def profile_rate
    page.find_element(tag_name: 'cfe-profile-rate')
  end

  def total_earned
    aggregated_progress_element 'Total earned'
  end

  def total_jobs
    aggregated_progress_element 'Jobs'
  end

  def total_hours_worked
    aggregated_progress_element 'Hours worked'
  end

  def profiles_list
    page.find_elements(css: 'button.o-tag-skill.specialty-tag')
  end

  # Will work just for non-authorized requests
  # TODO: rework
  def portfolio_count
    more_portfolio_items = find_element_or_nil { page.find_element(tag_name: 'fe-visitor-portfolios') }
    result = more_portfolio_items.nil? ? 0 : more_portfolio_items.attribute('data-more-portfolio-items').to_i
    o_profile_portfolio = find_element_or_nil { page.find_element(tag_name: 'o-profile-portfolio') }
    unless o_profile_portfolio.nil?
      elements = find_elements_or_nil { o_profile_portfolio.find_elements(tag_name: 'up-project-thumb') }
      result = elements.nil? ? result : result + elements.size
    end
    result
  end

  def top_rated?
    result = find_elements_or_nil { page.find_elements(css: 'span.badge.badge-top-rated') }
    result.nil? ? false : result.select { |e| e.text.downcase == 'top rated' }.count.positive?
  end

  def job_success
    page.find_element(tag_name: 'o-job-success').attribute('jss-value')
  end

  def skills
    result = []
    is_one_list_skills = find_element_or_nil { skills_container.find_element(tag_name: 'cfe-profile-skills') }.nil?
    if is_one_list_skills
      skill = {
        tags_group_name: nil,
        tags: skills_container.find_elements(css: 'a.o-tag-skill').map(&:text)
      }
      result.append(skill)
    else
      skills_container.find_elements(css: 'div.form-group').each do |el|
        skill = {
          tags_group_name: el.find_element(tag_name: 'label').text,
          tags: el.find_elements(tag_name: 'span.o-tag-skill').map(&:text)
        }
        result.append(skill)
      end
    end
    result
  end


  private

  # container for Total earned, Jobs, Hours worked
  def aggregated_progress_element(name)
    result = page.find_elements(css: '.cfe-aggregates ul li')
                 .select { |v| v.find_element(css: 'div.text-muted').text == name }
                 .first
    result.nil? ? '' : result.find_element(tag_name: 'h3').text
  end

  # skills container
  def skills_container
    page.find_elements(css: 'div.air-card')
        .select { |v| v.find_element(tag_name: 'h2').text == 'Skills' }
        .first
        .find_element(css: 'div.in section')
  end

  def page
    @driver.find_element(id: 'oProfilePage')
  end

end
