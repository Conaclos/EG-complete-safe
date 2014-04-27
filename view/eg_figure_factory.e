note
	description: "Objects that produces views for given models."
	legal: "See notice at end of class."
	status: "See notice at end of class."
	date: "$Date$"
	revision: "$Revision$"

deferred class
	EG_FIGURE_FACTORY

feature -- Access

	world: detachable EG_FIGURE_WORLD
			-- World `Current' is a factory for.
		note
			option: stable
		attribute end

	new_node_figure (a_node: EG_NODE): EG_LINKABLE_FIGURE
			-- Create a node figure for `a_node'
		require
			a_node_not_void: a_node /= Void
		deferred
		ensure
			result_not_void: Result /= Void
		end

	new_cluster_figure (a_cluster: EG_CLUSTER): EG_CLUSTER_FIGURE
			-- Create a cluster figure for `a_cluster'.
		require
			a_cluster_not_void: a_cluster /= Void
		deferred
		ensure
			result_not_void: Result /= Void
		end

	new_link_figure (a_link: EG_LINK; a_source, a_target: EG_LINKABLE_FIGURE): EG_LINK_FIGURE
			-- Create a link figure for `a_link'.
		require
			a_link_not_void: a_link /= Void
		deferred
		ensure
			result_not_void: Result /= Void
		end

	model_from_xml (a_node: like xml_element_type): detachable EG_ITEM
			-- Create an EG_ITEM from `a_node' if possible.
		require
			node_not_void: a_node /= Void
		deferred
		end

feature {EG_FIGURE_WORLD} -- Implementation

	set_world (a_world: attached like world)
			-- Set `world' to `a_world'.
		require
			a_world_not_void: a_world /= Void
		do
			world := a_world
		ensure
			set: world = a_world
		end

feature {NONE} -- Implementation

	linkable_with_name (a_name: STRING): detachable EG_LINKABLE
			-- Linkable with name `a_name' in graph if any.
		require
			a_name_not_void: a_name /= Void
		do
			if world /= Void then
				across
					world.model.flat_nodes as it
				until
					Result /= Void
				loop
					if it.item.name ~ a_name then
						Result := it.item
					end
				end

				if Result = Void then
					across
						world.model.flat_clusters as it
					until
						Result /= Void
					loop
						if it.item.name ~ a_name then
							Result := it.item
						end
					end
				end
			end
		end

feature {NONE} -- Anchor

	xml_element_type: XML_ELEMENT
			-- Element type for compilation purpose.
		require
			callable: False
		do
			check callable: False then end
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




end -- class EG_FIGURE_FACTORY

