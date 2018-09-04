class Api::ConsultantController < Api::ApplicationController

  before_action :doorkeeper_authorize!, except: [:register]

  def save_profile
    user = current_resource_owner
    
    # TODO handle change of email address
    # TODO handle change of password
    user.update_attributes(
      username: params[:username],
      first_name: params[:firstName],
      last_name: params[:lastName],
      email: params[:username],
      password: params[:password]
    )

    if user.address.nil?
      user.address = Address.create(
        street1: params[:street],
        postcode: params[:postcode],
        suburb: params[:suburb],
      )
    else
      user.address.update_attributes(
        street1: params[:street],
        postcode: params[:postcode],
        suburb: params[:suburb],
      )
    end
    user_details
  end

  def subscribed_companies
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: { 
          results: user.subscriptions.map do |s| 
            {
              id: s.id,
              companyName: s.company.name, 
              companyLabel: s.company.label, 
              companyId: s.company.id,
              customerCount: s.customers.count,
              active: s.active,
              websiteUrl: s.website_url,
              facebookUrl: s.facebook_url,
              twitterUrl: s.twitter_url,
              newsItems: s.news_items.map {|ni| {
                id: ni.id,
                newsType: {
                  id: ni.news_type.id,
                  name: ni.news_type.name,
                  label: ni.news_type.label,
                },
                title: ni.title,
                description: ni.description,
                startDate: ni.start_date,
                endDate: ni.end_date,
                active: ni.active,
                url: ni.url,
                discountedPrice: ni.discountedPrice,
                regularPrice: ni.regularPrice
              }},

              tutorials: s.company.company_tutorials.map {|t| {
                id: t.id,
                title: t.title,
                steps: t.tutorial_steps.map {|ts| {
                  id: ts.id,
                  title: ts.title,
                  number: ts.sort_order,
                  video: ts.video,
                  description: ts.description,
                }}
              }},

              customers: s.subscription_users.map {|su| 
                c = su.user
                country_object = (c.address.nil?) ? { code: nil } : {
                  id: c.address.country.id,
                  name: c.address.country.name,
                  code: c.address.country.code
                }
                {
                  id: c.id,
                  subscriptionUserId: su.id,
                  username: c.email,
                  firstName: c.first_name,
                  lastName: c.last_name,
                  name: "#{c.last_name} #{c.first_name}",
                  street: c.street1,
                  suburb: c.suburb,
                  postcode: c.postcode,
                  state: c.state,
                  potentialRecruit: su.potential_recruit,
                  potentialHost: su.potential_host,
                  currentHost: su.current_host,
                  phone: c.phone,
                  email: c.email,
                  country: country_object,
                  notes: su.subscription_user_notes.map {|n|
                    {
                      id: n.id,
                      note: n.note,
                      createdAt: n.created_at
                    }
                  }
                }
              },
            }
          end
        }
      }
    end
  end
  
  def category_companies
    respond_to do |format| 
      format.json {
        render json: { 
          results: Company.joins(:company_category).group_by(&:company_category_label)
        }
      }
    end
  end
 
  def create_call_reminder
    user = current_resource_owner 
    subscription_id = params[:subscriptionId]
    customer_id = params[:customerId]
    title = params[:title]
    call_date = params[:callDate]

    su = SubscriptionUser.where(subscription_id: subscription_id, user_id: customer_id).first
    if (su) 
      cr = SubscriptionUserCallReminder.create(subscription_user: su, title: title, call_date: call_date)
    else 
    end
    # TODO Send back a success/error message
  end

  def call_reminders
    user = current_resource_owner
    respond_to do |format| 
      format.json {
        render json: { 
          results: user.subscription_user_call_reminders.order(:call_date).map {|call_reminder|
            {
              title: call_reminder.title,
              callDate: call_reminder.call_date,
              customerName: call_reminder.subscription_user.user.full_name,
              phone: call_reminder.subscription_user.user.phone
            }
          }
        }
      }
    end
  end

  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
