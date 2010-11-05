require 'rubygems'
require 'sinatra'
require 'pp'
require 'erb'
require 'gattica'
require 'json'
require 'twitter'

class Time
  def yesterday
    self - 86400
  end
  
  def one_week_ago
    self - (86400 * 7)
  end
  
  def one_month_ago
    self - 2629743.83
  end
  
  def two_months_ago
    self - (2629743.83 * 2)
  end
    
  def three_months_ago
    self - (2629743.83 * 3)
  end
  
  def six_months_ago
    self - (2629743.83 * 6)
  end
  
  def one_year_ago
    self - (2629743.83 * 12)
  end
end

$ga_username  = 'GA-USERNAME'
$ga_password  = 'GA-PASSWORD'
$ga_profileid = 'GA-PROFILEID'


get '/' do
  erb :index
end

get '/twitter' do
  # NOT SHOWN: granting access to twitter on website
  # and using request token to generate access token
  oauth = Twitter::OAuth.new('TWITTER-CONSUMER-KEY', 'TWITTER-CONSUMER-SECRET')
  oauth.authorize_from_access('TWITTER-ACCESS-TOKEN', 'TWITTER-ACCESS-TOKEN-SECRET')

  @client = Twitter::Base.new(oauth)
  # @client.friends_timeline.each  { |tweet| @twitter << tweet }
  # @client.user_timeline.each     { |tweet| @twitter << tweet }
  # @client.replies.each           { |tweet| @twitter << tweet }
  
  erb :twitter
end

get '/pagestats/visitors/week' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_visitors = gs.get({
    :start_date => Time.now.three_months_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['week','year'],
    :metrics => ['visitors']
  })
  @ga_results = []
  @ga_results_visitors.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_results.push([date.dimensions[0][:week].to_i, date.metrics[0][:visitors]]);
    end
  end
  erb :ga
end

get '/pagestats/visitors/month' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_visitors = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['year','month'],
    :metrics => ['visitors']
  })
  @ga_results = []
  @ga_results_visitors.points.each do |date|
    unless date.metrics[0][:visitors] == 0
      point_time = Time.parse(date.dimensions[0][:year] + "-" + date.dimensions[1][:month] + "-01")
      @ga_results.push([point_time.to_i * 1000, date.metrics[0][:visitors]]);
    end
  end
  erb :ga
end

get '/pagestats/homepage' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['day','month','year','pagePath'],
    :metrics => ['pageviews'],
    :filters => ['pagePath == /www.sitepoint.com/'],
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    point_time = Time.parse(date.dimensions[2][:year] + "-" + date.dimensions[1][:month] + "-" + date.dimensions[0][:day])
    @ga_results.push([point_time.to_i * 1000, date.metrics[0][:pageviews] ]);
  end
  
  @ga_results.sort! {|a,b| a[0]<=>b[0]}
  erb :ga
end

get '/pagestats/browsers' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['browser'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 5000']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  p @ga_browser_pageviews_total
  
  @ga_results_browsers.points.each do |date|
    if (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f > 5
      @ga_results.push([date.dimensions[0][:browser], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/pagestats/browsers/ie' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['browser','browserVersion'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 5000','browser == Internet Explorer']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  
  @ga_results_browsers.points.each do |date|
    if (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f > 1
      @ga_results.push([date.dimensions[1][:browserVersion], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/pagestats/browsers/opera' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['browser','browserVersion'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 5000','browser == Opera']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  
  @ga_results_browsers.points.each do |date|
    if date.dimensions[1][:browserVersion] != '(not set)' && (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f > 5
      @ga_results.push([date.dimensions[1][:browserVersion], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/pagestats/browsers/ff' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['browser','browserVersion'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 5000','browser == Firefox']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  
  @ga_results_browsers.points.each do |date|
    if (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f > 5
      @ga_results.push([date.dimensions[1][:browserVersion], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/pagestats/browsers/chrome' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['browser','browserVersion'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 5000','browser == Chrome']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  
  @ga_results_browsers.points.each do |date|
    if (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f > 5
      @ga_results.push([date.dimensions[1][:browserVersion], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/pagestats/browsers/safari' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['browser','browserVersion'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 5000','browser == Safari']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  
  @ga_results_browsers.points.each do |date|
    if (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f > 5
      @ga_results.push([date.dimensions[1][:browserVersion], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/pagestats/landingpage' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['landingPagePath'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 500'],
    :sort => ['-pageviews']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  
  @ga_results_browsers.points.each do |date|
    @ga_results.push([date.dimensions[0][:landingPagePath], date.metrics[0][:pageviews] ]);
  end
  
  erb :ga
end

get '/pagestats/landingpage/books' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['landingPagePath'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 500'],
    :sort => ['-pageviews']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  
  @ga_results_browsers.points.each do |date|
    if date.dimensions[0][:landingPagePath] =~ /www.sitepoint.com\/books\/(?!pdf)/ || date.dimensions[0][:landingPagePath] =~ /courses.sitepoint.com\//
      @ga_results.push([date.dimensions[0][:landingPagePath], date.metrics[0][:pageviews] ]);
    end
  end
  
  erb :ga
end

get '/pagestats/landingpage/articles' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['landingPagePath'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 500'],
    :sort => ['-pageviews']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  
  @ga_results_browsers.points.each do |date|
    if date.dimensions[0][:landingPagePath] =~ /articles.sitepoint.com\/article\//
      @ga_results.push([date.dimensions[0][:landingPagePath], date.metrics[0][:pageviews] ]);
    end
  end
  
  erb :ga
end

get '/pagestats/landingpage/blogs' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['landingPagePath'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 500'],
    :sort => ['-pageviews']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  
  @ga_results_browsers.points.each do |date|
    if date.dimensions[0][:landingPagePath] =~ /www.sitepoint.com\/blogs\//
      @ga_results.push([date.dimensions[0][:landingPagePath], date.metrics[0][:pageviews] ]);
    end
  end
  
  erb :ga
end

get '/pagestats/exitpage' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['exitPagePath'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 500'],
    :sort => ['-pageviews']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  
  @ga_results_browsers.points.each do |date|
    @ga_results.push([date.dimensions[0][:exitPagePath], date.metrics[0][:pageviews] ]);
  end
  
  erb :ga
end

get '/pagestats/countries' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['country'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 500'],
    :sort => ['-pageviews']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  
  @ga_results_browsers.points.each do |date|
    if (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f > 2
      @ga_results.push([date.dimensions[0][:country], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/pagestats/landingpage/courses' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['landingPagePath'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 500'],
    :sort => ['-pageviews']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  
  @ga_results_browsers.points.each do |date|
    if date.dimensions[0][:landingPagePath] =~ /courses.sitepoint.com\//
      @ga_results.push([date.dimensions[0][:landingPagePath], date.metrics[0][:pageviews] ]);
    end
  end
  
  erb :ga
end

get '/pagestats/browsers/os' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_browsers = gs.get({
    :start_date => Time.now.one_year_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['operatingSystem'],
    :metrics => ['pageviews'],
    :filters => ['pageviews >= 50000']
  })
  @ga_results = []
  @ga_browser_pageviews_total = 0
  @ga_results_browsers.points.each do |date|
    unless date.metrics[0][:visitors] == 0 
      @ga_browser_pageviews_total += date.metrics[0][:pageviews]
    end
  end
  p @ga_browser_pageviews_total
  
  @ga_results_browsers.points.each do |date|
    unless date.dimensions[0][:operatingSystem] == '(not set)'
      @ga_results.push([date.dimensions[0][:operatingSystem], (date.metrics[0][:pageviews].to_f/@ga_browser_pageviews_total.to_f)*100.to_f ]);
    end
  end
  
  erb :ga
end

get '/ecommerce/revenue' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_visitors = gs.get({
    :start_date => Time.now.one_month_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['day','month','year'],
    :metrics => ['itemRevenue']
  })
  @ga_results = []
  @ga_results_visitors.points.each do |date|
      point_time = Time.parse(date.dimensions[2][:year] + "-" + date.dimensions[1][:month] + "-" + date.dimensions[0][:day])
    @ga_results.push([point_time.to_i * 1000, date.metrics[0][:itemRevenue]]);
  end
  
  @ga_results.sort! {|a,b| a[0]<=>b[0]}
  erb :ga
end

get '/ecommerce/transactions/yesterday' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_visitors = gs.get({
    :start_date => Time.now.yesterday.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['day','month','year'],
    :metrics => ['transactions','transactionRevenue']
  })
  @ga_results = []
  @ga_results_visitors.points.each do |date|
    unless date.metrics[0][:transactions] == 0
      @ga_results.push([date.dimensions[0][:day] + "/" + date.dimensions[1][:month], date.metrics[0][:transactions], date.metrics[1][:transactionRevenue]]);
    end
  end
  
  @ga_results.sort! {|a,b| a[0]<=>b[0]}
  erb :ga
end

get '/ecommerce/sales' do
  gs = Gattica.new({:email => $ga_username, :password => $ga_password, :profile_id => $ga_profileid})
  @ga_results_visitors = gs.get({
    :start_date => Time.now.one_week_ago.strftime("%Y-%m-%d"),
    :end_date => Time.now.strftime("%Y-%m-%d"),
    :dimensions => ['productName','productSku'],
    :metrics => ['itemRevenue','itemQuantity']
  })
  @ga_results = []
  @ga_results_visitors.points.each do |date|
    unless date.metrics[0][:itemRevenue] == 0
      @ga_results.push([date.metrics[0][:itemRevenue], date.metrics[1][:itemQuantity], date.dimensions[0][:productName], date.dimensions[1][:productSku].downcase]);
    end
  end
  
  @ga_results.sort! {|a,b| b[0]<=>a[0]}
  erb :ga
end

