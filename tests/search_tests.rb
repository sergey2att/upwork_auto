# frozen_string_literal: true

require_relative '../lib/testcase'
require_relative '../pages/front_page'
require_relative '../pages/search_page'
require_relative '../pages/freelancer_page'
require_relative '../lib/asserts'

#
# Class for search tests
# Each test must start from 'test_' prefix
# It will be a good practise to set default test arguments if they exist

class SearchTest < TestCase

  def initialize(driver)
    super(driver)
    @front_page = FrontPage.new(@driver)
    @search_page = SearchPage.new(@driver)
    @freelancer_page = FreelancerPage.new(@driver)
    @logger = SimpleLog.new
    @logger.progname = 'UI_Auto:'
  end

  # Test case title here. Also annotation logic can be implemented for
  # adding test types. For example: @bat, @sanity, @regression
  def test_1(term = 'Java')
    # Test looks too complicated and may be separated for 2 scenarios
    @front_page.load''
    @front_page.search_for'Freelancers & Agencies', term
    # let's search just freelancers
    @search_page.apply_filter('Talent Type', 'Freelancers')
    # let's collect all search results
    profiles = @search_page.collect_freelancers
    # Check that result contains search keyword
    verify_search_profile_contains(profiles, term)
    # take sample result and check data
    sample_profile = profiles.keys.sample
    @search_page.scroll_and_click { sample_profile }

    # compare profile params with search param
    random_profile = profiles[sample_profile]
    random_profile_description = random_profile[:description]
                                 .delete_suffix('...')
                                 .delete_suffix(' more').strip
    random_profile_specialization = random_profile[:specialization_line]
                                    .delete_prefix('Specializes in ')

    full_profile_total_earned = @freelancer_page.total_earned
    full_profile_skills = @freelancer_page.skills.map { |v| v[:tags] }
    full_profile_profiles_list = @freelancer_page.profiles_list.map(&:text)

    Asserts.assert_equal(@freelancer_page.name, random_profile[:name], 'Names comparing')
    Asserts.assert_equal(@freelancer_page.profile_title.text, random_profile[:profile_title],
                         'Profile titles comparing')
    Asserts.assert_true('Search result location include in Profile location') do
      @freelancer_page.location.text.include? random_profile[:location]
    end
    Asserts.assert_equal(@freelancer_page.profile_rate.text, random_profile[:hourly_rate],
                         'Hourly rates comparing')
    Asserts.assert_equal(full_profile_total_earned, random_profile[:total_earned], 'Total earnings comparing')
    Asserts.assert_equal(@freelancer_page.top_rated?, random_profile[:top_rated],
                         'Checking top rated params match')
    Asserts.assert_true('Check that searched portfolio count more or equal to profile portfolios') do
      random_profile[:portfolios_count] >= @freelancer_page.portfolio_count
    end
    Asserts.assert_equal(@freelancer_page.job_success, random_profile[:job_success],
                         'Job success comparing')
    Asserts.assert_true("Full description: '#{@freelancer_page.description.text}', short description '#{random_profile_description}'") do
      @freelancer_page.description.text.include? random_profile_description
    end
    unless full_profile_profiles_list.empty? && random_profile[:specialization_line].empty?
      Asserts.assert_true('Check that specialize areas matches') do
        @freelancer_page.profiles_list.map(&:text).include? random_profile_specialization
      end
    end
    random_profile[:skills].map { |v| v[:tags] }.each do |array|
      Asserts.assert_true("Array '#{array}' includes in freelancer profile skills") do
        full_profile_skills.select { |v| array == (array & v) }.size.positive?
      end
    end

  end

  # test example
  def test_2
    Asserts.assert_false { false }
  end

  # test example
  def test_3
    Asserts.assert_equal(true, false)
  end


  private

  # All checks must be done in test case classes. We must not use pages for it
  def verify_search_profile_contains(profiles, keyword)
    keyword = keyword.strip.downcase
    markers = []
    profiles.each_key do |profile|
      profiles[profile].each_key do |pk|
        param = profiles[profile][pk]
        if pk == :skills
          markers += verify_skills(param, keyword)
        else
          profile_param = param.nil? ? '' : param.to_s.downcase
          result = profile_param.include? keyword
          markers.append result
          @logger.warning("Keyword '#{keyword}' is#{result ? '' : ' not'} included in param '#{pk}' => '#{profile_param}'")
        end
      end
    end
    Asserts.assert_true('Profile contains search keyword') { markers.include? true }
  end

  def verify_skills(skills, keyword)
    skill_markers = []
    skills.each do |skill|
      skill.each_key do |sk|
        if sk == :tags
          skill[sk].each do |tag|
            result = tag.downcase.include? keyword
            skill_markers.append result
            @logger.warning("Keyword '#{keyword}' #{result ? '' : 'is not'} included in param '#{sk}' => '#{tag.downcase}'")
          end
        else
          skills_group = skill[sk].empty? ? '' : skill[sk].downcase.delete_suffix("-").strip
          result = skills_group.include? keyword
          skill_markers.append result
          @logger.warning("Keyword '#{keyword}' #{result ? '' : 'is not'} included in param '#{sk}' => '#{skills_group}'")
        end
      end
    end
    skill_markers
  end

end