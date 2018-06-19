CompanyCategory.create!([
  {name: "beauty", label: "Beauty"},
  {name: "health", label: "Health"},
  {name: "cleaning", label: "Cleaning"},
  {name: "kitchen", label: "Kitchen"}
])
Country.create!([
  {name: "Australia", code: "AU"}
])
User.create!([
  {first_name: "Nicolas", last_name: "Connault", username: "nicolasconnault@gmail.com", password: nil, email: "nicolasconnault@gmail.com", encrypted_password: "$2a$11$FiRr6u7dkpb192VoCpIHJ.APetyihnf8vz.0Iz7L3sl4LoMNwIvJW", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, confirmation_token: nil, confirmed_at: nil, confirmation_sent_at: nil, unconfirmed_email: nil, failed_attempts: 0, unlock_token: nil, locked_at: nil, avatar_file_name: nil, avatar_content_type: nil, avatar_file_size: nil, avatar_updated_at: nil, phone: nil},
  {first_name: "Jasmine", last_name: "Standley", username: nil, password: nil, email: "jasmine.standley@gmail.com", encrypted_password: "$2a$11$.ha/dh.PxzyiWGUmpT9P2OH029AxeRWoKlb2rkJ3kIrqB6nhPiFW6", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, confirmation_token: nil, confirmed_at: nil, confirmation_sent_at: nil, unconfirmed_email: nil, failed_attempts: 0, unlock_token: nil, locked_at: nil, avatar_file_name: nil, avatar_content_type: nil, avatar_file_size: nil, avatar_updated_at: nil, phone: nil},
  {first_name: "James", last_name: "Temple", username: nil, password: nil, email: "james.temple@gmail.com", encrypted_password: "", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, confirmation_token: nil, confirmed_at: nil, confirmation_sent_at: nil, unconfirmed_email: nil, failed_attempts: 0, unlock_token: nil, locked_at: nil, avatar_file_name: nil, avatar_content_type: nil, avatar_file_size: nil, avatar_updated_at: nil, phone: nil},
  {first_name: "Samantha", last_name: "Standley", username: "samantha.standley@gmail.com", password: nil, email: "samantha.standley@gmail.com", encrypted_password: "$2a$11$7if34/dcdya.b.f5duWopupU9/xQqQKOyS3pv2m75wDU9hNWHroku", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, confirmation_token: nil, confirmed_at: nil, confirmation_sent_at: nil, unconfirmed_email: nil, failed_attempts: 0, unlock_token: nil, locked_at: nil, avatar_file_name: nil, avatar_content_type: nil, avatar_file_size: nil, avatar_updated_at: nil, phone: "0435423747"}
])
Address.create!([
  {country_id: 1, user_id: 2, street1: "23 Fake street", street2: nil, unit: nil, suburb: "Bunbury", latitude: -33.325636, longitude: 115.6396494, phone: nil, fax: nil, state: "WA", postcode: "6210", timezone: "Australia/Perth"},
  {country_id: 1, user_id: 3, street1: "60 Blair Street", street2: nil, unit: nil, suburb: "Bunbury", latitude: -33.325636, longitude: 115.6396494, phone: nil, fax: nil, state: "WA", postcode: "6230", timezone: "Australia/Perth"},
  {country_id: 1, user_id: 4, street1: "Wraight Street", street2: nil, unit: nil, suburb: "Pimpama", latitude: -27.816667, longitude: 153.3, phone: nil, fax: nil, state: "QLD", postcode: "4209", timezone: "Australia/Brisbane"}
])
Company.create!([
  {name: "scentsy", label: "Scentsy", company_category_id: 3},
  {name: "jamberry", label: "Jamberry", company_category_id: 2},
  {name: "enjo", label: "Enjo", company_category_id: 1},
  {name: "tupperware", label: "Tupperware", company_category_id: 4},
  {name: "avon", label: "Avon", company_category_id: 2}
])
Role.create!([
  {name: "customer", resource_type: nil, resource_id: nil, label: nil},
  {name: "consultant", resource_type: nil, resource_id: nil, label: nil}
])
Subscription.create!([
  {user_id: 2, company_id: 1, active: true, website_url: "http://facebook.com", facebook_url: "https://www.facebook.com/FabricTrove", twitter_url: "https://twitter.com/fabric_trove"},
  {user_id: 2, company_id: 2, active: true, website_url: "http://facebook.com", facebook_url: "https://www.facebook.com/FabricTrove\t", twitter_url: nil},
  {user_id: 3, company_id: 1, active: true, website_url: "http://facebook.com", facebook_url: "https://www.facebook.com/FabricTrove\t", twitter_url: nil}
])
UsersCompany.create!([
  {user_id: 1, company_id: 5, consultant_id: nil, enabled: false},
  {user_id: 1, company_id: 2, consultant_id: 2, enabled: true},
  {user_id: 1, company_id: 4, consultant_id: nil, enabled: true},
  {user_id: 1, company_id: 3, consultant_id: nil, enabled: true},
  {user_id: 1, company_id: 1, consultant_id: 3, enabled: true}
])
UsersRole.create!([
  {user_id: 1, role_id: 1},
  {user_id: 2, role_id: 2},
  {user_id: 3, role_id: 2},
  {user_id: 4, role_id: 2}
])
