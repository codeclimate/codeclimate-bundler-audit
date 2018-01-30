module BePresentInHelper
  def find_missing(expected_set, actual_set)
    expected_set.select { |expected_set_member| !actual_set.include?(expected_set_member) }
  end

  def find_extra(expected_set, actual_set)
    actual_set.select { |actual_set_member| !expected_set.include?(actual_set_member) }
  end

  RSpec::Matchers.define :be_present_in do |actual_set|
    match do |expected_set|
      find_missing(expected_set, actual_set).none?
    end

    failure_message do |expected_set|
      missing = find_missing(expected_set, actual_set).map { |issue| issue["description"] }
      extra = find_extra(expected_set, actual_set)
      extra_description = extra.map { |issue| issue["description"] }

      "Expected these issues to be present, but they weren't: \n#{missing.join("\n")}.\n\nFurther, these issues were present, but not expected (which is OK, but you could expect them if you want to): \n#{extra_description.join("\n")}\n\nFull JSON for the extra ones, in case you want to copy them into the expectation: \n#{JSON.pretty_generate(extra)}"
    end
  end
end

RSpec.configure do |conf|
  conf.include(BePresentInHelper)
end
