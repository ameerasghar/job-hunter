class Job < ActiveRecord::Base
  belongs_to :user
  validates :title, :company, :description, presence: true
  validates :title, uniqueness: true, on: :create

  scope :match, -> { where('score > 50') }

  def logo_validator(url)
    res = Faraday.get("https://logo.clearbit.com/#{url}")
    unless res.status == 200
      "https://placeholdit.imgix.net/~text?txtsize=33&txt=400%C3%97400&w=400&h=400"
    else
      "https://logo.clearbit.com/#{url}"
    end
  end

  # Searches for jobs.
  def self.get_jobs
    %x(bin/rails r scraper.rb)
  end

  # Apply for the matching jobs.
  def self.apply(jobs)
    jobs.each do |job|
      %x(bin/rails r applier.rb #{job.url})
    end
  end
end
