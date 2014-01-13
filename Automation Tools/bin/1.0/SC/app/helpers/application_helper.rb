module ApplicationHelper
  def sortthis(ac, column, title=nil)
    title ||= column.titleize
    css_class = column == default_column_sort ? "sort_#{default_column_direction}" : "sort_option"
    direction = column == default_column_sort && default_column_direction == "asc" ? "desc" : "asc"
    ((link_to title, {:action => ac,:sort => column, :direction => direction}, {:class => css_class}) + raw("<span class='#{css_class}'></span>"))
  end
  def is_active?(page)
    "active" if "#{params[:controller]}_#{params[:action]}" == page
  end
end