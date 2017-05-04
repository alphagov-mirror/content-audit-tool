module TableHelper
  def sort_table_header(heading, attribute_name)
    SortTable.new(self, heading, attribute_name).render
  end

  class SortTable
    attr_accessor :view, :heading, :attribute_name

    delegate :content_tag, :params, :link_to, :content_items_path, to: :view

    def initialize(view, heading, attribute_name)
      @view = view
      @heading = heading
      @attribute_name = attribute_name
    end

    def render
      content_tag :th, "aria-sort" => aria_label do
        link text_label, order_param
      end
    end

  private

    def link(label, order)
      link_options = {
          sort: attribute_name,
          order: order,
          query: params[:query]
      }

      link_options[:organisation_id] = view.instance_variable_get(:@organisation).content_id if view.instance_variable_get(:@organisation).present?
      link_options[:taxonomy_content_id] = view.instance_variable_get(:@taxonomy).content_id if view.instance_variable_get(:@taxonomy).present?

      link_to content_items_path(link_options) do
        "#{heading}#{content_tag :span, label, class: 'rm'}".html_safe
      end
    end

    def currently_sorted_by?
      params[:order].present? && params[:sort] == attribute_name
    end

    def text_label
      ", sort #{readable_sort_term(order_param)}"
    end

    def order_param
      if currently_sorted_by? && params[:order] == "asc"
        "desc"
      else
        "asc"
      end
    end

    def aria_label
      if currently_sorted_by?
        readable_sort_term(params[:order])
      else
        "none"
      end
    end

    def readable_sort_term(term)
      term_map = { "asc" => "ascending", "desc" => "descending" }
      term_map[term] || "ascending"
    end
  end
end
