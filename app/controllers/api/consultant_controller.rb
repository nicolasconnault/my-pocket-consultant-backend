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
              status: s.status,
              logoUrl: (s.company.logo.attached? && !s.company.logo.blob.nil?) ? url_for(s.company.logo.variant(resize: '300x300').processed.service_url) : nil, 
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
                regularPrice: ni.regularPrice,
                imageUrl: (ni.image.attached? && !ni.image.blob.nil?) ? url_for(ni.image.variant(resize: '400x300').processed.service_url) : nil
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
                      title: n.title,
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
        records = Company.joins(:company_category).group_by(&:company_category_label)
        results = {}
        records.each do |category_name, companies|
          results[category_name] = []
          companies.each do |company|
            results[category_name].push({
              id: company.id,
              name: company.name,
              label: company.label,
              categoryId: company.company_category_id,
              categoryName: company.company_category.name,
              categoryLabel: company.company_category.label,
              logoUrl: (company.logo.attached? && !company.logo.blob.nil?) ? url_for(company.logo.variant(resize: '300x300').processed.service_url) : nil
            })
          end
        end
        render json: { 
          results: results
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

  # CUSTOMER NOTES

  def create_customer_note
    user = current_resource_owner 
    subscription_id = params[:subscriptionId]
    customer_id = params[:customerId]
    title = params[:title]
    note = params[:note]

    su = SubscriptionUser.where(subscription_id: subscription_id, user_id: customer_id).first
    if (su) 
      cr = SubscriptionUserNote.create(subscription_user: su, title: title, note: note)
    else 
    end
    # TODO Send back a success/error message
  end

  def update_customer_note
    note_id = params[:customerNoteId]
    title = params[:title]
    note = params[:note]
    SubscriptionUserNote.find(note_id).update(title: title, note: note)
    # TODO Send back a success/error message
  end

  def remove_customer_note
    SubscriptionUserNote.find(params[:customerNoteId]).destroy
    # TODO Send back a success/error message
  end

  # SUBSCRIPTIONS

  def create_subscription
    user = current_resource_owner 
    company_id = params[:companyId]
    website_url = params[:websiteUrl]
    facebook_url = params[:facebookUrl]
    twitter_url = params[:twitterUrl]

    s = Subscription.where(company_id: company_id, user_id: user.id).first
    if s.nil? 
      s = Subscription.create(
        company_id: company_id,
        user_id: user.id,
        website_url: website_url,
        facebook_url: facebook_url,
        twitter_url: twitter_url,
        active: false
      )
    end
    # TODO Send back a success/error message
  end

  def deactivate_subscription
    user = current_resource_owner 
    subscription_id = params[:subscriptionId]
    subscription = Subscription.find(subscription_id)
    subscription.update(active: false)
    # TODO send a notification to every customer, tell them that this consultant is now offline, and prompt them to choose a new one when they click the notification or next time they launch the app

    subscription.subscription_users.each do |su|
      su.destroy
    end
    # TODO Send back a success/error message
  end

  def update_subscription
    user = current_resource_owner 
    subscription_id = params[:subscriptionId]
    website_url = params[:websiteUrl]
    facebook_url = params[:facebookUrl]
    twitter_url = params[:twitterUrl]
    Subscription.find(subscription_id).update(website_url: website_url, facebook_url: facebook_url, twitter_url: twitter_url)
    # TODO Send back a success/error message
  end

  def remove_subscription
    Subscription.find(params[:subscriptionId]).destroy
    # TODO Send back a success/error message
    # TODO manage Stripe subscription
  end

  def save_subscription_token
    token = params[:stripeToken]
    subscription = Subscription.find(params[:subscriptionId])
    subscription.enabled = true
    subscription.save!
  end

  # NEWS ITEMS
  
  def create_news_item
    news_type_id = params[:newsTypeId]
    subscription_id = params[:subscriptionId]
    title = params[:title]
    description = params[:description]
    start_date = params[:startDate]
    end_date = params[:endDate]
    active = params[:active]
    url = params[:url]
    discounted_price = params[:discountedPrice]
    regular_price = params[:regularPrice]
    news_item = NewsItem.create(
      news_type_id: news_type_id,
      subscription_id: subscription_id,
      title: title,
      description: description,
      start_date: start_date,
      end_date: end_date,
      active: active,
      url: url,
      discountedPrice: discounted_price,
      regularPrice: regular_price
    )

    subscription = Subscription.find(params[:subscriptionId])
    news_item.image.attach(subscription.news_item_temp_image.blob)
    subscription.news_item_temp_image = nil
    subscription.save!
    respond_to do |format| 
      format.json {
        render json: { 
          results: news_item.to_json
        }
      }
    end
  end

  def update_news_item
    news_item_id = params[:newsItemId]
    title = params[:title]
    description = params[:description]
    start_date = params[:startDate]
    end_date = params[:endDate]
    active = params[:active]
    url = params[:url]
    discounted_price = params[:discountedPrice]
    regular_price = params[:regularPrice]

    NewsItem.find(news_item_id).update(
      title: title,
      description: description,
      start_date: start_date,
      end_date: end_date,
      active: active,
      url: url,
      discountedPrice: discounted_price,
      regularPrice: regular_price
    )
  end

  def remove_news_item
    NewsItem.find(params[:newsItemId]).destroy
  end

  def toggle_news_item
    ni = NewsItem.find(params[:newsItemId])
    ni.update(active: !params[:oldValue])
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

  def upload_image_for_new_news_item
    subscription = Subscription.find(params[:subscription_id])
    if subscription.news_item_temp_image.attached?
      subscription.news_item_temp_image.purge
    end
    subscription.news_item_temp_image.attach(params[:photo])

    subscription.save!
    respond_to do |format| 
      format.json {
        render json: { 
          results: { location: url_for(subscription.news_item_temp_image.variant(resize: '400x300').processed.service_url) }
        }
      }
    end
  end

  def upload_image
    news_item = NewsItem.find(params[:news_item_id])
    news_item.image.attach(params[:photo])

    news_item.save!
    respond_to do |format| 
      format.json {
        render json: { 
          results: { location: url_for(news_item.image.variant(resize: '400x300').processed.service_url) }
        }
      }
    end
  end
end
