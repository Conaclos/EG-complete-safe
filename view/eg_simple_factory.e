note
	description: "Factory for the simple figures."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

class
	EG_SIMPLE_FACTORY

inherit
	EG_FIGURE_FACTORY

create
	default_create

feature -- Basic operations

	new_node_figure (a_node: EG_NODE): EG_LINKABLE_FIGURE
			-- <Precursor>
		do
			create {EG_SIMPLE_NODE} Result.make_with_model (a_node)
		end

	new_cluster_figure (a_cluster: EG_CLUSTER): EG_CLUSTER_FIGURE
		-- <Precursor>
		do
			create {EG_SIMPLE_CLUSTER} Result.make_with_model (a_cluster)
		end

	new_link_figure (a_link: EG_LINK; a_source, a_target: EG_LINKABLE_FIGURE): EG_LINK_FIGURE
			-- <Precursor>
		do
			create {EG_SIMPLE_LINK} Result.make (a_link, a_source, a_target)
		end

	model_from_xml (a_node: like xml_element_type): detachable EG_ITEM
			-- <Precursor>
		do
			if attached a_node.name as l_name then
				if l_name.same_string ("EG_SIMPLE_NODE") then
					create {EG_NODE} Result
				elseif l_name.same_string ("EG_SIMPLE_CLUSTER") then
					create {EG_CLUSTER} Result
				elseif
					l_name.same_string ("EG_SIMPLE_LINK") and

					attached a_node.attribute_by_name ("SOURCE") as l_attribute_by_name and then
					attached l_attribute_by_name.value as l_source_name and then
					attached linkable_with_name (l_source_name) as l_source and

					attached a_node.attribute_by_name ("TARGET") as l_attribute_by_name_2 and then
					attached l_attribute_by_name_2.value as l_target_name and then
					attached linkable_with_name (l_target_name) as l_target
				then
					create {EG_LINK} Result.make_with_source_and_target (l_source, l_target)
				end
			end
		end

note
	copyright:	"Copyright (c) 1984-2014, Eiffel Software and others"
	license:	"Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"




end -- class EG_SIMPLE_FACTORY

