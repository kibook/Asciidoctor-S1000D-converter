module Asciidoctor
	class Converter::S1000D < Converter::Base
		register_for 's1000d'

		def initialize *args
			super
			filetype 'xml'
			outfilesuffix '.xml'
		end

		def common_attributes id
			if id
				%( id="#{id}")
			end
		end

		def convert_document node
			result = %(<content><description>#{node.content}</description></content>)
		end

		def convert_paragraph node
			result = %(<para#{common_attributes node.id}>#{node.content}</para>)
		end

		def convert_ulist node
			result = %(<para><randomList#{common_attributes node.id}>)
			node.items.each do |item|
				if item.blocks?
					result << %(<listItem>#{item.content}</listItem>)
				else
					result << %(<listItem><para>#{item.text}</para></listItem>)
				end
			end
			result << %(</randomList></para>)
		end

		def convert_olist node
			result = %(<para><sequentialList#{common_attributes node.id}>)
			node.items.each do |item|
				if item.blocks?
					result << %(<listItem>#{item.content}</listItem>)
				else
					result << %(<listItem><para>#{item.text}</para></listItem>)
				end
			end
			result << %(</sequentialList></para>)
		end

		def convert_dlist node
			result = %(<para><definitionList#{common_attributes node.id}>)
			node.items.each do |terms, dd|
				result << %(<definitionListItem><listItemTerm>)
				terms.each {|dt| result << dt.text}
				result << %(</listItemTerm><listItemDefinition>)
				if dd
					result << %(<para>#{dd.text}</para>) if dd.text?
					result << dd.content if dd.blocks?
				else
					result << %(<para/>)
				end

				result << %(</listItemDefinition></definitionListItem>)
			end

			result << %(</definitionList></para>)
		end

		def convert_section node
			result = %(<levelledPara#{common_attributes node.id}><title>#{node.title}</title>#{node.content}</levelledPara>)
		end

		def convert_inline_anchor node
			result = %(<internalRef internalRefId="#{node.target[1..-1]}">#{node.text}</internalRef>)
		end

		def convert_table node
			pgwide = (node.option? 'pgwide') ? 1 : 0
			frame = node.attr 'frame', 'all'
			grid = node.attr 'grid', nil, 'table-grid'
			result = %(<table#{common_attributes node.id} frame="#{frame}" pgwide="#{pgwide}" rowsep="#{['none', 'cols'].include?(grid) ? 0 : 1}" colsep="#{['none', 'rows'].include?(grid) ? 0 : 1}"#{(node.attr? 'orientation', 'landscape', 'table-orientation') ? 'orient="land"' : ''}>)
			result << %(<title>#{node.title}</title>) if node.title?
			result << %(<tgroup cols="#{node.attr 'colcount'}">)

			col_width_key = if (width = (node.attr? 'width') ? (node.attr 'width') : nil)
				'colabswidth'
			else
				'colpcwidth'
			end

			node.columns.each do |col|
				result << %(<colspec colname="col_#{col.attr 'colnumber'}" colwidth="#{col.attr col_width_key}*"/>)
			end

			node.rows.to_h.each do |tsec, rows|
				next if rows.empty?
				result << %(<t#{tsec}>)
				rows.each do |row|
					result << %(<row>)
					row.each do |cell|
						halign_attribute = (cell.attr? 'halign') ? %( align="#{cell.attr 'halign'}") : ''
						valign_attribute = (cell.attr? 'valign') ? %( valign="#{cell.attr 'valign'}") : ''
						colspan_attribute = cell.colspan ? %( namest="col_#{colnum = cell.column.attr 'colnumber'}" nameend="col_#{colnum + cell.colspan - 1}") : ''
						rowspan_attribute = cell.rowspan ? %( morerows="#{cell.rowspan - 1}") : ''

						entry_start = %(<entry#{halign_attribute}#{valign_attribute}#{colspan_attribute}#{rowspan_attribute}>)

						case cell.style
						when :asciidoc
							cell_content = cell.content
						else
							cell_content = %(<para>#{cell.text}</para>) if not cell.text.empty?
						end

						entry_end = %(</entry>)

						result << %(#{entry_start}#{cell_content}#{entry_end})
					end
					result << %(</row>)
				end
				result << %(</t#{tsec}>)
			end

			result << %(</tgroup>)
			result << %(</table>)
		end

		alias convert_embedded content_only
	end
end
