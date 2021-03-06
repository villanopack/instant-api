require 'instant_api/model/active_record_query_builder'

module InstantApi::Model
  class Collection
    attr_reader :params, :query_builder

    def initialize(klass, params)
      @params = params
      @query_builder = InstantApi::Model::ActiveRecordQueryBuilder.new(klass)
    end

    def page
      @page ||= [(params[:page] || 1).to_i, 1].max
    end

    def per_page
      @per_page ||= begin
        aux = (params[:per_page] || 10).to_i
        if aux < 1
          aux = 10
        end
        [aux, 10].min
      end
    end

    def count
      collection.count
    end

    def collection
      @collection ||= query_builder.query(params)
    end

    def paginated_collection
      collection_to_paginate = if collection.is_a?(Array)
                                 Kaminari::paginate_array(collection)
                               else
                                 collection
                               end
      collection_to_paginate.page(page).per(per_page)
    end
  end
end
