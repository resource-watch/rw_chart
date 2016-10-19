# frozen_string_literal: true
# == Schema Information
#
# Table name: charts
#
#  id           :uuid             not null, primary key
#  name         :string           not null
#  slug         :string
#  description  :text
#  source       :string
#  source_url   :string
#  authors      :string
#  query_url    :string
#  chart_config :jsonb
#  status       :integer          default(0)
#  published    :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  verified     :boolean          default(FALSE)
#  layer_id     :uuid
#  dataset_id   :uuid
#  template     :boolean          default(FALSE)
#  default      :boolean          default(FALSE)
#  application  :jsonb
#

class Chart < ApplicationRecord
  STATUS = %w(pending saved failed deleted).freeze

  before_save   :merge_apps, if: 'application_changed?'
  before_update :assign_slug

  before_validation(on: [:create, :update]) do
    check_slug
  end

  before_save :generate_dataset_id, if: 'query_url_changed? || dataset_id.blank?'

  validates :name, presence: true
  validates :slug, presence: true, format: { with: /\A[^\s!#$%^&*()（）=+;:'"\[\]\{\}|\\\/<>?,]+\z/,
                                             allow_blank: true,
                                             message: 'invalid. Slug must contain at least one letter and no special character' }
  validates_uniqueness_of :name, :slug

  scope :recent,             -> { order('updated_at DESC')      }
  scope :filter_pending,     -> { where(status: 0)              }
  scope :filter_saved,       -> { where(status: 1)              }
  scope :filter_failed,      -> { where(status: 2)              }
  scope :filter_inactives,   -> { where(status: 3)              }
  scope :filter_published,   -> { where(published: true)        }
  scope :filter_unpublished, -> { where(published: false)       }
  scope :filter_verified,    -> { where(verified: true)         }
  scope :filter_unverified,  -> { where(verified: false)        }
  scope :filter_template,    -> { where(template: true)         }
  scope :notfilter_template, -> { where(template: false)        }
  scope :filter_default,     -> { where(default: true)          }
  scope :notfilter_default,  -> { where(default: false)         }
  scope :filter_actives,     -> { filter_saved.filter_published }

  scope :filter_apps,     -> (app)     { where('application ?| array[:keys]', keys: ["#{app}"]) }
  scope :filter_dataset,  -> (dataset) { where(dataset_id: dataset)                             }

  def status_txt
    STATUS[status - 0]
  end

  def deleted?
    status_txt == 'deleted'
  end

  class << self
    def by_id_or_slug(param)
      chart_id = where(slug: param).or(where(id: param)).pluck(:id).min
      find(chart_id) rescue nil
    end

    def fetch_all(options)
      status    = options['status'].downcase if options['status'].present?
      published = options['published']       if options['published'].present?
      verified  = options['verified']        if options['verified'].present?
      app       = options['app'].downcase    if options['app'].present?
      template  = options['template']        if options['template'].present?
      dataset   = options['dataset']         if options['dataset'].present?
      default   = options['default']         if options['default'].present?

      charts = recent

      charts = case status
               when 'pending'  then charts.filter_pending
               when 'active'   then charts.filter_actives
               when 'failed'   then charts.filter_failed
               when 'disabled' then charts.filter_inactives
               when 'all'      then charts
               else
                 published.present? || verified.present? ? charts : charts.filter_actives
                end

      charts = charts.filter_published        if published.present? && published.include?('true')
      charts = charts.filter_unpublished      if published.present? && published.include?('false')
      charts = charts.filter_verified         if verified.present?  && verified.include?('true')
      charts = charts.filter_unverified       if verified.present?  && verified.include?('false')
      charts = app_filter(charts, app)        if app.present?
      charts = charts.filter_template         if template.present?  && template.include?('true')
      charts = charts.notfilter_template      if template.present?  && template.include?('false')
      charts = charts.filter_default          if default.present?   && default.include?('true')
      charts = charts.notfilter_default       if default.present?   && default.include?('false')
      charts = charts.filter_dataset(dataset) if dataset.present?

      charts
    end

    def app_filter(scope, app)
      charts = scope
      charts = if app.present? && !app.include?('all')
                 charts.filter_apps(app)
               else
                 charts
                end

      charts
    end
  end

  private

    def merge_apps
      self.application = self.application.each { |a| a.downcase! }.uniq
    end

    def check_slug
      self.slug = self.name.downcase.parameterize if self.name.present? && self.slug.blank?
    end

    def assign_slug
      self.slug = self.slug.downcase.parameterize
    end

    def generate_dataset_id
      self.dataset_id = URI.parse(self.query_url).path.split('/').last if self.query_url.present?
    end
end
