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
	end
end
